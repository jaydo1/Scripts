#Get VMware Disk Usage
# Created by Hugo Peeters
# http://www.peetersonline.nl
# VARIABLES
$Decimals = 1
$VCServer = "hpvvcs001"
# SCRIPT
# Connect to VC
Write-Progress "Gathering Information" "Connecting to Virtual Center" -Id 0
$VC = Connect-VIServer $VCServer
# Create Output Collection
$myCol = @()
# List Datastores (Datastore Name)
Write-Progress "Gathering Information" "Listing Datastores" -Id 0
$Datastores = Get-Datastore | Sort Name
# List vms
Write-Progress "Gathering Information" "Listing VMs and Disk Files" -Id 0
$VMSummaries = @()
ForEach ($vm in (Get-VM))
	{
	$VMView = $VM | Get-View
	ForEach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | Where {$_.DeviceInfo.Label -match "SCSI Controller"}))
		{
		ForEach ($VirtualDiskDevice  in ($VMView.Config.Hardware.Device | Where {$_.ControllerKey -eq $VirtualSCSIController.Key}))
			{
			$VMSummary = "" | Select VM, HostName, PowerState, DiskFile, DiskName, DiskSize, SCSIController, SCSITarget
			$VMSummary.VM = $VM.Name
			$VMSummary.HostName = $VMView.Guest.HostName
			$VMSummary.PowerState = $VM.PowerState
			$VMSummary.DiskFile = $VirtualDiskDevice.Backing.FileName
			$VMSummary.DiskName = $VirtualDiskDevice.DeviceInfo.Label
			$VMSummary.DiskSize = $VirtualDiskDevice.CapacityInKB * 1KB
			$VMSummary.SCSIController = $VirtualSCSIController.BusNumber
			$VMSummary.SCSITarget = $VirtualDiskDevice.UnitNumber
			$VMSummaries += $VMSummary
			}
		}
	Clear-Variable VMView -ErrorAction SilentlyContinue
	}
