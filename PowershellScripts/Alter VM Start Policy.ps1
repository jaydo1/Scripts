# The following example shows how to alter all VMs to start with 
# their ESX Host

Connect-VIServer MYVISERVER
 
Get-VM | Get-VMStartPolicy | Set-VMStartPolicy –StartAction PowerOn 