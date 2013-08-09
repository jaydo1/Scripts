# Adds a new vSwitch named vSwitch02 to the host named ‘MyESXHost.mydomain.com’ 
 
Connect-VIServer MYVISERVER

New-VirtualSwitch -VMHost (Get-VMHost -Name "MyESXHost.mydomain.com") -Name vSwitch02 