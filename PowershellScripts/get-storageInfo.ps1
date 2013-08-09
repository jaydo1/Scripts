#############################
# Get-StorageInfo.ps1
# Created by Hugo Peeters
# Created AUGUST 2008
# http://www.peetersonline.nl
#############################

# Description: Gets detailed information about LUNs and Paths in the Virtual Infrastructure. Dot-source this script!

# Purely cosmetic blank line
Write-Host ""

# Variables
$Color = "yellow"

# Check if the script was dot-sourced
If ($MyInvocation.InvocationName -ne '.')
{
	Write-Warning "This script should be dot-sourced. Preceed the path with a dot and a space."
	Throw "Script not dot-sourced"
}

# Connect to Virtual Center
$VCServerName = Read-Host "Enter Virtual Center Server Name"
$VC = Connect-VIServer $VCServerName

# Create menu for selecting cluster or folder

$MenuTitle = "Select Entity"
$MenuMessage = "Which type of entity would you like to use? Make sure you select an entity for which you would expect the storage configuration to be equal on all VMHosts."
$ChoiceCluster = New-Object System.Management.Automation.Host.ChoiceDescription "&Cluster", "Allows you to select a cluster."
$ChoiceFolder = New-Object System.Management.Automation.Host.ChoiceDescription "&Folder", "Allows you to select a folder."
$MenuOptions = [System.Management.Automation.Host.ChoiceDescription[]]($ChoiceCluster, $ChoiceFolder)
$MenuResult = $Host.UI.PromptForChoice($MenuTitle, $MenuMessage, $MenuOptions, 0)
Switch ($MenuResult)
    {
        0 
		{
			$Clusters = Get-Cluster | Sort-Object Name
			$Menu = @()
			For ($i = 1; $i -le $Clusters.Length ; $i++)
			{
				$MenuItem = "" | Select-Object '#', Name
				$MenuItem.'#' = $i
				$MenuItem.Name = $Clusters[$i-1].Name
				$Menu += $MenuItem
			}
			$Menu | Format-Table -AutoSize
			$Choice = Read-Host 'Select Cluster #'
			$EntityName = $menu[$Choice-1].Name
			$Entity = Get-Cluster $EntityName
		}
        1
		{
			$Folders = Get-Folder | Where { $_.Name -ne "vm" -and $_.Name -ne "host" -and $_.Name -notmatch "Discovered"}
			$Menu = @()
			For ($i = 1; $i -le $Folders.Length ; $i++)
			{
				$MenuItem = "" | Select-Object '#', Name
				$MenuItem.'#' = $i
				$MenuItem.Name = $Folders[$i-1].Name
				$Menu += $MenuItem
			}
			$Menu | Format-Table -AutoSize
			$Choice = Read-Host 'Select Folder # (Choose Datacenters to select ALL VMHosts)'
			$EntityName = $menu[$Choice-1].Name
			$Entity = Get-Folder $EntityName
		}
    }

