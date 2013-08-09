Connect-VIServer upvvcs001


$cluster = Read-Host "Enter cluster name"
$vmhosts = Get-Cluster $cluster | get-vmhost
foreach($vmhost in $vmhosts){
Set-VMHostSysLogServer -SysLogServerPort 514 -SysLogServer 192.168.78.77 -VMHost $host.name
$syslog = Get-VMHostFirewallException -name ‘syslog’ -vmhost $host.name
$syslog | Set-VMHostFirewallException -Enabled:$true
}
