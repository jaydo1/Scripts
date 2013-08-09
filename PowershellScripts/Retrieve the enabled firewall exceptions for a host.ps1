# Retrieves the enabled firewall exceptions of the ESX host with a name of ESXSRV1: 
 
Connect-VIServer VISRV

Get-VMHostFirewallException -VMHost (Get-VMHost -Name ESXSRV1) -Enabled $true | Format-List 
 
New-VMHostAccount -ID User1 -Password pass –UserAccount 
 