# Gather information
$VMHosts = Get-VMHost -Location $Entity | Sort-Object Name
$VMHostCounter = 0
$VMHostTotal = $VMHosts.Length
If ($VMHostTotal -eq $null)
{
	Write-Warning "You can't run this script against an entity that contains one or less VMHosts. Please select a different Entity."
	Throw "Entity contains not enough VMHosts."
}
$LUNCollection = @()
# Loop through VMHosts
ForEach ($VMHost in $VMhosts)
{
	$VMHostName = $VMHost.Name
	$VMHostCounter++
	Write-Progress -Activity "Gathering Information for Entity $EntityName" -Status "Processing server $VMHostName ..." -Id 1 -PercentComplete (100*$VMHostCounter/$VMHostTotal)
	$VMHostAdv = Get-View $VMHost.Id
	$DatastoreCollection = @()
	$Datastores = $VMHostAdv.Config.FileSystemVolume.MountInfo
	$DatastoresCounter = 0
	$DatastoresTotal = $Datastores.Length
	# Loop through datastores to match extents to datastore names
	ForEach ($Datastore in $Datastores)
	{
		$DatastoresCounter++
		Write-Progress -Activity " " -Status "Getting Datastores on $VMHostName" -Id 2 -PercentComplete (100*$DatastoresCounter/$DatastoresTotal)
		$DatastoreObject = "" | Select-Object Datastore, Extent
		$DatastoreName = $Datastore.Volume.Name
		$Extents = $Datastore.Volume.Extent
		$ExtentCollection = @()
		ForEach ($Extent in $Extents)
		{
			$ExtentName = $Extent.DiskName
			$ExtentCollection += $ExtentName
		}
		$DatastoreObject.Datastore = $DatastoreName
		$DatastoreObject.Extent = $ExtentCollection
		$DatastoreCollection += $DatastoreObject
	}
	$VMHBAs = $VMHostAdv.Config.StorageDevice.ScsiTopology.Adapter
	$VMHBAsCounter = 0
	$VMHBAsTotal = $VMHBAs.Length
	# Loop through VMHBAs
	ForEach ($VMHBA in $VMHBAs)
	{
		$VMHBAName = $VMHBA.Adapter.Split("-")[2]
		$VMHBAsCounter++
		Write-Progress -Activity " " -Status "Processing $VMHBAname ..." -Id 3 -PercentComplete (100*$VMHBAsCounter/$VMHBAsTotal)
		$SCSITargets = $VMHBA.Target
		$SCSITargetsCounter = 0
		$SCSITargetsTotal = $SCSITargets.Length
		# Loop through SCSITargets
		ForEach ($SCSITarget in $SCSITargets)
		{
			$SCSITargetNumber = $SCSITarget.Target
			$SCSITargetsCounter++
			Write-Progress -Activity " " -Status "Processing SCSI Target $SCSITargetNumber ..." -Id 4 -PercentComplete (100*$SCSITargetsCounter/$SCSITargetsTotal)
			$LUNs = $SCSITarget.Lun
			$LUNsCounter = 0
			$LUNsTotal = $LUNs.Length
			# Loop through LUNs
			ForEach ($LUN in $LUNs)
			{
				$LUNID = $LUN.Lun
				$LUNPath = $VMHBAName + ":" + $SCSITargetNumber + ":" + $LUNID
				$LUNPathInfo = $VMHostAdv.Config.StorageDevice.MultipathInfo.lun
				$LUNSANInfo = $VMHostAdv.Config.StorageDevice.ScsiLun
				$LUNsCounter++
				Write-Progress -Activity " " -Status "Processing LUN ID $LUNID ..." -Id 5 -PercentComplete (100*$LUNsCounter/$LUNsTotal)
				# Store all info in a custom object
				$LUNObject = "" | Select-Object VMHost, LUNPath, Policy, Prefer, Datastore, Vendor, Model, VMHBA, SCSITarget, LUNID, LUNKey
				$LUNObject.VMHost = $VMHostName
				$LUNObject.LUNPath = $LUNPath
				$LUNObject.Policy = ($LUNPathInfo | Where {$_.Id -eq $LUNPath}).Policy.Policy
				$LUNObject.Prefer = ($LUNPathInfo | Where {$_.Id -eq $LUNPath}).Policy.Prefer
				$LUNObject.Datastore = ($DatastoreCollection | Where {$_.Extent -eq $LUNPath}).Datastore
				$LUNObject.Vendor = ($LUNSANInfo | Where {$_.CanonicalName -eq $LUNPath}).Vendor
				$LUNObject.Model = ($LUNSANInfo | Where {$_.CanonicalName -eq $LUNPath}).Model
				$LUNObject.VMHBA = $VMHBAName
				$LUNObject.SCSITarget = $SCSITargetNumber
				$LUNObject.LUNID = $LUNID
				$LUNObject.LUNKey = $LUN.Key
				# Add all custom objects to a custom collection
				$LUNCollection += $LUNObject
				# Clear set variables in order to eliminate errors
				Clear-Variable LUNPath -ErrorAction SilentlyContinue
				Clear-Variable LUNID -ErrorAction SilentlyContinue
				Clear-Variable LUNPathInfo -ErrorAction SilentlyContinue
				Clear-Variable LUNSANInfo -ErrorAction SilentlyContinue
			}
		}
	}
	Write-Progress -Activity " " -Status "Getting Datastores on $VMHostName" -Id 2 -Completed
	Write-Progress -Activity " " -Status "Processing $VMHBAname ..." -Id 3 -Completed
	Write-Progress -Activity " " -Status "Processing SCSI Target $SCSITargetNumber ..." -Id 4 -Completed
	Write-Progress -Activity " " -Status "Processing LUN ID $LUNID ..." -Id 5 -Completed
}

