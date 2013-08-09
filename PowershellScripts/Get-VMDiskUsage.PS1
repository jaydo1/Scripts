## TITLE: Get-VMDiskUsage
## DESCRIPTION: Retrieves disk size and free space for virtual machines.  
##   VM Tools must be in "green" state.

Begin {
	# This hides the errors which appear if the VM Tools are not running
	$ErrorActionPreference = "SilentlyContinue"
	$VMNameExp = @{
		Name	= "Name"
		Expr	= { $VMName }
	}
	$CapacityExp = @{
		Name	= "CapacityMB"
		Expr	= { "{0:n2}" -f ( $_.Capacity / 1MB ) }
	}
	$FreeSpaceExp = @{
		Name	= "FreeSpaceMB"
		Expr	= { "{0:n2}" -f ( $_.FreeSpace / 1MB ) }
	}
	$UsageExp = @{
		Name	= "Usage %"
		Expr	= { "{0:p2}" -f ( $_.FreeSpace / $_.Capacity ) }
	}
}
Process {
	if ( $_.GetType().Name -ne 'VirtualMachineImpl' ) {
		Throw "This script expects a VirtualMachineImpl object as input."
	}
	$VMName = $_.Name
	$_ | Get-VMGuest | Select-Object -ExpandProperty Disks | 
		Select-Object $VMNameExp, $CapacityExp, $FreeSpaceExp, $UsageExp
}