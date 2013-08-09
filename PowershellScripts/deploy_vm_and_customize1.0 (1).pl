#!/usr/bin/perl -w
##################################################################
# Author: Harald Jensas
# 19/04/2011
# harald_jensas@dell.com
#
##################################################################
#	Change Log
##################################################################
# 19/04/2011 - Initial Release 1.0 	Harald Jensås 
# 					(harald_jensas@dell.com)
#
#
#
##################################################################

use strict;
use warnings;
use POSIX qw(ceil floor);
use VMware::VIRuntime;
#use VMware::VIFPLib;
use VMware::VIM25Stub;
use VMware::VIM2Runtime;

#################################################
# Defaults
#################################################
my $guestid = "windows7Server64Guest"; 
my $timezone = 110; 	
my $cpus = 2;
my $memory = 1024;
#################################################

my %opts = (
	vmhost => {
	type => "=s",
	help => "ESX Host in cluster to deploy VM to",
	required => 1,
	},
        sourcevm => {
        type => "=s",
        help => "Name of VM Template (source VM)",
        required => 1,
        },
        vmname => {
        type => "=s",
        help => "Hostname to set for the new VM",
        required => 1,
        },
        resourcepool => {
        type => "=s",
        help => "Name of ResourcePool in vCenter",
        required => 0,
        },
        datastore => {
        type => "=s",
        help => "Name of Datastore in vCenter",
        required => 0,
        },
	memory => {
        type => "=s",
        help => "Amount of Memory (RAM) on the new VM",
        required => 0,
	default => $memory,
        },
        cpus => {
        type => "=s",
        help => "Number of CPUs on the new VM",
        required => 0,
	default => $cpus,
        },
        domain => {
        type => "=s",
        help => "Windows Domain to join",
        required => 1,
        },
	localadminpwd => {
        type => "=s",
        help => "Local Administrator Password, (Sets \"AutoLogon Enabled\" and \"AutoLogonCount = 1\", unless AutoLogonCount greater than 1)",
        required => 0,
        },
	domainuser => {
        type => "=s",
        help => "Username of user with permissions to join VM to domain",
        required => 1,
        },
        domainuserpassword => {
        type => "=s",
        help => "Password for Domain user",
        required => 1,
        },
        ipaddress => {
        type => "=s",
        help => "IP address to apply to the VM, Comma seperated list, Example: 10.10.10.10,192.168.10.10",
        required => 1,
        },
	netmask => {
	type => "=s",
	help => "Subnet Mask to apply to VM, Comma seperated list, Example: 255.255.0.0,255.255.255.0",
	required => 1,
	},
	gateway => {
	type => "=s",
        help => "Default gateway to apply to VM",
        required => 1,
	},
	dnsdomain => {
        type => "=s",
        help => "A DNS domain suffix such as dell.com.",
        required => 1,
        },
	dnsservers => {
        type => "=s",
        help => "(DNS - Domain Name Servers) Comma seperated list, 10.10.10.10,10.10.10.11",
        required => 1,
        },
        winsservers => {
        type => "=s",
        help => "(WINS - Windows Internet Name Servers) Comma seperated list, 10.10.10.10,10.10.10.11",
        required => 0,
        },
	guestid => {
	type => "=s",
        help => "Guest Operating System 
		http://www.vmware.com/support/developer/windowstoolkit/wintk40u1/html/New-VM.html",
        required => 0,
        default => $guestid,
        },
        plaintextpassword => {
        type => "",
        help => "Use Plaintext passwords", 
        },
        autologon => {
        type => "",
        help => "Enables Autologon", 
        },
       	autologoncount => {
        type => "=s",
        help => "AutoLogonCount, How many times system will AutoLogon",
        required => 0,
        default => 1,
        },
	timezone => {
        type => "=s",
        help => "Timezone, 	For Windows use Time Zone Index Values for Windows (Index value for Stockholm is 110)
			For Linux use tz (timezone) database valuse such as Europe/Stockholm",
        required => 0,
        default => $timezone,
        },
        fullname => {
        type => "=s",
        help => "Name of owner",
        required => 0,
        },
        orgname => {
        type => "=s",
        help => "Name of Organisation",
        required => 0,
        },
        productkey => {
        type => "=s",
        help => "Windows Product/Licenwse Key",
        required => 0,
        },
	licensemode => {
        type => "=s",
        help => "perSeat or perServer ",
        required => 0,
        },
	licenses => {
        type => "=s",
        help => "Valid only if perServer is licensemode, number of client licenses",
        required => 0,
        },
	runonce => {
	type => "=s",
        help => "A list of commands to run at first user logon, after guest customization.",
        required => 0,
        },
	annotation => {
        type => "=s",
        help => "User-provided description of the virtual machine.",
        required => 0,
        default => "",
        },
);

