# Adds a new local user on ESX host ESXSRV1
 
Connect-VIServer ESXSRV1 

New-VMHostAccount -ID User1 -Password pass –UserAccount 