Get-View -ViewType Datastore | Select Name, 
     @{N="CapacityGB";E={$_.Summary.Capacity/1GB}},
     @{N="ProvisionedGb";E={($_.Summary.Capacity - $_.Summary.FreeSpace + $_.Summary.Uncommitted)/1GB}},
     @{N="FreeGB";E={$_.Summary.FreeSpace/1GB}}