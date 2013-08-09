$Title = "No VM Tools"
$Header =  "No VMTools"
$Comments = "The following VMs do not have VM Tools installed or are not running, you may gain increased performance and driver support if you install VMTools"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

@($FullVM | Where {$_.Runtime.Powerstate -eq "poweredOn" -And ($_.Guest.toolsStatus -eq "toolsNotInstalled" -Or $_.Guest.ToolsStatus -eq "toolsNotRunning")} | Select Name, @{N="Status";E={$_.Guest.ToolsStatus}})
