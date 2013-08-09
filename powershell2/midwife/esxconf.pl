#!/usr/bin/perl -w

use strict;
use warnings;
use VMware::VIRuntime;
use VMware::VILib;
use Socket;
use threads;
use Data::Dumper;

my $program = $0;

my %nas = (
    vms => { name => 'vms', host => '10.17.145.5', path => '/vms', mode => 'readWrite' },
    iso => { name => 'iso', host => '10.17.145.5', path => '/iso', mode => 'readOnly' }
    );

my %vswitches = (
    vSwitch0 => {name => 'vSwitch0', numPorts => 32},
    vSwitch1 => {name => 'vSwitch1', numPorts => 64}, 
#    vSwitch2 => {name => 'vSwitch2', numPorts => 64}, 
    );

my %portgroups = (
    pg0 => { name => 'Production', vSwitch => 'vSwitch0' },
    pg1 => { name => 'Local', vSwitch => 'vSwitch1' }
    );

my %nicAssignments = (
    vmnic0 => 'vSwitch0',
    vmnic1 => 'vSwitch1',
    default => 'vSwitch1'
    );

my $vmotionNic = "vmk0";

# ntp[12].sfo1.eng.vmware.com
my @ntpHosts = ("10.17.148.1", "10.17.148.2");
#  my @ntpHosts = ("10.2.128.10");
#my @ntpHosts = ("vmc-ntp1.eng.vmware.com", "vmc-ntp2.eng.vmware.com");


$Data::Dumper::Sortkeys = 1; #Sort the keys in the output
$Data::Dumper::Deepcopy = 1; #Enable deep copies of structures
$Data::Dumper::Indent = 2; #Output in a reasonable style (but no array indexes)

my %opts = (
    service => {
	type => '!',
	help => "Run as Serivce",
	default => 0,
	required => 0,
    },
    destroy => {
	type => '!',
	help => "Destroy host",
	default => 0,
	required => 0,
    },
    cluster => {
	type => "=s",
	help => "Target Cluster",
	variable => "TARGET_CLUSTER",
	required => 1,
    },
    target_host => {
	type => "=s",
	help => "Hostname or IP address",
	variable => "TARGET_HOST",
	required => 0,
    },
    target_username => {
	type => "=s",
	help => "Admisitrator on target (root)",
	variable => "TARGET_USERNAME",
	default => 'root',
	required => 0,
    },
    target_password => {
	type => "=s",
	help => "Administrator's password on target",
	variable => "TARGET_PASSWORD",
	default => "",
	required => 0,
    },
    target_newpassword => {
	type => "=s",
	help => "New root password on target",
	variable => "TARGET_NEWPASSWORD",
	default => undef,
	required => 0,
    }

    );

Opts::add_options(%opts);
Opts::parse();
Opts::validate(\&validate);

my $target_cluster = Opts::get_option('cluster');
my $target_username = Opts::get_option('target_username');
my $target_password = Opts::get_option('target_password');
my $verbose = Opts::get_option('verbose');

sub esx_add() {
    my ($target_host) = @_;
    my $host;
    my $cluster_name = Opts::get_option('cluster');
    my $cluster_views =
	Vim::find_entity_views(view_type => 'ClusterComputeResource',
			       filter => {name => $cluster_name});

    unless (@$cluster_views) {
	print("$target_cluster: Cluster not found \n") if $verbose;
	return;
    }

    my $cluster = shift @$cluster_views;
    my $host_connect_spec = HostConnectSpec->new(force => (1||1),
						 hostName => $target_host,
						 userName => $target_username,
						 password => $target_password,
	);
    my ($task, $task_info, $task_state);
    print("$target_host: AddHost\n") if $verbose;
    my $task_object = $cluster->AddHost_Task(spec => $host_connect_spec, asConnected => 1);
    do {
	sleep 10;
	$task = Vim::get_view(mo_ref => $task_object);
	$task_info = $task->info;
	$task_state = $task_info->state->val;
	my $progress = $task_info->progress;
	my $s = (!defined $progress) ? (".") : ("$progress\%");
	print("$target_host: AddHost: $s ($task_state)\n") if $verbose;
    } while  (($task_state eq 'running') || ($task_state eq 'queued'));

    warn("$target_host: AddHost: " . $task_info->error . "\n") if ($task_state eq 'error');

    return $task->info->result;
}

