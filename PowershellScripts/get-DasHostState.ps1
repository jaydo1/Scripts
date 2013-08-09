function Get-DasHostState{
  param(
  [PSObject]$Cluster
  )

  if($Cluster.GetType().Name -eq "string"){
    $Cluster = Get-Cluster -Name $Cluster
  }
  Get-View -ViewType HostSystem -Property Name,Runtime.DasHostState | %{
    New-Object PSObject -Property @{
      VMHost = $_.Name
      DasHostState = $_.RunTime.DasHostState.State
      StateReporter = (Get-View -Id $_.RunTime.DasHostState.StateReporter -Property Name).Name
    }
  }
}
