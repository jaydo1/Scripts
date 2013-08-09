$Title = "Checking VI Events"
$Header =  "Error Events (Last $VCEventAge Day(s))"
$Comments = "The Following Errors were logged in the vCenter Events tab, you may wish to investigate these"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

@(Get-VIEvent -maxsamples 10000 -Start ($Date).AddDays(-$VCEventAge ) -Type Error | Select @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage)