sub exitMaintenanceMode() {
    my ($target_host, $hostRef) = @_;

    my $host = Vim::get_view(mo_ref => $hostRef);
    if ($host->runtime->inMaintenanceMode) {
	print("$target_host: ExitMaintenanceMode\n") if $verbose;
	eval { $host->ExitMaintenanceMode(timeout => 0); };
	warn("$target_host: ExitMaintenanceMode: " . $@ . "\n") if ($@);
    }
}

sub configureStorage() {
    my ($target_host, $hostRef) = @_;
    my $host = Vim::get_view(mo_ref => $hostRef);
    my $configMgr = $host->configManager;
    my $dsSystem = Vim::get_view(mo_ref => $configMgr->datastoreSystem);

    foreach my $mount(sort keys %nas) {
	my $nasSpec = HostNasVolumeSpec->new(
	    accessMode => $nas{$mount}{mode},
	    localPath => $nas{$mount}{name},
	    remoteHost => $nas{$mount}{host},
	    remotePath => $nas{$mount}{path},
	    );

#print Dumper($nasSpec);
#print "\n";

	if (defined $host->datastore) {
	    foreach my $ds (@{$host->datastore}) {
		my $dsView = Vim::get_view(mo_ref => $ds);
		my $dsName = $dsView->info->name;
		
		if ($dsName eq $nas{$mount}{name}) {
		    print "$target_host: NAS mount $dsName exists\n" if $verbose;
		    next;
		}
	    }
	}

	print("$target_host: CreateNasDatastore $mount\n") if $verbose;
	eval { $dsSystem->CreateNasDatastore(spec => $nasSpec); };
	warn("$target_host: CreateNasDatastore $mount Error: "  . $@ . "\n") if ($@);
    }
    return $@ if ($@);
    return 0;
}

sub configureNetworking() {
    my ($target_host, $hostRef) = @_;
    my $host = Vim::get_view(mo_ref => $hostRef);
    my $netMgr = Vim::get_view(mo_ref => $host->configManager->networkSystem);
    my %vswitchnics;

    print("$target_host: Configure Network\n") if $verbose;

    my @pnics = ();

    foreach my $pnic (@{$host->config->network->pnic}) {
	my $device = $pnic->device;
	my $vs;
	$vs = $nicAssignments{$device};
	$vs = $nicAssignments{default} if !defined($vs);
	if (!defined $vs) {
	    print "$target_host: pNIC '$device' not assigned to a defined vswitch\n";
	    next;
	}
	if (!defined $vswitches{$vs}) {
	    print "$target_host: pNIC '$device' assigned to undefined switch $vs\n";
	    next;
	}
	
	print("$target_host: Add " . $device . " to $vs\n") if $verbose;
	push @{$vswitchnics{$vs}}, $device;
    }

    foreach my $vs(keys %vswitches) {
	if($vs eq 'vSwitch0') {
	    my $bridge = HostVirtualSwitchBondBridge->new( nicDevice => [ @{$vswitchnics{vSwitch0}} ] );
	    my $hvsSpec = HostVirtualSwitchSpec->new(
		numPorts => $vswitches{vSwitch0}{numPorts},
		bridge => $bridge);
	    print("$target_host: UpdateVirtualSwitch vSwitch0\n") if $verbose;
	    eval { $netMgr->UpdateVirtualSwitch(vswitchName => $vs, spec => $hvsSpec); };
	    next;
	}

	
	my $vswSpec;
	if ($#{$vswitchnics{$vs}} == -1) {
	    my $vswBridge = undef;
	    eval { $netMgr->AddVirtualSwitch(vswitchName => $vs); };
	} else {
	    my $vswBridge = HostVirtualSwitchBondBridge->new(nicDevice => [ @{$vswitchnics{$vs}} ] );
	    $vswSpec = HostVirtualSwitchSpec->new(
		numPorts => $vswitches{$vs}{numPorts}, 
		bridge => $vswBridge);
	    eval { $netMgr->AddVirtualSwitch(vswitchName => $vs, spec => $vswSpec); };
	}
	if ($@) {
	    warn("$target_host: AddVirtualSwitch $vs: " . $@ . "\n");
	    print Dumper($vswSpec) . "\n";
	}
    }

    foreach my $pg(keys %portgroups) {
	my $vs = $portgroups{$pg}{vSwitch};
	if (!defined($vswitches{$vs}{name})) {
	    print("$target_host: PortGroup $pg not assigned to a Virtual Switch\n");
	    next;
	}

	my $pgPolicy = HostNetworkPolicy->new();
	my $pgSpec = HostPortGroupSpec->new(
	    name => $portgroups{$pg}{name},
	    policy => $pgPolicy,
	    vlanId => 0,
	    vswitchName => $vs,
	    );
	print("$target_host: AddPortGroup " . $portgroups{$pg}{name} . " to $vs\n") if $verbose;
	eval { $netMgr->AddPortGroup(portgrp => $pgSpec); };
	warn ("$target_host: AddPortGroup " . $portgroups{$pg}{name} . " to $vs: " . $@ . "\n") if ($@);
    }
}

