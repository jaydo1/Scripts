@"
======================================================================
Title:         VMExtract.ps1
Description:   Exports VM Information from vCenter into a .CSV file 
Source:        Julian Rattue, wooditwork.com, LucD
Usage:         .\VMExtract.ps1
Date:          15/10/2012
======================================================================
"@
filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name
 
        $current = Get-View $_.Parent
#        $path = $_.Name # Uncomment out this line if you want the VM Name to appear at the end of the path
        $path = ""
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}

$SelectVC = "upvvcs001.detnsw.win","hpvvcs001.detnsw.win"

#testing for each vc loop
#$intyhosts = Get-VMHost -Server $vcserver | Sort Name
 
ForEach ($vcserver in $SelectVC) {
 
#$SelectVC = Read-Host "Enter vCenter Server Name: (type u1,h1,u4,h4)"
$VC = Connect-VIServer $SelectVC
$VMFolder = "*"
$Timestamp = Get-Date -format "yyyyMMdd-HH.mm"
$Csvfile = "c:$TimeStamp-$SelectVC-VMDiskInfo.csv"

$Report = @()
$VMs = Get-Folder $VMFolder | Get-VM
 
$Datastores = Get-Datastore | select Name, Id
$VMHosts = Get-VMHost | select Name, Parent
$Annotation1 = "Managed By"

Write-Host = "1. Gathering information from" $SelectVC -ForegroundColor Yellow
 
ForEach ($VM in $VMs) {
      $VMView = $VM | Get-View
      $VMInfo = {} | Select ,VMName,Folder,Datastore,
      $VMInfo.VMName = $vm.name
      $VMInfo.Folder = ($vm | Get-Folderpath).Path
      $VMInfo.Datastore = ($Datastores | where {$_.ID -match (($vmview.Datastore | Select -First 1) | Select Value).Value} | Select Name).Name
      $VMInfo.DiskGb = [Math]::Round((($vm.HardDisks | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
      $VMInfo.DiskFree = [Math]::Round((($vm.Guest.Disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB),2)
      $VMInfo.DiskUsed = $VMInfo.DiskGb - $VMInfo.DiskFree
ForEach ($VM in $VMs){
 		$Details = New-object PSObject
 		$Details | Add-Member -Name Name -Value $VM.name -Membertype NoteProperty
		$DiskNum = 0
 Foreach ($disk in $VM.Guest.Disk){
 		$Details | Add-Member -Name "Disk$($DiskNum)path" -MemberType NoteProperty -Value $Disk.DiskPath
 		$Details | Add-Member -Name "Disk$($DiskNum)Capacity(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.Capacity/ GB))
 		$Details | Add-Member -Name "Disk$($DiskNum)FreeSpace(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.FreeSpace / GB))
 		$DiskNum++
 }
      $Report += $VMInfo
	  $Report += $Details
}
$Report = $Report | Sort-Object VMName
IF ($Report -ne "") {
$report | Export-Csv $Csvfile -NoTypeInformation
}
Write-Host = "2. Script is complete...goto" $Csvfile -ForegroundColor Green
$VC = Disconnect-VIServer "*" -Confirm:$False
}
#$VC = Disconnect-VIServer "*" -Confirm:$False