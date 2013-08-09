Get-VIEvent -maxsamples 10000 |
where-Object {$_.Gettype().Name -match “(VmCreatedEvent|VmBeingClonedEvent|VmBeingDeployedEvent)“} |
Sort-object CreatedTime -Descending |
Select-Object CreatedTime, UserName, FullformattedMessage -First 10 

