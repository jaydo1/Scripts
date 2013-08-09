param (
	$Region = "atl",
	$Department = "fin",
	$Role = "web",
	$Ordinal = "01",
	$Domain = "halr9000.com",
	$VMHost
)
# Select build attributes based on role
switch ( $Role ) {
	"web"	{ $DiskMB = ( 8GB / 1MB ), $MemoryMB = ( 0.75GB / 1MB ), $NumCpu = 1 }
	"db"	{ $DiskMB = ( 16GB / 1MB ), $MemoryMB = ( 1.5GB / 1MB ), $NumCpu = 2 }
}

$VMNames = Get-VM | Select-Object Name # build catalog of existing VMs
$VMName = "$Region-$Department-$Role$Ordinal.$Domain"
# need to generate unique name