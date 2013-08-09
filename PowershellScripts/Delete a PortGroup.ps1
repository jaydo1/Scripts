# The following example can be used to delete the Port Group named PG1

Connect-VIServer MYVISERVER
 
Get-VirtualSwitch -VMHost (Get-VMHost -Name "MyESXHost.mydomain.com") -Name vSwitch2 | Get-VirtualPortGroup -Name PG1 | Remove-VirtualPortGroup 