# List snapshots for all VMs
 
Connect-VIServer MYVISERVER
 
Get-VM | Get-Snapshot 