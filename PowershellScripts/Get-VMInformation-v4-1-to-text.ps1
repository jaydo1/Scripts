$allLines = @()                                            # Line added
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
    $Report = "" | Select-Object VMname,vmCreatedByUser,vmCreatedDate,ESXname,ClusterName,MemoryGB,vCPUcount,vNICcount,IPaddresses,VMXname,VMDKname,VmdkSizeGB,TotalVmdkSizeGB,DatastoreName,ToolsVersion,ToolsUpdate,NumCpuShares,CpuLimitMHZ,CpuReservationMHZ,NumMemShares,ReservationsMB,LimitMB,SnapshotCount,GuestOS
    $Report.VMName = $VM.name
	$Report.vmCreatedByUser = $VM.CustomFields["CreatedBy"]
	$Report.vmCreatedDate = $VM.CustomFields["CreatedOn"]
    $Report.ESXname = $VM.Host
	$Report.ClusterName = ($VM | Get-Cluster).Name
    $Report.MemoryGB = $VM.MemoryMB/1024
    $Report.vCPUcount = $VM.NumCpu
    $Report.vNICcount = $VM.Guest.Nics.Count
    $Report.IPaddresses = $VM.Guest.IPAddress
    $Report.VMXname = $VMview.Config.Files.VmPathName.Split("/")[1]
	$Report.VMDKname = $VMDKnames
    $Report.VmdkSizeGB = $VmdkSizeGB
    $Report.TotalVmdkSizeGB = $TotalHardDisksSizeGB
    $Report.DatastoreName = $VMview.Config.DatastoreUrl
    $Report.ToolsVersion = $VMview.Config.Tools.ToolsVersion
    $Report.ToolsUpdate = $VMview.Guest.ToolsStatus
    $Report.NumCpuShares = $VMResourceConfiguration.NumCPUShares
	$Report.CpuLimitMHZ = $VMResourceConfiguration.CpuLimitMhz
	$Report.CpuReservationMHZ = $VMResourceConfiguration.CpuReservationMhz
    $Report.NumMemShares = $VMResourceConfiguration.NumMemShares
    $Report.ReservationsMB = $VMResourceConfiguration.MemReservationMB
    $Report.LimitMB = $VMResourceConfiguration.MemLimitMB
    $Report.SnapshotCount = (@($VM | Get-Snapshot)).Count
    $Report.GuestOS = $VM.Guest.OSFullName
    $allLines += $Report                                   # Line changed
  }

$allLines | Out-File "C:\VMreport.txt"                     # Line added

