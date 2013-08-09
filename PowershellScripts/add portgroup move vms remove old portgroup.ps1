<#
Summary
Add new portgroup to switch 
move vm's to new portgroups 
remove old portgroup from vSwitch 
#>

$vCenter = Read-Host "Enter vCenter name"
$cluster = Read-Host "Enter cluster name"
$vSwitch = Read-host "Enter vSwitch name"
$NewPortGroup = Read-host "Enter new port group name"
$VLAN = Read-Host "Enter New VLAN ID"
$OldPortGroup = Read-host "Enter old port group name"  

Connect-VIServer $vCenter

foreach ($esx in get-VMhost -Location $cluster | sort Name) {$esx | Get-VirtualSwitch -Name $vSwitch | New-VirtualPortGroup -Name $NewPortGroup -VlanId $VLAN}

Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $OldPortGroup} | Set-NetworkAdapter -NetworkName $NewPortGroup -Confirm:$false  

Get-VirtualPortGroup -VMHost $esx -name $OldPortGroup | Remove-VirtualPortGroup -confirm:$True 
