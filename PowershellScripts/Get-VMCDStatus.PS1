param ( $Name = "*" )
$vmCol = Get-VM -Name $Name
$Output = @()
foreach ($vm in $vmCol) {
	$vm | Get-CDDrive | ForEach-Object {
		$process = "" | select Name, DriveType, Connected
		$process.Name = $vm.Name
		switch ( $_ ) {
			{ $_.IsoPath }		{ $process.DriveType = "Host ISO File" }
			{ $_.HostDevice }	{ $process.DriveType = "Host Device" }
			default				{ $process.DriveType = "Client Device " }
		}
		$process.Connected = $_.ConnectionState.Connected
		$Output += $process
	}
}
Write-Output $Output