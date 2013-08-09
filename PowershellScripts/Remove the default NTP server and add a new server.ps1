# The following shows how PowerCLI can be used to remove the 
# default ntp server and add your own: 

Connect-VIServer MYVISERVER

$VMHost = "MyESXHost.mydomain.com" 
$NTPServer = "ntp.mydomain.com" 
Remove-VMHostNtpServer -VMHost $VMHost -NtpServer '127.127.1.0' 
Add-VMHostNtpServer -VMHost $VMHost -NtpServer $NTPServer 
 
Get-VmHostService -VMHost $VMHost | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService 
Get-VmhostFirewallException -VMHost $VMHost -Name "NTP Client" | Set-VMHostFirewallException -enabled:$true 