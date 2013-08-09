$currentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy')
$AllVMs = Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template}

$allLines = @()
   ForEach ($VM in $AllVMs) {
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
    
	
	$Report = "" | Select-Object VMname,ClusterName,VMDKname,VmdkSizeGB,TotalVmdkSizeGB,DiskGb,DiskFree,DatastoreName,RDMPath
    $Report.VMName = $VM.name
	$Report.ClusterName = ($VM | Get-Cluster).NameForEach
	$Report.VMDKname = $VMDKnames
    $Report.VmdkSizeGB = $VmdkSizeGB
    $Report.TotalVmdkSizeGB = $TotalHardDisksSizeGB
	$Report.DiskGb = [Math]::Round((($vm.HardDisks | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
    $Report.DiskFree = [Math]::Round((($vm.Guest.Disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB),2)
    $Report.DatastoreName = $VMview.Config.DatastoreUrl
    $RDMPaths = $vm | Get-HardDisk | where {$_.DiskType -like "Raw*"}
    $Report.RDMPath = &{if($RDMPaths){$RDMPaths | %{$_.ScsiCanonicalName}}else{"No RDM"}}
	
    $allLines += $Report
  
  }  

  $allLines | Export-Csv "C:\VMDISKInventory_$currentdate.csv" -NoTypeInformation -UseCulture