Opts::add_options(%opts);
Opts::parse();
Opts::set_option("passthroughauth", 1);
Opts::validate();

my $vmname = Opts::get_option('vmname');


sub deploy_template() {
	my $vmhost = Opts::get_option('vmhost');
	my $sourcevm = Opts::get_option('sourcevm');
	my $cpus = Opts::get_option('cpus');
	   $guestid = Opts::get_option('guestid');
	my $comp_res_view;
	my $resourcepool;
	my $datastore;

	if (Opts::get_option('resourcepool')) {		$resourcepool = get_resource_pool();		}
	if (Opts::get_option('datastore')) {		$datastore = Opts::get_option('datastore');	}

	# CheckCustomizationResources
	# Verify that required recources to Customize OS is available:
#	my $CheckCustomizationResources = CheckCustomizationResources->new(
#									_this => 
#									guestOS => $guestid
#									);


	my $vm_views = Vim::find_entity_views(
									view_type => 'VirtualMachine',
                                        				filter => {'name' => $sourcevm}
									);
	
	if(@$vm_views) {
		foreach (@$vm_views) {
			my %relocate_params;
			my %datastore_info;
			my $host_view;
                        if ($vmhost) {
				$host_view = Vim::find_entity_view(
                                                                        view_type => 'HostSystem',
                                                                        filter => {'name' => $vmhost}
                                                                        );

                                unless($host_view) { Util::disconnect(); die "ESX Host '$vmhost' not found\n"; }
                        }

                      
			$comp_res_view = Vim::get_view(
									mo_ref => $host_view->parent
									);

			%datastore_info = get_datastore(
									host_view => $host_view,
                		               				datastore => $datastore
									);
 
			if (not $resourcepool) { 	$resourcepool = $comp_res_view->resourcePool;	}

			%relocate_params = (				datastore => $datastore_info{mor}, 
									pool => $resourcepool
									); 

			my $relocate_spec = get_relocate_spec(%relocate_params);
			my $config_spec = get_config_spec();
			my $customization_spec = get_customization_spec();
			my $clone_spec = VirtualMachineCloneSpec->new(
								powerOn => 1,
								template => 0,
								location => $relocate_spec,
								customization => $customization_spec,
								config => $config_spec,
							);
				$Data::Dumper::Sortkeys = 1; #Sort the keys in the output
				$Data::Dumper::Deepcopy = 1; #Enable deep copies of structures
				$Data::Dumper::Indent = 1;   #Enable enough indentation to read the output
				print "Dumper VirtualMachineCloneSpec: \n";
				print Dumper ($clone_spec) . "\n";

			Util::trace (0, "\n Deploying virtual machine from template " . $sourcevm . "  ...\n");
			eval {
				$_->CloneVM(			folder => $_->parent,
								name => $vmname,
								spec => $clone_spec
								);
				Util::trace (0, "\n'$vmname' based on template '$sourcevm' successfully deployed.");
			};
#########################################################################
if ($@) {
if (ref($@) eq 'SoapFault') {
if (ref($@->detail) eq 'FileFault') { Util::trace(0, "\nFailed to access the virtual machine files.\n");
} elsif (ref($@->detail) eq 'InvalidState') { Util::trace(0,"The operation is not allowed in the current state.\n");
} elsif (ref($@->detail) eq 'NotSupported') { Util::trace(0," Operation is not supported by the current agent. \n");
} elsif (ref($@->detail) eq 'VmConfigFault') { Util::trace(0,"Virtual machine is not compatible with the destination host.\n");
} elsif (ref($@->detail) eq 'InvalidPowerState') { Util::trace(0,"The attempted operation cannot be performed in the current state.\n");
} elsif (ref($@->detail) eq 'DuplicateName') { Util::trace(0,"The name '$vmname' already exists.\n");
} elsif (ref($@->detail) eq 'NoDisksToCustomize') { Util::trace(0, "\nThe virtual machine has no virtual disks that are suitable for customizationomization or no guest is present on given virtual machine.\n");
} elsif (ref($@->detail) eq 'HostNotConnected') { Util::trace(0, "\nUnable to communicate with the remote host, since it is disconnected.\n");
} elsif (ref($@->detail) eq 'UncustomizationomizableGuest') { Util::trace(0, "\nCustomization is not supported for the guest operating system.\n");
} else { Util::trace (0, "Fault" . $@ . ""   );}
} else {Util::trace (0, "Fault" . $@ . ""   );}
}
#########################################################################
		}
	} else {
		Util::trace (0, "\nNo virtual machine template found with name '$sourcevm'\n");
	}
}

