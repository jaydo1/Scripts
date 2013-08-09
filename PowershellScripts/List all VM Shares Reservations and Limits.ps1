# List all Shares, Reservations and Limits for each VM. 

Connect-VIServer MYVISERVER
 
Get-VM | Get-VMResourceConfiguration