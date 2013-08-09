$clusterName = Read-host "enter Cluster name" 
$cluster = Get-Cluster -Name $clusterName

$esxs = $cluster | get-vmhost 
foreach ($esx in $esxs){
	$HostView = Get-View $esx  
    ForEach ($ScsiLun in ($HostView.Config.StorageDevice.ScsiLun | Where-Object {$_.DisplayName -match '^decom_'}))
}{
            $lunname = $ScsiLun.DisplayName
            Write-Output "Detaching LUN $LunName"
      }

  