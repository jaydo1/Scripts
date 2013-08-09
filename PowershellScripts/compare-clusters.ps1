$outputFile = 'D:\scipts\compare.html'
$VCServer = "hpvvcs001"

Function Create-HTMLTable
	{
	param([array]$Array)
	$arrHTML = $Array | ConvertTo-Html
	$arrHTML[-1] = $arrHTML[-1].ToString().Replace('</body></html>',"")
	Return $arrHTML[5..1000]
	}

$output = @()
$output += '<html><head></head><body>'
$output += '<style>table{border-style:solid;border-width:1px;font-size:8pt;background-color:#ccc;width:100%;}th{text-align:left;}td{background-color:#fff;width:20%;border-style:solid;border-width:1px;}body{font-family:verdana;font-size:8pt;}h1{font-size:12pt;}h2{font-size:10pt;}</style>'
$output += '<h1>VMWARE CONFIGURATION INCONSISTENCIES</h1>'
$output += '<p>The following items are not available to all ESX servers in the cluster:</p>'

$VC = Connect-VIServer $VCServer

ForEach ($Cluster in (Get-Cluster | Sort Name))
	{
	$VMHosts = $Cluster | Get-VMHost | Sort Name
	$VMHostViews = $VMHosts | Get-View | Sort Name
	
	$myDSCol = @()
	$Datastores = Get-Datastore -VMHost $VMHosts
	$DSdiffs = $VMHosts | ForEach {Compare-Object $Datastores (Get-Datastore -VMHost $_) -SyncWindow 1000} | ForEach {$_.InputObject} | Sort Name | Select Name -Unique
	ForEach ($DSdiff in $DSdiffs)
		{
		If ($DSdiff.Name -ne $null)
			{
			$myDSObj = "" | Select Datastore
			$myDSObj.Datastore = $DSdiff.Name
			ForEach ($VMHost in $VMHosts)
				{
				$myDSObj | Add-Member -MemberType NoteProperty -Name $VMHost.Name -Value (!!(Get-Datastore -Name $myDSObj.Datastore -VMHost $VMHost -ErrorAction SilentlyContinue))
				}
			$myDSCol += $myDSObj
			}
		}
		
	$myLUNCol = @()
	$LUNs = $VMHostViews | ForEach {$_.Config.StorageDevice.ScsiLun | ForEach {$_.Uuid}} | Select -Unique
	$LUNdiffs = @()
	ForEach ($VMHostView in $VMHostViews)
		{
		$HostLUNs = $VMHostView.Config.StorageDevice.ScsiLun | ForEach {$_.Uuid} | Select -Unique
		$LUNdiffs += Compare-Object $LUNs $HostLUNs -SyncWindow 1000 | ForEach {$_.InputObject}
		Clear-Variable HostLUNs -ErrorAction SilentlyContinue
		}
	ForEach ($LUNdiff in ($LUNdiffs | Select -Unique | Sort))
		{
		If ($LUNdiff -ne $null)
			{
			$myLUNObj = "" | Select LunUuid
			$myLUNObj.LunUuid = $LUNdiff
			ForEach ($VMHostView in $VMHostViews)
				{
				If (($VMHostView.Config.StorageDevice.ScsiLun | Where {$_.Uuid -eq $myLUNObj.LunUuid}) -ne $null)
					{
					$myLUNObj | Add-Member -MemberType NoteProperty -Name $VMHostView.Name -Value (($VMHostView.Config.StorageDevice.ScsiLun | Where {$_.Uuid -eq $myLUNObj.LunUuid}).CanonicalName)
					}
				Else
					{
					$myLUNObj | Add-Member -MemberType NoteProperty -Name $VMHostView.Name -Value $False
					}
				}
			$myLUNCol += $myLUNObj
			}
		}
	
	$myPGCol = @()
	$PortGroups = Get-VirtualPortGroup -VMHost $VMHosts | ForEach {$_.Name} | Select -Unique
	$PGdiffs = @()
	ForEach ($VMHost in $VMHosts)
		{
		$HostPGs = Get-VirtualPortGroup -VMHost $VMHost | ForEach {$_.Name} | Select -Unique
		$PGdiffs += Compare-Object $PortGroups $HostPGs -SyncWindow 1000 | ForEach {$_.InputObject}
		Clear-Variable HostPGs -ErrorAction SilentlyContinue
		}
	ForEach ($PGdiff in ($PGdiffs | Select -Unique | Sort))
		{
		If ($PGdiff -ne $null)
			{
			$myPGObj = "" | Select PortGroup
			$myPGObj.PortGroup = $PGdiff
			ForEach ($VMHost in $VMHosts)
				{
				$myPGObj | Add-Member -MemberType NoteProperty -Name $VMHost.Name -Value (!!(Get-VirtualPortGroup -Name $myPGObj.PortGroup -VMHost $VMHost -ErrorAction SilentlyContinue))
				}
			$myPGCol += $myPGObj
			}
		}
		
	$output+= '<h2>'
	$output += $Cluster.Name
	$output+= '</h2>'
	If ($myDSCol.Count -eq 0)
		{
		$output += '<p>'
		$output += "All datastores OK."
		$output += '</p>'
		}
	Else
		{
		$output += '<p>'
		$output += Create-HTMLTable $myDSCol
		$output += '</p>'
		}
		If ($myLUNCol.Count -eq 0)
		{
		$output += '<p>'
		$output += 'All LUNs OK.'
		$output += '</p>'
		}
	Else
		{
		$output += '<p>'
		$output += Create-HTMLTable $myLUNCol 
		$output += '</p>'
		}
	If ($myPGCol.Count -eq 0)
		{
		$output += '<p>'
		$output += "All portgroups OK."
		$output += '</p>'
		}
	Else
		{
		$output += '<p>'
		$output += Create-HTMLTable $myPGCol 
		$output += '</p>'
		}
	
	Clear-Variable VMHosts -ErrorAction SilentlyContinue
	Clear-Variable Datastores -ErrorAction SilentlyContinue
	Clear-Variable DSdiffs -ErrorAction SilentlyContinue
	Clear-Variable PortGroups -ErrorAction SilentlyContinue
	Clear-Variable PGdiffs -ErrorAction SilentlyContinue
	Clear-Variable LUNs -ErrorAction SilentlyContinue
	Clear-Variable LUNdiffs -ErrorAction SilentlyContinue
	}

$output += '</body></html>'	
$output | Out-File $outputFile -Force
ii $outputfile

Disconnect-VIServer -Confirm:$False