$Title = "Cluster Configuration Issues"
$Header =  "Cluster(s) Config Issue(s)"
$Comments = "The following alarms have been registered against clusters in vCenter"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$clualarms = @()
foreach ($clusview in $clusviews) {
	if ($clusview.ConfigIssue) {           
		$CluConfigIssues = $clusview.ConfigIssue
		Foreach ($CluConfigIssue in $CluConfigIssues) {
			$Details = "" | Select-Object Name, Message
			$Details.name = $clusview.name
			$Details.Message = $CluConfigIssue.FullFormattedMessage
			$clualarms += $Details
		}
	}
}

$clualarms | sort name
	


