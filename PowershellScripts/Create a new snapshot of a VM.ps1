# Create a new snapshot on a VM Called PROD1

Connect-VIServer MYVISERVER
 
New-Snapshot -Name "General Snapshot" -VM (Get-VM "PROD1")