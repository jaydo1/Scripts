# Set the Memory Limit to Unlimited for each VM which has a 
# memory limit currently not set to Unlimited. 

Connect-VIServer MYVISERVER
 
Get-VM | Get-VMResourceConfiguration | Where-Object {$_.MemLimitMB -ne '-1'} | Set-VMResourceConfiguration -MemLimitMB $null 