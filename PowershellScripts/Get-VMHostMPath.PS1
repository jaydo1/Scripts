$hostview = Get-VMHost | Get-View
$mPathLun = $hostview.Config.StorageDevice.MultipathInfo.Lun
foreach ( $lun in $mPathLun ) {
	$lunName = $lun.Id
	$pathCount = $lun.Path.Length
	$mPathPolicy = $lun.Policy.Policy
	Write-Host "Disk $lunName has $pathCount paths and policy of $mPathPolicy."
}