# The following example can be used to set the Port Group ID to 
# 13 on the Port Group PG1: 
 
Connect-VIServer MYVISERVER

Get-VirtualSwitch -VMHost (Get-VMHost -Name "MyESXHost.mydomain.com") -Name vSwitch2 | Get-VirtualPortGroup -Name PG1 | Set-VirtualPortGroup -VLanId 13 