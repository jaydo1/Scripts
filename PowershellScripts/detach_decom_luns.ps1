$ClusterName = "Lab"
$ViServer = "utvvcs001.uatdetnsw.win"

Write-Host "Connecting to $ViServer"
Connect-VIServer -Server $ViServer

Write-Host "Fetching cluster hosts"
$ClusterHosts = Get-Cluster -Name $ClusterName | Get-VMHost

ForEach ($esx in $ClusterHosts) {
	Write-Host "Checking for decommissioned LUNs on $esx"
	$HostView = Get-View $esx | Select Config
	$StorSys  = Get-View $esx.ExtensionData.ConfigManager.StorageSystem
	$LunsFound = 0
	
	ForEach ($ScsiLun in ($HostView.Config.StorageDevice.ScsiLun | Where-Object {$_.DisplayName -match '^decom_'})) {
		$LunName = $ScsiLun.DisplayName
		$LunUuid = $ScsiLun.Uuid
		Write-Output "  Detaching LUN $LunName"
		$StorSys.DetachScsiLun($LunUuid)
		$LunsFound++
	}
	
	If ($LunsFound -eq 0) {
		Write-Host "  No decommissioned LUN's found"
	}
}

Write-Host "Disconnecting from $ViServer"
Disconnect-VIServer -Server $ViServer -Confirm:$False