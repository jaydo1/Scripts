# List all snapshots over 14 days old
 
Connect-VIServer MYVISERVER

Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-14)}