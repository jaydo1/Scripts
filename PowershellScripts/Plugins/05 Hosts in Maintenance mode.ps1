$Title = "Hosts in Maintenance Mode"
$Header =  "Hosts in Maintenance Mode : $($MaintHosts.count)"
$Comments = "Hosts held in Maintenance mode will not be running any virtual machine worloads, check the below Hosts are in an expected state"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$MaintHosts = @($VMH | where {$_.ConnectionState -match "Maintenance"} | Select Name, State)
$MaintHosts

