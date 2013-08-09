# Create a new snapshot on all VMs

Connect-VIServer MYVISERVER
 
New-Snapshot -Name "All Machine Snapshot taken today" -VM (Get-VM) 
