# Enables a firewall exception for the NTP Client on ESXSRV1
 
Connect-VIServer VISRV 

Get-VmhostFirewallException -VMHost ESXSRV1 -Name "NTP Client" | Set-VMHostFirewallException -enabled:$true 