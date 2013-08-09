# Retrieves the default firewall policy of the ESX host with an name of ESXSRV1
 
Connect-VIServer VISRV 

Get-VMHostFirewallDefaultPolicy -VMHost (Get-VMHost -Name ESXSRV1) 
 
