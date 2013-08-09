Begin {
	# Collection of property names for custom object
	$PropertyCol = @( 
		"Name", "IP Address", "OS", "Host", "CPU (Count)", "Memory (MB)", 
		"Hard Drive (Count)", "HD Capacity (Total KB)", "Floppy Drive (Count)", 
		"CD Drive (Count)", "NIC (Count)", "NIC1 MAC Address", "NIC1 Net Name"
	)
}

Process {
	if ( $_ -isnot [VMware.VimAutomation.Client20.VirtualMachineImpl] ) { continue }
	$process = "" | Select-Object -Property $PropertyCol
	$process.Name = $_.Name
	$process."IP Address" = $_.Guest.IPAddress[0]
	$process.OS = $_.Guest.OSFullName
	$process.Host = $_.Host.Name
	$process."CPU (Count)" = $_.NumCpu
	$process."Memory (MB)" = $_.MemoryMB
	$process."Hard Drive (Count)" = $_.HardDisks.Length
	$process."HD Capacity (Total KB)" = `
		( $_.HardDisks | Measure-Object -Sum CapacityKB ).Sum
	$process."Floppy Drive (Count)" = $_.FloppyDrives.Length
	$process."CD Drive (Count)" = $_.CDDrives.Length
	$process."NIC (Count)" = $_.NetworkAdapters.Length
	$process."NIC1 MAC Address" = $_.NetworkAdapters[0].MacAddress
	$process."NIC1 Net Name" = $_.NetworkAdapters[0].NetworkName
	Write-Output $process
}