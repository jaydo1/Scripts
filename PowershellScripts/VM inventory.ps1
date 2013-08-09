$HostReport = @()
Get-VM | sort-object name | foreach ($_.name){
$Report = "" | select Hostname, Cluster, NumCPU, MemoryMB, Network, SCSI, Datastore, ToolsVersion, ToolsStatus
$Report.Hostname = $_.Name 
$report.Cluster = ($_|Get-Cluster).Name
$report.NumCPU = $_.NumCPU
$report.MemoryMB = $_.MemoryMB
$report.Network = ($_|Get-NetworkAdapter).Type
$report.SCSI = ($_|Get-ScsiController).Type 
$report.Datastore = ($_|Get-Datastore).Name
$report.ToolsVersion = $_.ToolsVersion
$report.ToolsStatus = $_.ToolsVersionStatus
$HostReport += $Report 
}
$HostReport | Export-Csv -Path c:\TEMP\vm-hw.csv -NoTypeInformation -UseCulture