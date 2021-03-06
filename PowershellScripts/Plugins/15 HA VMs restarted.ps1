$Title = "HA VMs restarted"
$Header =  "HA: VM restart (Last $HAVMrestartold Day(s)) : $($HAVMrestartlist.count)"
$Comments = "The following VMs have been restarted by HA in the last $HAVMresetold days"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# HA VM restart day(s) number
$HAVMrestartold =5
# End of Settings

@(Get-VIEvent -maxsamples 100000 -Start ($Date).AddDays(-$HAVMrestartold) -type info | Where {$_.FullFormattedMessage -match "was restarted"} |select CreatedTime,FullFormattedMessage |sort CreatedTime -Descending)
