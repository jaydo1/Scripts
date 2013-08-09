# Remove all snapshots on the VM called PROD1

Connect-VIServer MYVISERVER
 
Get-VM "PROD1" | Remove-Snapshot -confirm:$False 
