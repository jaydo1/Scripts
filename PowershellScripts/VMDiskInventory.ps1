$currentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy')

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
    $Report = "" | Select-Object VMname,ClusterName,VmdkSizeGB,TotalVmdkSizeGB,RDMPath,DiskGb,DiskFree,
	
	$Report.VMName = $VM.name
	$Report.ClusterName = ($VM | Get-Cluster).Name
	$Report.VmdkSizeGB = $VmdkSizeGB
    $Report.TotalVmdkSizeGB = $TotalHardDisksSizeGB
    $RDMPaths = $vm | Get-HardDisk | where {$_.DiskType -like "Raw*"}
    $Report.RDMPath = &{if($RDMPaths){$RDMPaths | %{$_.ScsiCanonicalName}}else{"No RDM"}}
    $Report.DiskGb = [Math]::Round((($vm.HardDisks | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
    $Report.DiskFree = [Math]::Round((($vm.Guest.Disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB),2)
    $allLines += $Report
  
  }

  $allLines | Export-Csv "C:\VMDISKInfo_$CurrentDate.csv" -NoTypeInformation