sub get_customization_spec() {
	my @ipaddresses = split(',', Opts::get_option('ipaddress'));
	my @gateway = Opts::get_option('gateway');
	my @netmasks = split(',', Opts::get_option('netmask'));
	my @dnsservers = split(',', Opts::get_option('dnsservers'));
	my @winsservers =  split(',', Opts::get_option('winsservers'));
	my $dnsdomain = Opts::get_option('dnsdomain');
	my $domain = Opts::get_option('domain');
	my $localadminpwd = Opts::get_option('localadminpwd');
	my $domainuser = Opts::get_option('domainuser');
	my $domainuserpassword = Opts::get_option('domainuserpassword');
	my $plaintextpassword;
		if (Opts::get_option('plaintextpassword')) {
			$plaintextpassword = 1;
		} else {
			$plaintextpassword = 0;
		}
	my $autologon;
		if (Opts::get_option('autologon')) {
			$autologon = 1;
		} else {
			$autologon = 0;
		}		
	my $autologoncount = Opts::get_option('autologoncount');
	   $timezone = Opts::get_option('timezone');
	my $fullname = Opts::get_option('fullname');
	my $orgname = Opts::get_option('orgname');
	my $licensekey =  Opts::get_option('productkey');
	my $licensemode = Opts::get_option('licensemode');
	my $licenses = Opts::get_option('licenses');
	   $guestid = Opts::get_option('guestid');
	my @runonce;
	if (Opts::get_option('runonce')) {
		@runonce = split(',', Opts::get_option('runonce'));
	}
	
	my $customization_sysprep;
	my @ifconfig;
	my $iface_ip_settings;
	my $iface_settings;
	my $iface_fixed_ip;
	

	# Identify OS
	if (	$guestid eq 		"winVista64Guest" 		||
		$guestid eq		"winVistaGuest" 		||
		$guestid eq		"winXPHomeGuest"		||
		$guestid eq		"winXPPro64Guest" 		||
		$guestid eq		"winXPProGuest"			||
		$guestid eq		"win2000AdvServGuest" 		||
		$guestid eq		"win2000ProGuest" 		||
		$guestid eq		"win2000ServGuest"		||	
		$guestid eq		"windows7_64Guest" 		||
		$guestid eq		"windows7Guest" 		||
		$guestid eq		"windows7Server64Guest" 	||
		$guestid eq		"winLonghorn64Guest" 		||
		$guestid eq		"winLonghornGuest" 		||
		$guestid eq		"winNetBusinessGuest" 		||	
		$guestid eq		"winNetDatacenter64Guest" 	||
		$guestid eq		"winNetDatacenterGuest"		||
		$guestid eq		"winNetDatacenterGuest" 	||
		$guestid eq		"winNetDatacenterGuest" 	||
		$guestid eq		"winNetDatacenterGuest" 	||
		$guestid eq		"winNetEnterprise64Guest" 	||
		$guestid eq		"winNetEnterpriseGuest" 	||
		$guestid eq		"winNetStandard64Guest" 	||
		$guestid eq		"winNetEnterpriseGuest" 	||
		$guestid eq		"winNetStandard64Guest" 	||
		$guestid eq		"winNetStandardGuest" 		||
		$guestid eq		"winNetWebGuest" 		) {

		#########################################
		# Create Windows customizationimization #
		#########################################

		my $customization_domain_admin_pwd = CustomizationPassword->new(	
								plainText => $plaintextpassword, 
								value => $domainuserpassword
								);

		my $customization_identification = CustomizationIdentification->new(	
								domainAdmin => $domainuser,
								domainAdminPassword => $customization_domain_admin_pwd,
								joinDomain => $domain
								);

		my $customization_gui_unattended;
		my $customization_local_admin_pwd;
		if (Opts::get_option('localadminpwd')) {
			$customization_local_admin_pwd = CustomizationPassword->new(	
								plainText => $plaintextpassword, 
								value => $localadminpwd
								);
			$customization_gui_unattended = CustomizationGuiUnattended->new(	
								autoLogon => $autologon,
								autoLogonCount => $autologoncount,
								password => $customization_local_admin_pwd,
								timeZone => $timezone
								);
		} else {
			$customization_gui_unattended = CustomizationGuiUnattended->new(	
								autoLogon => $autologon,
								autoLogonCount => $autologoncount,
								timeZone => $timezone
								);
		}

		my $customization_name = CustomizationFixedName->new(	
								name => $vmname
								);

        	my $customization_user_data = CustomizationUserData->new(
								computerName => $customization_name,
								fullName => $fullname,
								orgName => $orgname,
								productId => $licensekey
								);

		my $CustomizationLicenseFilePrintData;	
		if (Opts::get_option('licensemode')) {
			my $CustomizationLicenseDataMode = CustomizationLicenseDataMode->new(
								$licensemode
								);
		
			if ($licensemode eq 'perServer') {
				if (not (Opts::get_option('licenses'))) {
					Util::disconnect(); die "When using perServer licensemode, option --licenses is required. \n";
				}
				$CustomizationLicenseFilePrintData = CustomizationLicenseFilePrintData->new(
								autoMode => $CustomizationLicenseDataMode,
								autoUsers => $licenses
								);
			} elsif ($licensemode eq 'perSeat') {
				$CustomizationLicenseFilePrintData = CustomizationLicenseFilePrintData->new(
								autoMode => $CustomizationLicenseDataMode,
								);
			} else {
				 Util::disconnect(); die "Valid licensemodes are perSeat and perServer\n";
			}
		}

		my $customization_runonce;
		if (Opts::get_option('runonce')) {
			$customization_runonce = CustomizationGuiRunOnce->new(
								commandList => \@runonce
								);
		}


		if ((Opts::get_option('runonce')) and (Opts::get_option('licensemode'))) {
	        	$customization_sysprep = CustomizationSysprep->new(	
								guiUnattended => $customization_gui_unattended,
								guiRunOnce => $customization_runonce,
								identification => $customization_identification,
								userData => $customization_user_data,
								licenseFilePrintData => $CustomizationLicenseFilePrintData
								);
		} elsif (Opts::get_option('runonce')) {
	        	$customization_sysprep = CustomizationSysprep->new(	
								guiUnattended => $customization_gui_unattended,
								guiRunOnce => $customization_runonce,
								identification => $customization_identification,
								userData => $customization_user_data
								);
		} elsif (Opts::get_option('licensemode')) {
			$customization_sysprep = CustomizationSysprep->new(	
								guiUnattended => $customization_gui_unattended,
								identification => $customization_identification,
								userData => $customization_user_data,
								licenseFilePrintData => $CustomizationLicenseFilePrintData
								);
		} else {
			$customization_sysprep = CustomizationSysprep->new(
								guiUnattended => $customization_gui_unattended,
								identification => $customization_identification,
								userData => $customization_user_data
								);

		}

	} elsif (	
		$guestid eq 		"rhel3_64Guest"		 	||
		$guestid eq 		"rhel3_64Guest"			||
		$guestid eq 		"rhel3Guest"			||
		$guestid eq 		"rhel4_64Guest"			||
		$guestid eq 		"rhel4Guest"			||
		$guestid eq 		"rhel5_64Guest"			||
		$guestid eq 		"rhel5Guest"			||
		$guestid eq 		"rhel6_64Guest"			||
		$guestid eq 		"rhel6Guest"			||
		$guestid eq 		"sles10_64Guest"		||
		$guestid eq 		"sles10Guest"			||
		$guestid eq 		"sles11_64Guest"		||
		$guestid eq 		"sles11Guest"			||
		$guestid eq 		"sles64Guest"			||
		$guestid eq 		"slesGuest"			) {

        	#######################################
        	# Create Linux customizationimization #
        	#######################################
		my $customization_name = CustomizationFixedName->new(	
								name => $vmname
								);
		my $customization_sysprep = CustomizationLinuxPrep->new(
								domain => $domain,
								hostName => $customization_name,
								timeZone => $timezone
								);
	} else {
		die "Error: Unrecognized Operating System Type.\n $guestid \n";
	}


	#######################################
	#	IP stuff		      #
	#######################################
	my $customization_global_ip_settings = CustomizationGlobalIPSettings->new(	
						);

	my $numOfipaddresses = @ipaddresses;
	my $numOfnetmasks = @netmasks;
	if (  $numOfipaddresses == $numOfnetmasks ) {
		my $counter = 0;
		while ($counter < $numOfipaddresses ) {
			$iface_fixed_ip = CustomizationFixedIp->new(
								ipAddress => $ipaddresses[$counter]
								);

			$iface_ip_settings = CustomizationIPSettings->new(
								dnsDomain => $dnsdomain,
								dnsServerList => \@dnsservers,
								ip => $iface_fixed_ip,
								gateway => \@gateway,
								primaryWINS => $winsservers[0],
								secondaryWINS => $winsservers[1],
								# netBIOS => "",								
								subnetMask => $netmasks[$counter]
								);

			$iface_settings = CustomizationAdapterMapping->new(
								adapter => $iface_ip_settings
								);

			if ($counter == 0) { 
				@ifconfig = $iface_settings; 
			} else { 
				push (@ifconfig, $iface_settings); 
			}
			$counter++;	
		}
	} else {
		die "Error: Number of ipaddresses must match number of netmasks specified. \n"
	}
	
	my $customization_spec = CustomizationSpec->new(
								# encryptionKey => "",
								identity => $customization_sysprep,
								globalIPSettings => $customization_global_ip_settings,
								nicSettingMap => \@ifconfig
								);
	return $customization_spec;
}


