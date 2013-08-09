# Revert the VM called PROD1 to a snapshot which is called “First Snapshot”

Connect-VIServer MYVISERVER
 
$VM = Get-VM -Name "PROD1" 
$SnapshotName = $VM | Get-Snapshot -Name "First Snapshot"   
$SnapshotName | Where-Object { $_.name -like $SnapshotName.name } | ForEach-Object { Set-VM $VM -snapshot $SnapshotName } 