sub configureVMotion() {
    my ($target_host, $hr) = (@_);
    my $host = Vim::get_view(mo_ref => $hr);
    my $option;
    my $enabled = 0;

    my $optionSystemMgr = Vim::get_view(mo_ref => $host->configManager->advancedOption);
    eval { $option = $optionSystemMgr->QueryOptions(name => 'Migrate.Enabled'); };
    warn("$target_host: Find Migrate.Enabled: " . $@ . "\n") if ($@);
    
    if (${$option}[0]->value == 0) {
	print("$target_host: Set Migrate.Enabled\n") if $verbose;
	$option = OptionValue->new(key => 'Migrate.Enabled', value => PrimType->new(1, 'int'));
	eval { $optionSystemMgr->UpdateOptions(changedValue => [ $option ]); };
	warn("$target_host: EnableMigration: " . $@ . "\n") if ($@);
    }

    my $vmotionConfigMgr = Vim::get_view(mo_ref => $host->configManager->vmotionSystem);
    print("$target_host: Enable vmotion on $vmotionNic\n") if $verbose;
    eval { $vmotionConfigMgr->SelectVnic(device => $vmotionNic); };
    warn("$target_host: Select $vmotionNic for VMotion: " . $@ . "\n") if ($@);
}

sub configureNTP() {
    my ($target_host, $hr) = (@_);
    my $host = Vim::get_view(mo_ref => $hr);

    my $dtSys = Vim::get_view(mo_ref => $host->configManager->dateTimeSystem);

    my $ntpCfg = HostNtpConfig->new(server => [ @ntpHosts ]);
    my $timeCfg = HostDateTimeConfig->new(ntpConfig => $ntpCfg,
					  timeZone => "UTC");
    eval { $dtSys->UpdateDateTimeConfig(config => $timeCfg); } ;
    warn("$target_host: UpdateDateTimeConfig: " . $@ . "\n") if ($@);

    my $svcSys = Vim::get_view(mo_ref => $host->configManager->serviceSystem);
    eval { $svcSys->StartService(id => "ntpd"); } ;
    warn("$target_host: StartService(ntp): " . $@ . "\n") if ($@);
}

sub setPassword() {
    my ($target_host, $hr) = (@_);
    my $newpw = Opts::get_option('target_newpassword');
    return if (!defined $newpw);

    my $si_moref = ManagedObjectReference->new(type => 'ServiceInstance',
					       value => 'ServiceInstance');
    my $si_view = Vim::get_view(mo_ref => $si_moref);
    my $sc_view = $si_view->RetrieveServiceContent();
#print Dumper($sc_view);
    if (!defined($sc_view->accountManager)) {
	warn("target_host: Account Manager undefined, can't set password\n");
	return;
    }
    my $am_view = Vim::get_view (mo_ref =>$sc_view->accountManager);

    my $haSpec = HostAccountSpec->new(id => "root", password => $newpw);

    print("$target_host: UpdateUser\n") if $verbose;
#print Dumper($am_view);
    eval { $am_view->UpdateUser(user => $haSpec); };
    warn("$target_host: UpdateUser: " . $@ . "\n") if ($@);
}