sub get_config_spec() {
	my $memory = Opts::get_option('memory');
	my $cpus = Opts::get_option('cpus');
	my $guestid = Opts::get_option('guestid');
	my $annotation = Opts::get_option('annotation');
	my $config_spec = VirtualMachineConfigSpec->new(
                                                  		name => $vmname,
                                                  		memoryMB => $memory,
                                                  		numCPUs => $cpus,
                                                  		guestId => $guestid,
								annotation => $annotation
								);
	return $config_spec;
}


sub get_relocate_spec() {
	my %args = @_;
	my $datastore = $args{datastore};
	my $resourcePool = $args{pool};
	my $relocate_spec = VirtualMachineRelocateSpec->new(
								datastore => $datastore,
                                                                pool => $resourcePool
								);
	

	return $relocate_spec;
}

sub get_datastore {
	my %args = @_;
	my $host_view = $args{host_view};
	my $config_datastore = $args{datastore};
	my $name;
	my $mor;

	my $ds_mor_array = $host_view->datastore;
	my $datastores = Vim::get_views(mo_ref_array => $ds_mor_array);


	my $found_datastore = 0;

	# User specified datatstore name.  It's possible no such
	# datastore exists, in which case an error is generated.
	if(defined($config_datastore)) {
		foreach (@$datastores) {
		$name = $_->summary->name;
		if($name eq $config_datastore) { # if datastore available to host
			$found_datastore = 1;
			$mor = $_->{mo_ref};
			last;
		}
	}
	}
	# No datatstore name specified.  The only only way to not find a
	# datastore in this case is if the host doesn't have any attached.
	else {
		my $disksize = 0;
		foreach (@$datastores) {
			my $ds_disksize = ($_->summary->freeSpace);
			if($ds_disksize > $disksize && $_->summary->accessible) {
				$found_datastore = 1;
				$name = $_->summary->name;
				$mor = $_->{mo_ref};
				$disksize = $ds_disksize;
			}
		}
	}

	if (!$found_datastore) {
	my $host_name = $host_view->name;
	my $datastore = "<any accessible datastore>";
	if (Opts::option_is_set('datastore')) {
		$datastore = Opts::get_option('datastore');
	}
	die "Datastore '$datastore' is not available to host $host_name\n";
	}

	return (name => $name, mor => $mor);
}

sub get_resource_pool() {
	my $resourcepool = Opts::get_option('resourcepool');
	my $resourpoolView = Vim::find_entity_view(view_type => 'ResourcePool', filter =>{ 'name'=> $resourcepool});
	unless($resourpoolView) { Util::disconnect(); die "Resource pool \"$resourcepool\" not found.\n";}
	return $resourpoolView;
}



Util::connect();

deploy_template();

Util::disconnect();

