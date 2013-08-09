

Get-Datastore | Select Name, Type, @{N="CapacityGB";E={[math]::Round($_.CapacityGB,2)}}, @{N="FreeSpaceGB";E={[math]::Round($_.FreeSpaceGB,2)}},@{N='PercentFree';E={ ($_.FreespaceGB / $_.capacityGB) * 100}} 


