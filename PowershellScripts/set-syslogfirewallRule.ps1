$cluster = Read-host "enter cluster name"


$VMhosts = Get-VMHost -location (Get-Cluster $cluster) 

foreach-object ($host in $VMhosts) {$host | Get-VMHostFirewallException |?{$_.Name -eq 'syslog'} | Set-VMHostFirewallException -Enabled:$true}