# Loop through Datastores
ForEach ($Datastore in $Datastores)
	{
	# List vmdk files in datastore (vmdk Name)
	Write-Progress "Gathering Information" ("Processing Datastore {0}" -f $Datastore.Name) -Id 0
	$DSView = $Datastore | Get-View
	$fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
	$fileQueryFlags.FileSize = $true
	$fileQueryFlags.FileType = $true
	$fileQueryFlags.Modification = $true
	$searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
	$searchSpec.details = $fileQueryFlags
	$searchSpec.sortFoldersFirst = $true
	$dsBrowser = Get-View $DSView.browser
	$rootPath = "["+$DSView.summary.Name+"]"
	$searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
	ForEach ($result in $searchResult)
		{
		ForEach ($vmdk in ($result.File | ?{$_.Path -like "*.vmdk"} | Sort Path))
			{
			Write-Progress "Gathering Information" ("Processing VMDK {0}" -f $vmdk.Path) -Id 1
			Write-Host "=============================================================================="
			# Find vm using the vmdk (VM Name)
			$VMRef = ($VMSummaries | ?{$_.DiskFile -match $Datastore.Name -and $_.DiskFile -match $vmdk.Path})
			"VMDK {0} belongs to VM {1}" -f $vmdk.Path, $VMRef.VM
			If ($VMRef.Powerstate -eq "PoweredOn")
				{
				Write-Host "VM is powered on" -ForegroundColor "yellow"
				$Partitions = Get-WmiObject -Class Win32_DiskPartition -ComputerName $VMRef.HostName
				If ($?)
					{
					$Disks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $VMRef.HostName
					$LogicalDisks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $VMRef.HostName
					$DiskToPartition = Get-WmiObject -Class Win32_DiskDriveToDiskPartition -ComputerName $VMRef.HostName
					$LogicalDiskToPartition = Get-WmiObject -Class Win32_LogicalDiskToPartition -ComputerName $VMRef.HostName
					Write-Host "Read partition and disk information" -ForegroundColor "yellow"
					# Match disk based on SCSI ID's
					$DiskMatch = $Disks | ?{($_.SCSIPort - 1) -eq $VMRef.SCSIController -and $_.SCSITargetID -eq $VMRef.SCSITarget}
					If ($DiskMatch -eq $null){Write-Warning "NO MATCHES!"}
					Else
						{
						Write-Host "Found match:" -ForegroundColor "yellow"
						$DiskMatch
						# Find the Partition(s) on this disk
						$PartitionsOnDisk = ($DiskToPartition | ?{$_.Antecedent -eq $DiskMatch.__PATH})
						If ($PartitionsOnDisk -eq $null){Write-Warning "NO PARTITIONS!"}
						Else
							{
							ForEach ($PartitionOnDisk in $PartitionsOnDisk)
								{
								Write-Host "Disk contains partition" -ForegroundColor "yellow"
								$PartitionOnDisk.Dependent
								$PartitionMatches = $Partitions | ?{$_.__PATH -eq $PartitionOnDisk.Dependent}
								ForEach ($PartitionMatch in $PartitionMatches)
									{
									$LogicalDiskRefs = $LogicalDiskToPartition | ?{$_.Antecedent -eq $PartitionMatch.__PATH}
									If ($LogicalDiskRefs -eq $null)
										{
										Write-Warning "NO LOGICAL DISKS!"
										}
									Else
										{
										ForEach ($LogicalDiskRef in $LogicalDiskRefs)
											{
											$LogicalDiskMatches = $LogicalDisks | ?{$_.__PATH -eq $LogicalDiskRef.Dependent}
											ForEach ($LogicalDiskMatch in $LogicalDiskMatches)
												{
												Write-Host "Matching Logical Disk:" -ForegroundColor "yellow"
												$LogicalDiskMatch
												# Create Output Object
												$myObj = "" | Select Datastore, DSSizeGB, DSFreeGB, DSPercentFree, DiskFile, VM, HardDisk, DriveLetter, DiskSizeGB, DiskFreeGB, PercFree
												# List datastore name
												$myObj.Datastore = $Datastore.Name
												# Determine datastore size in GB
												$myObj.DSSizeGB = [Math]::Round(($Datastore.CapacityMB * 1MB / 1GB),$Decimals)
												$myObj.DSFreeGB = [Math]::Round(($Datastore.FreeSpaceMB * 1MB / 1GB),$Decimals)
												# Determine datastore free space (DS%Free)
												$myObj.DSPercentFree = [Math]::Round((100*($Datastore.FreeSpaceMB/$Datastore.CapacityMB)),$Decimals)
												# List disk file name
												$myObj.DiskFile = $vmdk.Path
												# List VM Name
												$myObj.VM = $VMRef.VM
												# Determine virtual hard disk / logical drive
												$myObj.HardDisk = $VMRef.DiskName
												# Report driveletter
												$myObj.DriveLetter = $LogicalDiskMatch.DeviceID
												# Report Size
												$myObj.DiskSizeGB = [Math]::Round(($LogicalDiskMatch.Size / 1GB),$Decimals)
												# Report Free Space
												$myObj.DiskFreeGB = [Math]::Round(($LogicalDiskMatch.FreeSpace / 1GB),$Decimals)
												# Calculate Percentage free space
												$myObj.PercFree = [Math]::Round((100 * ([int]($LogicalDiskMatch.FreeSpace / 1MB) / [int]($LogicalDiskMatch.Size / 1MB))),$Decimals)
												Write-Host "RESULT:" -ForegroundColor "yellow"
												$myObj
												# Add output object to output collection
												$myCol += $myObj
												}
											Clear-Variable LogicalDiskMatches -ErrorAction SilentlyContinue
											}
										}
									Clear-Variable LogicalDiskRefs -ErrorAction SilentlyContinue
									}
								Clear-Variable PartitionMatches -ErrorAction SilentlyContinue
								}
							}
						Clear-Variable PartitionsOnDisk -ErrorAction SilentlyContinue
						}
					Clear-Variable DiskMatch -ErrorAction SilentlyContinue
					Clear-Variable Disks -ErrorAction SilentlyContinue
					Clear-Variable LogicalDisks -ErrorAction SilentlyContinue
					Clear-Variable DiskToPartition -ErrorAction SilentlyContinue
					Clear-Variable LogicalDiskToPartition -ErrorAction SilentlyContinue
					}
				Clear-Variable Partitions -ErrorAction SilentlyContinue
				}
			Else
				{
				Write-Host "VM is powered off" -ForegroundColor "yellow"
				}
			Clear-Variable VMRef -ErrorAction SilentlyContinue
			Write-Progress "Gathering Information" ("Processing VMDK {0}" -f $vmdk.Path) -Id 1 -Completed
			}
		}
	}
# Disconnect from VC
Disconnect-VIServer -Confirm:$False
# OUTPUT
Write-Host "==================================================="
Write-Host "==================================================="
$TotalDSFree = ($myCol | Select Datastore, DSFreeGB -Unique | Measure-Object DSFreeGB -Sum).Sum
$TotalDSSize = ($myCol | Select Datastore, DSSizeGB -Unique | Measure-Object DSSizeGB -Sum).Sum
$AverageDSFree =  [Math]::Round(100 * ($TotalDSFree / $TotalDSSize),$Decimals)
$AverageDiskFree =  [Math]::Round(100 * (($myCol | Measure-Object DiskFreeGB -Sum).Sum / ($myCol | Measure-Object DiskSizeGB -Sum).Sum),$Decimals)
Write-Host "Total DS Free: $TotalDSFree"
Write-Host "Total DS Size: $TotalDSSize"
Write-Host "Average DS Free Percentage: $AverageDSFree"
Write-Host "Average Disk Free Percentage: $AverageDiskFree"
$myCol | Export-Csv -NoTypeInformation 'C:VMwareDiskUsage.csv'