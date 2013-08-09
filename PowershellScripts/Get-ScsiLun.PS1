filter Get-ScsiLun {
	$_ | Get-VMHostStorage | Select-Object -expandProperty FileSystemVolumeInfo
}

