# The following example shows how to alter all VMs to perform a 
# guest shutdown when the host is being shutdown

Connect-VIServer MYVISERVER
 
Get-VM | Get-VMStartPolicy | Set-VMStartPolicy –StopAction GuestShutdown 