sub esx_destroy() {
    my ($target_host) = @_;

    do {
	my $hlist = Vim::find_entity_views(view_type => 'HostSystem',
					   filter => {name=> $target_host});
	unless (@$hlist) {
	    print "$target_host: Destroy: Host not found \n" if $verbose;
	    return 0;
	}
	my $host = shift @$hlist;

	my $pState = ${$host->summary->runtime->powerState}{val}; # "poweredOn"
	my $cState = ${$host->summary->runtime->connectionState}{val};

	print("$target_host: Destroy power: '$pState' connection: '$cState'\n")  if $verbose;

	if ($cState eq 'notResponding') {
	    print "$target_host: DisconnectHost\n" if $verbose;
	    eval{ $host->DisconnectHost(); };
	    if ($@) {
		warn("$target_host: Disconnect: " . $@ . "\n");
		my $vcErr = ref($@);
		print("$target_host: DisconnectHost fault '" . $vcErr . "'\n");
		if ($vcErr eq 'SoapFault') {
		    next;
		}
	    }
	}
	
	$hlist = Vim::find_entity_views(view_type => 'HostSystem',
					filter => {name=> $target_host});
	unless (@$hlist) {
	    print "$target_host: Not found after DisconnectHost\n" if $verbose;
	    return 0;
	}
	$host = shift @$hlist;
	
	print("$target_host: Destroy\n") if $verbose;
	eval{ $host->Destroy(); };
	warn("$target_host: Destroy: " . $@ . "\n") if ($@);
	return $@ ? 1 : 0;
    }
}

sub esx_cleanup() {
    my ($target_host) = @_;
    my $hlist = Vim::find_entity_views(view_type => 'HostSystem',
				       filter => {name=> $target_host});
    unless (@$hlist) {
	print "$target_host: Host not found \n" if $verbose;
	return;
    }

    my $host = shift @$hlist;

    my $pState = ${$host->summary->runtime->powerState}{val}; # "poweredOn"
    my $cState = ${$host->summary->runtime->connectionState}{val};

    print("$target_host: Disconnect power: '$pState' connection: '$cState'\n")  if $verbose;
    if ($cState eq "notResponding") {
	return if !&esx_destroy($target_host);
    }

    print("$target_host: Reconnect power: '$pState' connection: '$cState'\n")  if $verbose;
    if ($cState ne "connected") {
	my $hcSpec = HostConnectSpec->new(force => (1||1),
					  hostName => $target_host,
					  userName => $target_username,
					  password => $target_password,
	    );
#    print ("Host '$target_host', User '$target_username', Pass '$target_password'\n");
	eval { $host->ReconnectHost(cnxSpec => $hcSpec); };
	if ($@) {
	    warn("$target_host: Reconnect: "  . $@ . "\n");
	    return;
	}
	$hlist = Vim::find_entity_views(view_type => 'HostSystem',
					filter => {name=> $target_host});
	unless (@$hlist) {
	    print "$target_host: Not found after ReconnectHost\n" if $verbose;
	    return;
	}
	$host = shift @$hlist;
    }

    print("$target_host: Enter Maintenance Mode\n") if $verbose;
    eval{ $host->EnterMaintenanceMode(timeout => 0, evacuatePoweredOffVms => (0||0)); };
    if ($@) {
	my $vcErr = ref($@);
	if ($vcErr eq 'SoapFault') {
	    print("$target_host: EnterMaintenanceMode SoapFault, attempt destroy\n");
	    return if !&esx_destroy($target_host);
	} else {
	    warn("$target_host: EnterMaintenanceMode: " . $@ ."\n");
	}
    }

    my $configMgr = $host->configManager;
    if (defined $host->datastore) {
	my $dsSystem = Vim::get_view(mo_ref => $configMgr->datastoreSystem);
	foreach my $ds (@{$host->datastore}) {
	    my $dsView = Vim::get_view(mo_ref => $ds);
	    my $dsName = $dsView->info->name;

	    print("$target_host: Remove datastore " . $dsName . "\n") if $verbose;
	    eval { $dsSystem->RemoveDatastore(datastore => $ds); };
	    if ($@) {
		my $vcErr = ref($@);
		if ($vcErr eq 'SoapFault') {
		    print("$target_host: RemoveDatastore SoapFault, attempt destroy\n");
		    return if !&esx_destroy($target_host);
		} else {
		    warn("$target_host: RemoveDatastore: "  . $dsName . ": " . $@ . "\n");
		}
	    }
	}
    }

    if (defined $host->network) {
	my $netSys = Vim::get_view(mo_ref => $configMgr->networkSystem);
	foreach my $vswitch (@{$host->config->network->vswitch}) {
	    next if ($vswitch->name eq 'vSwitch0');

	    print("$target_host: Remove vswitch " . $vswitch->name . "\n") if $verbose;
	    eval { $netSys->RemoveVirtualSwitch(vswitchName => $vswitch->name); };
	    if ($@) {
		my $vcErr = ref($@);
		if ($vcErr eq 'SoapFault') {
		    print("$target_host: RemoveVirtualSwitch SoapFault, attempt destroy\n");
		    return if !&esx_destroy($target_host);
		} else {
		    warn("$target_host: Remove vswitch: " . $vswitch->name . ": " . $@ ."\n");
		}
	    }
	}
    }

    print("$target_host: Destroy\n") if $verbose;
    eval{ $host->Destroy(); };
    warn("$target_host: Destroy: " . $@ . "\n") if ($@);
}

