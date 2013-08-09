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
    $Report = "" | Select-Object VMname,ESXname,ClusterName,VMXname,VMDKname,VmdkSizeGB,TotalVmdkSizeGB,DatastoreName,GuestOS
    $Report.VMName = $VM.name
	$Report.ESXname = $VM.Host
	$Report.ClusterName = ($VM | Get-Cluster).Name
    $Report.VMXname = $VMview.Config.Files.VmPathName.Split("/")[1]
	$Report.VMDKname = $VMDKnames
    $Report.VmdkSizeGB = $VmdkSizeGB
    $Report.TotalVmdkSizeGB = $TotalHardDisksSizeGB
    $Report.DatastoreName = $VMview.Config.DatastoreUrl
    $Report.GuestOS = $VM.Guest.OSFullName
    Write-Output $Report
  }

   
