#!/usr/bin/perl -w

use strict;
use warnings;
use Socket;
use threads;
use Data::Dumper;

sub windowsExec() {
    my ($target_host) = @_;
    use Win32::Process;
    use Win32;
    my ($sl) = ("PowerShell");
    my ($p, $prog, $args);

    my %run = (
	"Perl" => {
	    prog => 'C:\Program Files\VMware\VMware VI Perl Toolkit\Perl\bin\perl.exe',
	    args => "perl esxconf.pl --config esxconf --target_host $target_host" },
	"PowerShell" => {
	    prog => 'C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe',
	    args => "powershell .\\esx-autoconfig.ps1 $target_host" },
    );

    $sl = "Perl" if (($#ARGV > -1) && ($ARGV[0] eq "-perl"));

    print "Calling $run{$sl}{prog} with $run{$sl}{args}\n";

    if (!Win32::Process::Create($p, $run{$sl}{prog}, $run{$sl}{args}, 0, NORMAL_PRIORITY_CLASS, ".")) {
	print Win32::FormatMessage(Win32::GetLastError());
    } else {
	$p->Wait(INFINITE);
    }
}

my $port = 3333;
my $proto = getprotobyname('tcp');
my ($ssock, $csock);
    
socket($ssock, PF_INET, SOCK_STREAM, $proto)	|| die "socket: $!";
setsockopt($ssock, SOL_SOCKET, SO_REUSEADDR,
	   pack("l", 1)) 			|| die "setsockopt: $!";
bind($ssock, sockaddr_in($port, INADDR_ANY))	|| die "bind: $!";
listen($ssock, SOMAXCONN) 			|| die "listen: $!";
    
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