sub validate {
    return 1;
}

sub do_host() {
    my ($target_host) = @_;

    Util::connect();
    &esx_cleanup($target_host);
    return if (Opts::get_option('destroy'));
    my $hr = &esx_add($target_host);
    if (defined $hr) {
	&configureNetworking($target_host, $hr);
	# For some reason NAS sometimes fails the first time with an authentication error
	if (&configureStorage($target_host, $hr)) {
	    print("$target_host: Retry Configure Storage\n") if $verbose;
	    &configureStorage($target_host, $hr);
	}
	&configureNTP($target_host, $hr);
	&configureVMotion($target_host, $hr);
	&exitMaintenanceMode($target_host, $hr);
    }
    Util::disconnect();

# Setting the password can only be done by direct connection, not through VC
#    &setPassword($target_host, $hr);

    print("$target_host: Configuration Complete\n");
}

sub windowsExec() {
    my ($target_host) = @_;
    use Win32::Process;
    use Win32;
    my $p;

    my $cf = Opts::get_option('config');
    if (!Win32::Process::Create($p,
				'C:\Program Files\VMware\VMware VI Perl Toolkit\Perl\bin\perl.exe',
				"perl $program --config $cf --target_host $target_host",
				0,
				NORMAL_PRIORITY_CLASS,
				".")) {
	print Win32::FormatMessage(Win32::GetLastError());
    } else {
	$p->Wait(INFINITE);
    }
}

sub server() {
    my $port = 3333;
    my $proto = getprotobyname('tcp');
    my ($ssock, $csock);
    
    ($port) = $port =~ /^(\d+)$/                        or die "invalid port";

    socket($ssock, PF_INET, SOCK_STREAM, $proto)	|| die "socket: $!";
    setsockopt($ssock, SOL_SOCKET, SO_REUSEADDR,
	       pack("l", 1)) 	|| die "setsockopt: $!";
    bind($ssock, sockaddr_in($port, INADDR_ANY))	|| die "bind: $!";
    listen($ssock, SOMAXCONN) 				|| die "listen: $!";
    
    print("Service started on port $port\n");

    while (1) {
	my $paddr = accept($csock, $ssock) || do {
	    # try again if accept() returned because a signal was received
	    next if $!{EINTR};
	    die "accept: $!";
	};
	my ($port, $iaddr) = sockaddr_in($paddr);
	close $csock;

	my $name = gethostbyaddr($iaddr, AF_INET);
	$name = "(unknown)" if (!defined $name);
	my $target_host = inet_ntoa($iaddr);

	print($target_host . ":$port: Initialize $name\n");

	my $thr = threads->create(\&windowsExec, $target_host);
	$thr->detach();
    }
    warn("Parent exited\n");
}

if (Opts::get_option('service')) {
    &server();
} else {
    my $target_host = Opts::get_option('target_host');
    &do_host($target_host);
}
