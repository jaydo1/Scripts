#Create and configure our new vDS
$vDS = Get-Datacenter -name �ATL-PROD�| 
    New-DistributedSwitch -Name 'vDS01' `
        -NumberOfUplinks 6 |
        Set-DistributedSwitch -LinkDiscoveryProtocol 'cdp' `
            -LinkDiscoveryOperation 'both' `
            -ContactName 'Glenn Sizemore' `
            -ContactInfo 'Glenn.Sizemore@mailinator.com' `
            -Description 'Atlanta Datacenter Production vSwitch'
# a regulare DVPG
$vDS | New-DistributedSwitchPortGroup -Name 'vDS01-VLAN22' `
		-VLAN 22 |
    Set-DistributedSwitchPortGroup -NumberOfPorts 256 `
        -PromiscuousMode $false `
        -MacAddressChanges $False `
        -ForgedTransmits $false `
        -LoadBalancing 'loadbalance_loadbased' `
        -ActiveDVUplinks DVUplink2,DVUplink3,DVUplink5,DVUplink6
# Trunked DVPG
$vDS | New-DistributedSwitchPortGroup -Name 'vDS01-Trunk01' `
    -VLANTrunkRange '7,19,25-28' |
    Set-DistributedSwitchPortGroup -NumberOfPorts 128 `
        -LoadBalancing 'loadbalance_loadbased' `
        -ActiveDVUplinks DVUplink2,DVUplink3,DVUplink5,DVUplink6
# Private VLAN
$vDS | New-DistributedSwitchPrivateVLAN -PrimaryVLanID 108 |
    New-DistributedSwitchPortGroup -Name 'vDS01-10.10.10.0' `
		-PrivateVLAN 108|
    Set-DistributedSwitchPortGroup -NumberOfPorts 128 `
        -ActiveDVUplinks DVUplink1,DVUplink4