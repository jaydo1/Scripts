# Adds nic3 to the existing vSwitch "vSwitch2"
 
Connect-VIServer MYVISERVER

Get-VirtualSwitch -VMHost (Get-VMHost -Name "MyESXHost.mydomain.com") -Name "vSwitch2" | Set-VirtualSwitch -Nic "vmnic3" 