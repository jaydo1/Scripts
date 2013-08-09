# Adds a new VMotion portgroup to newESXhost.mydomain.com 

Connect-VIServer MYVISERVER

$NewSwitch = New-VirtualSwitch -VMHost "MyESXHost.mydomain.com" -Name "vSwitch1" -Nic vmnic1 
New-VirtualPortGroup -Name vmkernel -VirtualSwitch $NewSwitch 
New-VMHostNetworkAdapter -VMHost "MyESXHost.mydomain.com" -PortGroup vmkernel -VirtualSwitch $NewSwitch -IP "192.168.0.10" -SubnetMask "255.255.255.0" -VMotionEnabled $true 