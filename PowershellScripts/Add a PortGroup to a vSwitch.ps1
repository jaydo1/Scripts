# List all Shares, Reservations and Limits for each VM. 

Connect-VIServer MYVISERVER
 
Get-VirtualSwitch -VMHost (Get-VMHost -Name "MyESXHost.mydomain.com") -Name vSwitch2 | New-VirtualPortGroup -Name PG1 