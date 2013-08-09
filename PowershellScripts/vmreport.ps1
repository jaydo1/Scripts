$allLines = @()
Get-VM | `

  ForEach-Object {
    $VM = $_
    $VMview = $VM | Get-View
    $VMResourceConfiguration = $VM | Get-VMResourceConfiguration
    $VMHardDisks = $VM | Get-HardDisk
    $HardDisksSizesGB = @()
    $Temp = $VMHardDisks | ForEach-Object { $HardDisksSizesGB += [Math]::Round($_.CapacityKB/1MB) }
    $VmdkSizeGB = ""
    $Temp = $HardDisksSizesGB | ForEach-Object { $VmdkSizeGB += "$_+" }
    $VmdkSizeGB = $VmdkSizeGB.TrimEnd("+")
    $TotalHardDisksSizeGB = 0
    $Temp = $HardDisksSizesGB | ForEach-Object { $TotalHardDisksSizeGB += $_ }
    $VMDKnames = @()
	$Temp = $VMHardDisks | ForEach-Object { $VMDKnames += $_.Filename.Split("/")[1] }
    $Snapshots = $VM | Get-Snapshot
    $Report = "" | Select-Object VMname,ClusterName,ESXname,MemoryGB,vCPUcount,TotalVmdkSizeGB,DatastoreName,vNICcount,IPaddresses,VMXname,VMDKname,VmdkSizeGB,GuestOS
    $Report.VMName = $VM.name
	$Report.ClusterName = ($VM | Get-Cluster).Name
	$Report.ESXname = $VM.Host
	$Report.MemoryGB = $VM.MemoryMB/1024
    $Report.vCPUcount = $VM.NumCpu
    $Report.TotalVmdkSizeGB = $TotalHardDisksSizeGB
    $Report.DatastoreName = $VMview.Config.DatastoreUrl
    $Report.vNICcount = $VM.Guest.Nics.Count
    $Report.IPaddresses = $VM.Guest.IPAddress
    $Report.VMXname = $VMview.Config.Files.VmPathName.Split("/")[1]
	$Report.VMDKname = $VMDKnames
    $Report.VmdkSizeGB = $VmdkSizeGB
    $Report.GuestOS = $VM.Guest.OSFullName
    $allLines += $Report
    
  }

 $allLines | Export-Csv "C:\VMreport.csv" -NoTypeInformation