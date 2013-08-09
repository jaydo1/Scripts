

$vCenter = Read-Host "Enter vCenter name"
$cluster = Read-Host "Enter cluster name"
$vSwitch = Read-host "Enter vSwitch name"
$NewPortGroup = Read-host "Enter new port group name"
$VLAN = Read-Host "Enter New VLAN ID"

foreach ($esx in get-VMhost -Location $cluster | sort Name) {$esx | Get-VirtualSwitch -Name $vSwitch | New-VirtualPortGroup -Name $NewPortGroup -VlanId $VLAN}