foreach($esx in Get-VMHost){
  $hbaTab = @{}
  $esx.ExtensionData.Config.StorageDevice.HostBusAdapter | %{
    $hbaTab.Add($_.Key,$_.Device)
  }
  foreach($lun in $esx.ExtensionData.Config.StorageDevice.MultipathInfo.Lun){
    $lun.Path | Group-Object Adapter | %{
      if(@($_.Group).Count -lt 2){
        New-Object PSObject -Property @{
          Host = $esx.Name
          HBA = $hbaTab[$_.Name]
        }        
      }
    }
  }
}