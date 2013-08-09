# Shutdown all ESX Hosts: 

Connect-VIServer MYVISERVER
 
Get-VMHost | ForEach-Object {Get-View $_.ID} | ForEach-object {$_.ShutdownHost_Task($TRUE)}