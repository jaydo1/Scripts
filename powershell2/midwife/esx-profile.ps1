# Where the new host will be placed in VC
$cluster = "cluster-sf"

$vswitches = @{}
$vswitches.vSwitch0 = @{ numports = 32 }
$vswitches.vSwitch1 = @{ numports = 32 }

# This program can't reconfigure vmnic0 since it assumes that we're
# currently using it
$nicAssignments = @{}
$nicAssignments.vmnic0 = "vSwitch0"
$nicAssignments.vmnic1 = "vSwitch1"
$nicAssignments.default = "vSwitch1"

# The built-in port groups "VM Network" and "Management Network" are undisturbed
$portgroups = @{}
$portgroups.Production = @{ vSwitch = "vSwitch0" }
$portgroups.Local = @{ vSwitch = "vSwitch1" }

$nas = @()
$nas += @{ ds = 'vms'; host = "10.17.145.5"; path = "/vms"; mode = "readWrite" }
$nas += @{ ds = 'iso'; host = "10.17.145.5"; path = "/iso"; mode = "readOnly" }

# PXE booting currently changes the iSCSI SW initiator IQN every reboot
# so this won't work if LUN access is granted via the IQN
# The iSCSI code is only partially tested
$iSCSI = @()
$iSCSI += @{ addr = "10.17.246.171"; port = 3260 }
$iSCSI += @{ addr = "10.17.246.172"; port = 3260 }

$ntpServers = @( "10.17.148.1", "10.17.148.2" )

$vmotionNIC = "vmk0"