# Find missing properties by matching them to other LUN references with identical UUIDs (LUNKeys)
$i = 0
$j = $LUNCollection.Length
ForEach ($LUNObject2 in $LUNCollection)
{
$i++
	If ($LUNObject2.Datastore -eq $null)
	{
		Write-Progress -Activity "Filling Missing Properties" -Status "LUN $i of $j" -PercentComplete (100*$i/$j) -Id 1
		$LUNObject2.Datastore = ($LUNCollection | Where {$_.LUNKey -eq $LUNObject2.LUNKey -and $_.Datastore -ne $null -and $_.VMHost -eq $LUNObject2.VMHost} | Select-Object -First 1).Datastore
	}
	If ($LUNObject2.Policy -eq $null)
	{
		Write-Progress -Activity "Filling Missing Properties" -Status "LUN $i of $j" -PercentComplete (100*$i/$j) -Id 1
		$LUNObject2.Policy = ($LUNCollection | Where {$_.LUNKey -eq $LUNObject2.LUNKey -and $_.Policy -ne $null -and $_.VMHost -eq $LUNObject2.VMHost} | Select-Object -First 1).Policy
	}
	If ($LUNObject2.Prefer -eq $null -and $LUNObject2.Policy -ne "mru")
	{
		Write-Progress -Activity "Filling Missing Properties" -Status "LUN $i of $j" -PercentComplete (100*$i/$j) -Id 1
		$LUNObject2.Prefer = ($LUNCollection | Where {$_.LUNKey -eq $LUNObject2.LUNKey -and $_.Prefer -ne $null -and $_.VMHost -eq $LUNObject2.VMHost} | Select-Object -First 1).Prefer
	}
	If ($LUNObject2.Vendor -eq $null)
	{
		Write-Progress -Activity "Filling Missing Properties" -Status "LUN $i of $j" -PercentComplete (100*$i/$j) -Id 1
		$LUNObject2.Vendor = ($LUNCollection | Where {$_.LUNKey -eq $LUNObject2.LUNKey -and $_.Vendor -ne $null -and $_.VMHost -eq $LUNObject2.VMHost} | Select-Object -First 1).Vendor
	}
	If ($LUNObject2.Model -eq $null)
	{
		Write-Progress -Activity "Filling Missing Properties" -Status "LUN $i of $j" -PercentComplete (100*$i/$j) -Id 1
		$LUNObject2.Model = ($LUNCollection | Where {$_.LUNKey -eq $LUNObject2.LUNKey -and $_.Model -ne $null -and $_.VMHost -eq $LUNObject2.VMHost} | Select-Object -First 1).Model
	}
}

# Disconnect from VC Server
Disconnect-VIServer -Confirm:$False

# Results section
Write-Host ""
Write-Host "***********" -ForegroundColor $Color
Write-Host "* RESULTS *" -ForegroundColor $Color
Write-Host "***********" -ForegroundColor $Color
Write-Host ""

# Display overview of Number of LUNPaths per VMHost
Write-Host "Summary:" -ForegroundColor $Color
$LUNcollection | Group-Object VMHost -NoElement | Format-Table @{L="VMHost";E={$_.Name}},@{L="NumLUNPaths";E={$_.Count}} -AutoSize

# Display LUNs with uncommon path counts, excluding local storage. Script assumes most LUNs are properly configured (most common path count is excluded).
$Group = $LUNCollection | Where {$_.Vendor -notmatch "VMware"} | Group-Object LUNID,Datastore | Group-Object Count | Sort-Object Count -Descending
Write-Host "Most LUNs (" $Group[0].Count ") have" $Group[0].Name "paths;" ($Group[0].Name/$VMHosts.Length) "per host. Any exceptions are listed below. These might be misconfigured!" -ForegroundColor $Color
Write-Host ""
$Group | Select-Object -Last ($Group.Count - 1) | ForEach { $_.Group | ForEach { Write-Host "The following LUN has" $_.Count "path(s):" ; $_.Group | Format-Table -AutoSize } }

# Declare custom functions
Function Show-DatastorePaths
{
	$LUNCollection | Group-Object LUNID,Datastore -NoElement | Sort-Object Count -Descending | Format-Table -AutoSize
}

Function Show-LUNs
{
	param([string]$VMHost = "",[string]$LUNID = "",[string]$Policy = "",[string]$Datastore = "",[string]$Vendor = "",[string]$Model = "")
	$LUNCollection | Where {$_.VMHost -match $VMHost -and $_.LUNID -eq $LUNID -and $_.Policy -match $Policy -and $_.Datastore -match $Datastore -and $_.Vendor -match $Vendor -and $_.Model -match $Model} | Format-Table VMHost, LUNPath, Policy, Prefer, Datastore, Vendor, Model -Autosize
}

# Show help section
Write-Host "********************************************************************************************************" -ForegroundColor $Color
Write-Host 'Complete information is stored in the $LUNCollection variable.' -ForegroundColor $Color
Write-Host "Type Show-DatastorePaths for an overview of LUNs and path counts." -ForegroundColor $Color
Write-Host "Type Show-LUNs for a detailed overview of Luns, which can be filtered by using the following parameters:" -ForegroundColor $Color
Write-Host "VMHost, LUNID, Policy, Datastore, Vendor, Model" -ForegroundColor $Color
Write-Host "Example uses:" -ForegroundColor $Color
Write-Host 'Show-LUNs -Datastore PRD -Policy MRU' 
Write-Host "Finds LUNs where the datastore name contains PRD and the policy is set to MRU" -ForegroundColor $Color
Write-Host '$LUNCollection | Where{$_.Datastore -eq $null} | Group-Object LUNID' 
Write-Host "Shows LUN IDs that have no datastore name (e.g. RDMs or unused LUNs)" -ForegroundColor $Color
Write-Host "********************************************************************************************************" -ForegroundColor $Color

# End of script