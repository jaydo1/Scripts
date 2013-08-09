param ( $CsvFile )
$worksheet = Import-Csv $CsvFile
ForEach-Object {
	New-VM -VMHost $_.VMHost `
		-Name $_.Name `
		-DiskMB $_.DiskMB `
		-MemoryMB $_.MemoryMB `
		-CD:$FALSE `
		-ResourcePool $_.ResourcePool `
		-NumCPU $_.NumCPU
}