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
    $Snapshots = $VM | Get-Snapshot
    $Report = "" | Select-Object VMname,ESXname,MemoryGB,vCPUcount,vNICcount,IPaddresses,VmdkSizeGB,TotalVmdkSizeGB,DatastoreName,ToolsVersion,ToolsUpdate,NumCpuShares,NumMemShares,ReservationsMB,LimitMB,SnapshotCount,GuestOS
    $Report.VMName = $VM.name
    $Report.ESXname = $VM.Host
    $Report.MemoryGB = $VM.MemoryMB/1024
    $Report.vCPUcount = $VM.NumCpu
    $Report.vNICcount = $VM.Guest.Nics.Count
    $Report.IPaddresses = $VM.Guest.IPAddress
    $Report.VmdkSizeGB = $VmdkSizeGB
    $Report.TotalVmdkSizeGB = $TotalHardDisksSizeGB
    $Report.DatastoreName = $VMview.Config.DatastoreUrl
    $Report.ToolsVersion = $VMview.Config.Tools.ToolsVersion
    $Report.ToolsUpdate = $VMview.Guest.ToolsStatus
    $Report.NumCpuShares = $VMResourceConfiguration.NumCPUShares
    $Report.NumMemShares = $VMResourceConfiguration.NumMemShares
    $Report.ReservationsMB = $VMResourceConfiguration.MemReservationMB
    $Report.LimitMB = $VMResourceConfiguration.MemLimitMB
    $Report.SnapshotCount = (@($VM | Get-Snapshot)).Count
    $Report.GuestOS = $VM.Guest.OSFullName
    Write-Output $Report
  }

   
