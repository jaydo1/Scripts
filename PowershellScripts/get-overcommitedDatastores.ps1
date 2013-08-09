Get-Datastore | ForEach-Object {
  $Datastore = $_.Extensiondata
  if ($Datastore.Summary.Uncommitted -gt "0") {
    $Report = "" | Select-Object -Property Datastore, CommittedPercent
    $Report.Datastore = $Datastore.name
    $Report.CommittedPercent = [math]::round(((($Datastore.Summary.Capacity - $Datastore.Summary.FreeSpace) + $Datastore.Summary.Uncommitted)*100)/$Datastore.Summary.Capacity,0)
    $Report
  }
}