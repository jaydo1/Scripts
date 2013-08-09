# Sets the password for the Root user account on ESX host ESXSRV1: 
 
Connect-VIServer ESXSRV1 

Set-VMHostAccount -UserAccount Root -Password NewPass123 