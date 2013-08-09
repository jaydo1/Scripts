$Title = "VCB/Veeam Garbage"
$Header =  "VCB/Veeam Garbage"
$Comments = "The following snapshots have been left over from using VCB/Veeam, you may wish to investigate if these are still needed"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$VM |where { (Get-Snapshot -VM $_).name -contains "VCB|Consolidate|veeam" } |sort name |select name

