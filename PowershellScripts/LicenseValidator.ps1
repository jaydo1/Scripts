
#region Application Functions
#----------------------------------------------

function OnApplicationLoad {
	#Note: This function is not called in Projects
	#Note: This function runs before the form is created
	#Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
	#Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
	#Important: Form controls cannot be accessed in this function
	#TODO: Add snapins and custom code to validate the application load
	
	return $true #return true for success or false for failure
}

function OnApplicationExit {
	#Note: This function is not called in Projects
	#Note: This function runs after the form is closed
	#TODO: Add custom code to clean up and unload snapins when the application exits
	
	$script:ExitCode = 0 #Set the exit code for the Packager
}

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Call-vSphere_5_License_Checker_pff {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$HAandDRSForm = New-Object System.Windows.Forms.Form
	$picturebox6 = New-Object System.Windows.Forms.PictureBox
	$picturebox5 = New-Object System.Windows.Forms.PictureBox
	$location = New-Object System.Windows.Forms.TextBox
	$picturebox4 = New-Object System.Windows.Forms.PictureBox
	$picturebox3 = New-Object System.Windows.Forms.PictureBox
	$Password = New-Object System.Windows.Forms.TextBox
	$UserName = New-Object System.Windows.Forms.TextBox
	$ProgressTXT = New-Object System.Windows.Forms.TextBox
	$ExitBTN = New-Object System.Windows.Forms.Button
	$ConnectBTN = New-Object System.Windows.Forms.Button
	$vCenterTXT = New-Object System.Windows.Forms.TextBox
	$picturebox1 = New-Object System.Windows.Forms.PictureBox
	$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------

	
	
	
	
	function Write-CustomOut ($Details){
		$ProgressTXT.Text = "$Details"
		$ProgressTXT.Update()
	}
	
	
	Function Get-CustomHTML ($Header){
	$Report = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>$($Header)</title>
		<META http-equiv=Content-Type content='text/html; charset=windows-1252'>

		<style type="text/css">

		TABLE 		{
						TABLE-LAYOUT: fixed; 
						FONT-SIZE: 100%; 
						WIDTH: 100%
					}
		*
					{
						margin:0
					}

		.dspcont 	{
	
						BORDER-RIGHT: #bbbbbb 1px solid;
						BORDER-TOP: #bbbbbb 1px solid;
						PADDING-LEFT: 0px;
						FONT-SIZE: 8pt;
						MARGIN-BOTTOM: -1px;
						PADDING-BOTTOM: 5px;
						MARGIN-LEFT: 0px;
						BORDER-LEFT: #bbbbbb 1px solid;
						WIDTH: 95%;
						COLOR: #000000;
						MARGIN-RIGHT: 0px;
						PADDING-TOP: 4px;
						BORDER-BOTTOM: #bbbbbb 1px solid;
						FONT-FAMILY: Tahoma;
						POSITION: relative;
						BACKGROUND-COLOR: #f9f9f9
					}
					
		.filler 	{
						BORDER-RIGHT: medium none; 
						BORDER-TOP: medium none; 
						DISPLAY: block; 
						BACKGROUND: none transparent scroll repeat 0% 0%; 
						MARGIN-BOTTOM: -1px; 
						FONT: 100%/8px Tahoma; 
						MARGIN-LEFT: 43px; 
						BORDER-LEFT: medium none; 
						COLOR: #ffffff; 
						MARGIN-RIGHT: 0px; 
						PADDING-TOP: 4px; 
						BORDER-BOTTOM: medium none; 
						POSITION: relative
					}

		.pageholder	{
						margin: 0px auto;
					}
					
		.dsp
					{
						BORDER-RIGHT: #bbbbbb 1px solid;
						PADDING-RIGHT: 0px;
						BORDER-TOP: #bbbbbb 1px solid;
						DISPLAY: block;
						PADDING-LEFT: 0px;
						FONT-WEIGHT: bold;
						FONT-SIZE: 8pt;
						MARGIN-BOTTOM: -1px;
						MARGIN-LEFT: 0px;
						BORDER-LEFT: #bbbbbb 1px solid;
						COLOR: #FFFFFF;
						MARGIN-RIGHT: 0px;
						PADDING-TOP: 4px;
						BORDER-BOTTOM: #bbbbbb 1px solid;
						FONT-FAMILY: Tahoma;
						POSITION: relative;
						HEIGHT: 2.25em;
						WIDTH: 95%;
						TEXT-INDENT: 10px;
					}

		.dsphead0	{
						BACKGROUND-COLOR: #$($Colour1);
					}
					
		.dsphead1	{
						
						BACKGROUND-COLOR: #$($Colour2);
					}
					
	.dspcomments 	{
						BACKGROUND-COLOR:#FFFFE1;
						COLOR: #000000;
						FONT-STYLE: ITALIC;
						FONT-WEIGHT: normal;
						FONT-SIZE: 8pt;
					}

	td 				{
						VERTICAL-ALIGN: TOP; 
						FONT-FAMILY: Tahoma
					}
					
	th 				{
						VERTICAL-ALIGN: TOP; 
						COLOR: #$($Colour1); 
						TEXT-ALIGN: left
					}
					
	BODY 			{
						margin-left: 4pt;
						margin-right: 4pt;
						margin-top: 6pt;
					} 
	.MainTitle		{
						COLOR: #$($Colour2);
						background-color:#$($Colour2);
						font-family:Arial, Helvetica, sans-serif;
						font-size:20px;
						font-weight:bolder;
					}
	.SubTitle		{
						font-family:Arial, Helvetica, sans-serif;
						font-size:14px;
						font-weight:bold;
					}
	.Created		{
						font-family:Arial, Helvetica, sans-serif;
						font-size:10px;
						font-weight:normal;
						margin-top: 20px;
						margin-bottom:5px;
					}
	.links			{	font:Arial, Helvetica, sans-serif;
						font-size:10px;
						FONT-STYLE: ITALIC;
					}
					
		</style>
	</head>
	<body>
<div class="MainTitle"><IMG SRC="data:image/jpg;base64,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" ALT="License Validator"></center></div>
        <hr size="8" color="#$($Colour1)">
	        <div class="SubTitle">License Validator v$($version) generated on $($ENV:Computername)
"@
	Return $Report
	}
	
	Function Get-CustomHeader0 ($Title){
	$Report = @"
			<div class="pageholder">		
	
			<h1 class="dsp dsphead0">$($Title)</h1>
		
	    	<div class="filler"></div>
"@
	Return $Report
	}
	
	Function Get-CustomHeader ($Title, $cmnt){
	$Report = @"
		    <h2 class="dsp dsphead1">$($Title)</h2>
"@
	If ($Comments) {
	$Report += @"
				<div class="dsp dspcomments">$($cmnt)</div>
"@
		}
	$Report += @"
	        <div class="dspcont">
"@
		Return $Report
		}
	
	Function Get-CustomHeaderClose{
	$Report = @"
			</DIV>
			<div class="filler"></div>
"@
	Return $Report
	}
	
	Function Get-CustomHeader0Close{
	$Report = @"
		</DIV>
"@
	Return $Report
	}
	
	Function Get-CustomHTMLClose{
	$Report = @"
	</div>
	
	</body>
	</html>
"@
	Return $Report
	}
	
	Function Get-HTMLTable {
		param([array]$Content)
		$HTMLTable = $Content | ConvertTo-Html
		$HTMLTable = $HTMLTable -replace '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">', ""
		$HTMLTable = $HTMLTable -replace '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"  "http://www.w3.org/TR/html4/strict.dtd">', ""
		$HTMLTable = $HTMLTable -replace '<html xmlns="http://www.w3.org/1999/xhtml">', ""
		$HTMLTable = $HTMLTable -replace '<html>', ""
		$HTMLTable = $HTMLTable -replace '<head>', ""
		$HTMLTable = $HTMLTable -replace '<title>HTML TABLE</title>', ""
		$HTMLTable = $HTMLTable -replace '</head><body>', ""
		$HTMLTable = $HTMLTable -replace '</body></html>', ""
		$HTMLTable = $HTMLTable -replace '&lt;', "<"
		$HTMLTable = $HTMLTable -replace '&gt;', ">"
		Return $HTMLTable
	}
	
	Function Get-HTMLDetail ($Heading, $Detail){
	$Report = @"
	<TABLE>
		<tr>
		<th width='50%'><b>$Heading</b></font></th>
		<td width='50%'>$($Detail)</td>
		</tr>
	</TABLE>
"@
	Return $Report
	}
	
	Function Get-LicenseKey {
	  Process {
	   $servInst = Get-View ServiceInstance
	   $licMgr = Get-View (Get-View ServiceInstance).Content.licenseManager
	   $licMgr.Licenses
	  }
	}
	 
	function Get-License($VMHosts){
		$servInst = Get-View ServiceInstance
		$licMgr = Get-View $servInst.Content.licenseManager
		$licAssignMgr = Get-View $licMgr.licenseAssignmentManager
		$HostLic = @()
			$VMHosts | Foreach {
				$vmhostId = ("$($_.Id)").TrimStart("HostSystem-")
			    $license = $licAssignMgr.QueryAssignedLicenses($VMHostId)
			    if ($license) {
					$license = $license.GetValue(0)
				    $CurLic = New-Object -TypeName PSObject -Property @{
						Host = $license.EntityDisplayName
						CurrentLicenseType = $license.AssignedLicense.Name
						EditionKey = $license.AssignedLicense.EditionKey
					}
					$HostLic += $CurLic
				}
			}
			$HostLic
		}
	
	$FormEvent_Load={
	
	$location.Text = [system.Environment]::GetFolderPath('MyDocuments') + "\LV\"	
	}
	
	$savefiledialog1_FileOk=[System.ComponentModel.CancelEventHandler]{
	#Event Argument: $_ = [System.ComponentModel.CancelEventArgs]
		#TODO: Place custom script here
		
	}
	
	$picturebox1_Click={
		#TODO: Place custom script here
		
	}
	
	$RunBTN_Click={
	
		
	}
	
	$ConnectBTN_Click={
		if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
			add-pssnapin VMware.VimAutomation.Core 
		}
		$ProgressTXT.Text = "Connecting to $($vCenterTXT.Text)... Please Wait"
		$ProgressTXT.Update()
		If (! $Global:DefaultVIServer) {
			$VIServer = connect-viserver $vCenterTXT.Text -User $UserName.Text -Password $Password.Text
		}
		If ($VIServer.IsConnected -ne $true -and $global:DefaultVIServer.IsConnected -ne $true){
			$ProgressTXT.Text = "Unable to connect - please check connection details & try again"
		} Else {
			$ProgressTXT.Text = "Connected to $($vCenterTXT.Text)"
			$ProgressTXT.Update()
			$ConnectBTN.Enabled = $false
			$vCenterTXT.Enabled = $false
			
			
				If ($v5Licenses) {
					Remove-Variable v5Licenses
				}
				If ($v5EntPlus) {
					Remove-Variable v5EntPlus
				}
				If ($v5Ent) {
					Remove-Variable v5Ent
				}
				If ($v5Stand) {
					Remove-Variable v5Stand
				}
				If ($v5EPlus) {
					Remove-Variable v5EPlus
				}
				If ($v5E) {
					Remove-Variable v5E
				}
	
				###############################
				# vSphere Licensing Advisor   # 
				###############################
	
				$Version = "1.8"
				#
				# Changes:
				# Version 1.0 - Initail Script
				# Version 1.1 - Added Pooled license details
				# Version 1.2 - Fixed Typos
				# Version 1.3 - Fixed bug
				# Version 1.4 - Fixed bug with Essentials License
				# Version 1.5 - Fixed a bug where the first host has only 1 VM then additional vms on hosts dont get counted				
				# Version 1.6 - Sorted Licenses by Name as requested
				# Version 1.7 - Added Logfile for further debug info
				# Version 1.8 - Used Get-VMHost rather than Get-View hostsystem due to issues with sme environments				
				
				# Set if you would like to see the helpfull comments about areas of the checks
				$Comments = $false
	
				# Use the following area to define the colours of the report
				$Colour1 = "0D657B"
				$Colour2 = "2DA2B3"
	
				$Date = Get-Date
	
				$MyReport = Get-CustomHTML
					$MyReport += Get-CustomHeader0 "<IMG SRC='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAASCAMAAACO0hVbAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAMAUExURQAAAGulGGu1CHOtGHO1GITGIZTOQs6UGN6UEOelEO+lEPe1GP+9GP/eMf/3QqWlpb3ejNbW1v///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJSgEIQAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGXRFWHRTb2Z0d2FyZQBQYWludC5ORVQgdjMuNS44NzuAXQAAAH9JREFUKFNlkFsSgCAMA60PUAFR7n9XbEOLjuaPnbIlDPWfQZGz8FmZm6hlpIdRbnGU+xzlghgTFbMjBW/MzSLKJYXtYXBdJWzrm0HlOf0uXNG/d4g/xd2Xk3eN7S3C4g6X7OrMXLwMPWSuu6Q+mPZf2KWsan24jGl9uIx9f/UGXHiGdWNK+WcAAAAASUVORK5CYII=' ALT='vCenter'> $($VIServer.Name)"
						
						if (-not (test-path ([system.Environment]::GetFolderPath('MyDocuments') + "\LV\"))){
							MD ([system.Environment]::GetFolderPath('MyDocuments') + "\LV\") | Out-Null
						}
						$Logfile = $SaveFile = $Location.Text + $VIServer + "Logfile" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".txt"
						"All License Info" | out-file -Append -encoding ASCII -filepath $Logfile
						$AllLicKey = Get-LicenseKey
						$AllLicKey | Select EditionKey, Name, Total, Used | FL | out-file -Append -encoding ASCII -filepath $Logfile
				
						
						# ---- Current License Information ----
						Write-CustomOut "Current License Information"
						$LicenseInstalled = $AllLicKey | Where {$_.Name -like "vSphere*"} | Sort Name
	
						If (($LicenseInstalled | Measure-Object).count -gt 0) {
							$MyReport += Get-CustomHeader "Current License Information" "General details of the current clusters attached to this vCenter"
								$MyReport += Get-HTMLTable ($LicenseInstalled | Select Name, Total, @{Name="Deployed";Expression={$_.Used}})
							$MyReport += Get-CustomHeaderClose
						}
						
						Write-CustomOut "v5 License Information"
						$v5Licenses = @()	
						Foreach ($Lic in $LicenseInstalled) {
							switch ($Lic.EditionKey) {
								"esxEnterprisePlus" {
									$vRam = $Lic.Total * 48
									if ($v5EntPlus) {
										$v5EntPlus.Total += $Lic.Total
										$v5EntPlus.vRamGB += $vRam
									} Else {
										$v5EntPlus = New-Object -TypeName PSObject -Property @{
											Name = "vSphere 5 Enterprise Plus"
											Total = $Lic.Total
											vRamGB = $vRam
										}
									}
								}
								"esxEnterprise" {
									$vRam = $Lic.Total * 32
									if ($v5Ent) {
										$v5Ent.Total += $Lic.Total
										$v5Ent.vRamGB += $vRam
									} Else {
											$v5Ent = New-Object -TypeName PSObject -Property @{
											Name = "vSphere 5 Enterprise"
											Total = $Lic.Total
											vRamGB = $vRam
										}
									}
								}
								"esxAdvanced" {
									$vRam = $Lic.Total * 32
									If ($v5Ent) {
										$v5Ent.Total = $v5Ent.Total + $Lic.Total
										$v5Ent.vRamGB = $v5Ent.vRamGB + $vRam
									} Else {
										$v5Ent = New-Object -TypeName PSObject -Property @{
											Name = "vSphere 5 Enterprise"
											Total = $Lic.Total
											vRamGB = $vRam
										}
									}
								}
								"esxFull" {
									$vRam = $Lic.Total * 24
									if ($v5Stand) {
										$v5Stand.Total += $Lic.Total
										$v5Stand.vRamGB += $vRam
									} Else {
										$v5Stand = New-Object -TypeName PSObject -Property @{
											Name = "vSphere 5 Standard"
											Total = $Lic.Total
											vRamGB = $vRam
										}
									}
								}
								"esxExpressPlus" {
									$vRam = $Lic.Total * 24
									if ($v5EPlus) {
										$v5EPlus.Total += $Lic.Total
										$v5EPlus.vRamGB += $vRam
									} Else {
										$v5EPlus = New-Object -TypeName PSObject -Property @{
											Name = "vSphere 5 Essentials Plus"
											Total = $Lic.Total
											vRamGB = $vRam
										}
									}
								}
								"esxExpress" {
									$vRam = $Lic.Total * 24
									if ($v5E) {
										$v5E.Total += $Lic.Total
										$v5E.vRamGB += $vRam
									} Else {
										$v5E = New-Object -TypeName PSObject -Property @{
											Name = "vSphere 5 Essentials"
											Total = $Lic.Total
											vRamGB = $vRam
										}
									}
								}
								default {
								}
							}
						}
	
						$v5Licenses += $v5EntPlus
						$v5Licenses += $v5Ent
						$v5Licenses += $v5Stand
						$v5Licenses += $v5EPlus
						$v5Licenses += $v5E
						
						# ---- New License Information ----
						Write-CustomOut "Adding v5 License Information"
						If (($v5Licenses | Measure-Object).count -gt 0) {
							$MyReport += Get-CustomHeader "vSphere 5 Equivalent License Information"
							$MyReport += Get-HTMLTable ($v5Licenses | Select Name, Total, @{Name="Pooled vRam Capacity (GB)";Expression={$_.vRamGB}})
							$MyReport += Get-CustomHeaderClose
						}
						
						# Get All Hosts	
						Write-CustomOut "Retrieving host information"
						$vmhosts = Get-VMHost | Sort Name
						"Host Info" | out-file -Append -encoding ASCII -filepath $Logfile
						$vmhosts | Select Name, ConnectionState | FL | out-file -Append -encoding ASCII -filepath $Logfile
						$HostLicenses = Get-License $vmhosts
						"Host Licenses" | out-file -Append -encoding ASCII -filepath $Logfile
						$HostLicenses | FL | out-file -Append -encoding ASCII -filepath $Logfile
						
						# Enterprise Plus Licence Info						
						Write-CustomOut "Working out Enterprise Plus Licence Info"
						If ($v5EntPlus) {
							$EntPlusLic = $HostLicenses | Where { $_.EditionKey -eq "esxEnterprisePlus" }
							if ($EntPlusLic ) {
								$v5EntPlusAllVM = @()
								$EntPlusLic | Foreach {
									$v5EntPlusAllVM += Get-VMHost $_.Host | Get-VM
								}
								$v5EntPlusPoweredonVM += $v5EntPlusAllVM | Where { $_.Powerstate -eq "PoweredOn" }
								$v5EntPlusCurrentvRam += [Math]::Round((($v5EntPlusPoweredonVM | Measure-Object -Sum MemoryMB).Sum / 1024), 0)
								$v5EntPlusAllvRAM += [Math]::Round((($v5EntPlusAllVM | Measure-Object -Sum MemoryMB).Sum / 1024), 0)
							}
							$MyReport += Get-CustomHeader "Enterprise Plus License Details"
									$MyReport += Get-CustomHeader "vRam Details" ""
										$MyReport += Get-HTMLDetail "Pooled vRam Capacity:" "$($v5EntPlus.vRamGB) GB"
										$MyReport += Get-HTMLDetail "Number of VMs Powered On:" ($v5EntPlusPoweredonVM | Measure-Object ).Count
										$MyReport += Get-HTMLDetail "Current vRam usage:" "$v5EntPlusCurrentvRam GB"
										$MyReport += Get-HTMLDetail "Percent vRam usage:" "$([math]::truncate($v5EntPlusCurrentvRam / ($v5EntPlus.vRamGB)* 100))%"
										$MyReport += Get-HTMLDetail "Number of VMs if all were Powered on:" ($v5EntPlusAllVM | Measure-Object).Count
										$MyReport += Get-HTMLDetail "vRam usage if all VMs were Powered on:" "$v5EntPlusAllvRAM GB"
										$MyReport += Get-HTMLDetail "Percent vRam usage if all VMs were Powered on:" "$([math]::truncate($v5EntPlusAllvRAM / ($v5EntPlus.vRamGB)* 100))%"
									$MyReport += Get-CustomHeaderClose
									if ($EntPlusLic ) {
									$MyReport += Get-CustomHeader "The following hosts will be assigned Enterprise Plus Licenses:" ""
										$MyReport += Get-HTMLTable ($EntPlusLic | Select Host, CurrentLicenseType)
									$MyReport += Get-CustomHeaderClose
									}
							$MyReport += Get-CustomHeaderClose
						}
						
						# Enterprise Licence Info						
						Write-CustomOut "Working out Enterprise Licence Info"
						If ($v5Ent) {
							$EntLic = $HostLicenses | Where { $_.EditionKey -eq "esxEnterprise" -or $_.EditionKey -eq "EsxAdvanced" }
							if ($EntLic) {
								$v5EntAllVM = @()
								$EntLic | Foreach {
									$v5EntAllVM += Get-VMHost $_.Host | Get-VM
								}
								$v5EntPoweredOnVM = $v5EntAllVM | Where { $_.Powerstate -eq "PoweredOn" }
								$v5EntCurrentvRam += [Math]::Round((($v5EntPoweredOnVM | Measure-Object -Sum MemoryMB).Sum / 1024), 0)
								$v5EntAllvRAM += [Math]::Round((($v5EntAllVM | Measure-Object -Sum MemoryMB).Sum / 1024),0)
							}
							$MyReport += Get-CustomHeader "Enterprise License Details"
									$MyReport += Get-CustomHeader "vRam Details" ""
										$MyReport += Get-HTMLDetail "Pooled vRam Capacity:" "$($v5Ent.vRamGB) GB"
										$MyReport += Get-HTMLDetail "Number of VMs Powered On:" ($v5EntPoweredOnVM | Measure-Object ).Count
										$MyReport += Get-HTMLDetail "Current vRam usage:" "$v5EntCurrentvRam GB"
										$MyReport += Get-HTMLDetail "Percent vRam usage:" "$([math]::truncate($v5EntCurrentvRam / ($v5Ent.vRamGB)* 100))%"
										$MyReport += Get-HTMLDetail "Number of VMs if all were Powered on:" ($v5EntAllVM | Measure-Object).Count
										$MyReport += Get-HTMLDetail "vRam usage if all VMs were Powered on:" "$v5EntAllvRAM GB"
										$MyReport += Get-HTMLDetail "Percent vRam usage if all VMs were Powered on:" "$([math]::truncate($v5EntAllvRAM / ($v5Ent.vRamGB)* 100))%"
									$MyReport += Get-CustomHeaderClose
								if ($EntLic) {
									$MyReport += Get-CustomHeader "The following hosts will be assigned Enterprise Licenses:" ""
										$MyReport += Get-HTMLTable ($EntLic | Select Host, CurrentLicenseType)
									$MyReport += Get-CustomHeaderClose
								}
							$MyReport += Get-CustomHeaderClose
						}
						
						# Standard Licence Info						
						Write-CustomOut "Working out Standard Licence Info"
						If ($v5Stand) {
							$StandLic = $HostLicenses | Where { $_.EditionKey -eq "esxFull" }
							if ($StandLic){
								$v5StandAllVM = @()
								$StandLic | Foreach {
									$v5StandAllVM += Get-VMHost $_.Host | Get-VM
								}
								$v5StandPoweredOnVM = $v5StandAllVM | Where { $_.Powerstate -eq "PoweredOn" }
								$v5StandCurrentvRam += [Math]::Round((($v5StandPoweredOnVM | Measure-Object -Sum MemoryMB).Sum / 1024), 0)
								$v5StandAllvRAM += [Math]::Round((($v5StandAllVM | Measure-Object -Sum MemoryMB).Sum / 1024),0)
							}
							$MyReport += Get-CustomHeader "Standard License Details"
								$MyReport += Get-CustomHeader "vRam Details" ""
									$MyReport += Get-HTMLDetail "Pooled vRam Capacity:" "$($v5Stand.vRamGB) GB"
									$MyReport += Get-HTMLDetail "Number of VMs Powered On:" ($v5StandPoweredOnVM | Measure-Object ).Count
									$MyReport += Get-HTMLDetail "Current vRam usage:" "$v5StandCurrentvRam GB"
									$MyReport += Get-HTMLDetail "Percent vRam usage:" "$([math]::truncate($v5StandCurrentvRam / ($v5Stand.vRamGB)* 100))%"
									$MyReport += Get-HTMLDetail "Number of VMs if all were Powered on:" ($v5StandAllVM | Measure-Object).Count
									$MyReport += Get-HTMLDetail "vRam usage if all VMs were Powered on:" "$v5StandAllvRAM GB"
									$MyReport += Get-HTMLDetail "Percent vRam usage if all VMs were Powered on:" "$([math]::truncate($v5StandAllvRAM / ($v5Stand.vRamGB)* 100))%"
								$MyReport += Get-CustomHeaderClose
								if ($StandLic) {
									$MyReport += Get-CustomHeader "The following hosts will be assigned Standard Licenses:" ""
										$MyReport += Get-HTMLTable ($StandLic | Select Host, CurrentLicenseType)
									$MyReport += Get-CustomHeaderClose
								}
							$MyReport += Get-CustomHeaderClose
						}
								
						# Essentials Plus Info						
						Write-CustomOut "Working out Essentials Plus Licence Info"
						If ($v5EPlus) {
							$EPlusLic = $HostLicenses | Where { $_.EditionKey -eq "esxExpressPlus" }
							if ($EPlusLic){
								$v5EPlusAllVM = @()
								$EPlusLic | Foreach {
									$v5EPlusAllVM += Get-VMHost $_.Host | Get-VM
								}
								$v5EPlusPoweredOnVM = $v5EPlusAllVM | Where { $_.Powerstate -eq "PoweredOn" }
								$v5EPlusCurrentvRam += [Math]::Round((($v5EPlusPoweredOnVM | Measure-Object -Sum MemoryMB).Sum / 1024), 0)
								$v5EPlusAllvRAM += [Math]::Round((($v5EPlusAllVM | Measure-Object -Sum MemoryMB).Sum / 1024),0)
							}
							$MyReport += Get-CustomHeader "Essentials Plus License Details"
								$MyReport += Get-CustomHeader "vRam Details" ""
									$MyReport += Get-HTMLDetail "Pooled vRam Capacity:" "$($v5EPlus.vRamGB) GB"
									$MyReport += Get-HTMLDetail "Number of VMs Powered On:" ($v5EPlusPoweredOnVM | Measure-Object ).Count
									$MyReport += Get-HTMLDetail "Current vRam usage:" "$v5EPlusCurrentvRam GB"
									$MyReport += Get-HTMLDetail "Percent vRam usage:" "$([math]::truncate($v5EPlusCurrentvRam / ($v5EPlus.vRamGB)* 100))%"
									$MyReport += Get-HTMLDetail "Number of VMs if all were Powered on:" ($v5EPlusAllVM | Measure-Object).Count
									$MyReport += Get-HTMLDetail "vRam usage if all VMs were Powered on:" "$v5EPlusAllvRAM GB"
									$MyReport += Get-HTMLDetail "Percent vRam usage if all VMs were Powered on:" "$([math]::truncate($v5EPlusAllvRAM / ($v5EPlus.vRamGB)* 100))%"
								$MyReport += Get-CustomHeaderClose
								if ($EPlusLic) {
									$MyReport += Get-CustomHeader "The following hosts will be assigned Essentials Plus Licenses:" ""
										$MyReport += Get-HTMLTable ($EPlusLic | Select Host, CurrentLicenseType)
									$MyReport += Get-CustomHeaderClose
								}
							$MyReport += Get-CustomHeaderClose
						}
						
						# Essentials Info						
						Write-CustomOut "Working out Essentials Licence Info"
						If ($v5e) {
							$ELic = $HostLicenses | Where { $_.EditionKey -eq "esxExpress" }
							if ($ELic){
								$v5EAllVM = @()
								$ELic | Foreach {
									$v5EAllVM += Get-VMHost $_.Host | Get-VM
								}
								$v5EPoweredOnVM = $v5EAllVM | Where { $_.Powerstate -eq "PoweredOn" }
								$v5ECurrentvRam += [Math]::Round((($v5EPoweredOnVM | Measure-Object -Sum MemoryMB).Sum / 1024), 0)
								$v5EAllvRAM += [Math]::Round((($v5EAllVM | Measure-Object -Sum MemoryMB).Sum / 1024),0)
							}
							$MyReport += Get-CustomHeader "Essentials License Details"
								$MyReport += Get-CustomHeader "vRam Details" ""
									$MyReport += Get-HTMLDetail "Pooled vRam Capacity:" "$($v5E.vRamGB) GB"
									$MyReport += Get-HTMLDetail "Number of VMs Powered On:" ($v5EPoweredOnVM | Measure-Object ).Count
									$MyReport += Get-HTMLDetail "Current vRam usage:" "$v5ECurrentvRam GB"
									$MyReport += Get-HTMLDetail "Percent vRam usage:" "$([math]::truncate($v5ECurrentvRam / ($v5E.vRamGB)* 100))%"
									$MyReport += Get-HTMLDetail "Number of VMs if all were Powered on:" ($v5EAllVM | Measure-Object).Count
									$MyReport += Get-HTMLDetail "vRam usage if all VMs were Powered on:" "$v5EAllvRAM GB"
									$MyReport += Get-HTMLDetail "Percent vRam usage if all VMs were Powered on:" "$([math]::truncate($v5EAllvRAM / ($v5E.vRamGB)* 100))%"
								$MyReport += Get-CustomHeaderClose
								if ($ELic) {
									$MyReport += Get-CustomHeader "The following hosts will be assigned Essentials Licenses:" ""
										$MyReport += Get-HTMLTable ($ELic | Select Host, CurrentLicenseType)
									$MyReport += Get-CustomHeaderClose
								}
								$MyReport += Get-CustomHeaderClose
						}
						$MyReport += Get-CustomHeaderClose
								
					$MyReport += Get-CustomHeader0Close
				$MyReport += Get-CustomHTMLClose
	
				Write-CustomOut "Displaying HTML results"
				if (-not (test-path ([system.Environment]::GetFolderPath('MyDocuments') + "\LV\"))){
					MD ([system.Environment]::GetFolderPath('MyDocuments') + "\LV\") | Out-Null
				}
				$Filename = $SaveFile = $Location.Text + $VIServer + "LicenseValidator" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
				$MyReport | out-file -encoding ASCII -filepath $Filename
				Invoke-Item $Filename
				Write-CustomOut "Report saved to $Filename"
		}		
	}
	
	$ExitBTN_Click={
		If ($VIServer) {
			Disconnect-VIServer -Confirm:$false
		}
		$HAandDRSForm.Close()
	}
	
	
	$picturebox6_Click={
		#TODO: Place custom script here
		
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	# Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$HAandDRSForm.WindowState = $InitialFormWindowState
	}

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$HAandDRSForm.Controls.Add($picturebox6)
	$HAandDRSForm.Controls.Add($picturebox5)
	$HAandDRSForm.Controls.Add($location)
	$HAandDRSForm.Controls.Add($picturebox4)
	$HAandDRSForm.Controls.Add($picturebox3)
	$HAandDRSForm.Controls.Add($Password)
	$HAandDRSForm.Controls.Add($UserName)
	$HAandDRSForm.Controls.Add($ProgressTXT)
	$HAandDRSForm.Controls.Add($ExitBTN)
	$HAandDRSForm.Controls.Add($ConnectBTN)
	$HAandDRSForm.Controls.Add($vCenterTXT)
	$HAandDRSForm.Controls.Add($picturebox1)
	$HAandDRSForm.BackColor = [System.Drawing.Color]::FromArgb(255,240,240,240)
	$HAandDRSForm.ClientSize = New-Object System.Drawing.Size(327,312)
	$HAandDRSForm.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$HAandDRSForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D 
	#region Binary Data
	$HAandDRSForm.Icon = [System.Convert]::FromBase64String("AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAAAAAABMLAAATCwAAEAAA
AAAAAADu7u4A1tXVAMzKygCqp6cAaGNjAJWSkQB7eHcAu7m4AI6KigBwbGsA5eTkAKGengBhXVwA
U05NAISAfwAAAAAA9t3d3d3d3W9t3d3d3d3d1t3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3LnUvN
udiN3TAtUGQD0B3UqgmAZAPQHdsOp4BsC9Ad2i0wIDUC4C3anUEBEKIKXd3d3d3d3d3d3d3d3d3d
3d3d3d3d3d3d3W3d3d3d3d3W9t3d3d3d3W+AAQAAAAAAAAAAAAAAAAAAAAAAAAAAAG4AAAB0AAAA
IAAAAAAAAAAAAAAAIAAAAGYAAABTAAAAdgAAAG6AAQwA")
	#endregion
	$HAandDRSForm.MaximizeBox = $False
	$HAandDRSForm.Name = "vSphereLicensingAdvisor"
	$HAandDRSForm.Text = "License Validator"
	$HAandDRSForm.add_Load($FormEvent_Load)
	#
	# picturebox6
	#
	$picturebox6.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	#region Binary Data
	$picturebox6.Image = [System.Convert]::FromBase64String("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")
	#endregion
	#region Binary Data
	#endregion
	$picturebox6.Location = New-Object System.Drawing.Point(0,0)
	$picturebox6.Name = "picturebox6"
	$picturebox6.Size = New-Object System.Drawing.Size(329,126)
	$picturebox6.TabIndex = 17
	$picturebox6.TabStop = $False
	$picturebox6.add_Click($picturebox6_Click)
	#
	# picturebox5
	#
	$picturebox5.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	#region Binary Data
	$picturebox5.Image = [System.Convert]::FromBase64String("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")
	#endregion
	$picturebox5.Location = New-Object System.Drawing.Point(7,229)
	$picturebox5.Name = "picturebox5"
	$picturebox5.Size = New-Object System.Drawing.Size(23,20)
	$picturebox5.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom 
	$picturebox5.TabIndex = 16
	$picturebox5.TabStop = $False
	#
	# location
	#
	$location.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$location.Location = New-Object System.Drawing.Point(36,229)
	$location.Name = "location"
	$location.Size = New-Object System.Drawing.Size(282,20)
	$location.TabIndex = 4
	#
	# picturebox4
	#
	$picturebox4.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	#region Binary Data
	$picturebox4.Image = [System.Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAA65JREFU
SEutln1M1HUcx+9E3PKhdGnGzGo1NWq0Bg0b1Fat0QNuVvMPEqWZ1aHA8WADCY4COeIpHB2W4SDQ
NctoasodTweYPIsBCoKK8yxEOQQOOLjjHnj1/f3RZmz98+u+22+fvz7v1+f9/n2+21eh8MBRqVQt
MdHRo6Le+SAs7LQHJP8tER0VNXqoqAiNRkNMTIwlVq2+lZ+X5/oiLc3uEVhljOLkL3FrJ/WZL81/
G/n0VOEun/jU7ZsWS+JbQkMjfigtZUd4uF42rFKtrO0uD2fSZGDe3gGOTuYslzCd+wZj6ro2McBG
AUo8Wl7OhxERZ2SB9LFexr+aDoK1BKZTRE3FbUlmevBT3NYjzJo7KVIH3tNqtTadTmeTBZGa+k5E
wtB+GP4YxhJw3I2l63vf0cbDwe5izSt8nZfEwYICkhL2zsmGGOKWNNsHi6Hndbi6FW7tYLj6VTI/
V5mztFpyc3JITdnHj2WJnNeFIhvUnB9gpy8emvygMwh632S86ytKU152FWaqbL9mBzM3lizi1GBq
OCAf1FXyDvyxC2ofg8YN0OoPlkZG29MYqgrDadoD4/tgKpnbbemIpciW5aqj0H+OAS3oV0O1D9Q9
AS2BYMoVMWbAtfdE3QnmKG5U7ZXvqC552QW3uQ7OClDlKjA8AjXroP4paH4eLgZD31twczctBYHy
QSKKnHutsXBdB6eWwpkHhbuHoepREed6OLcR2gKYaFVJsV2TFZvUZNz/wMRE/YvMXc8WcZULyJNw
eplwuFK4WyOc+eLs2kOrdrVTNkSvVjYNnXoBa1MQjo5AXJe24LhZhnvwMO4rB3D2JGFpCKcza/m0
bIiIIb3n0OPMdIQw+/tm5vuCGfttA22Zy6lO8KI+ydthTFw8oFcr8mRDpMbGlKVOa+dWrA2bcV0O
wdYUIIl3/S/Rhc2GWKVppO4NZtrfFoAg3APvMnLcR/rZGR4DCbGf+kuewda/m2mDL/OmT5ipfQ7z
sZUSqN5joPNfrsA+GIfVKDat+30cl7dhOb6C3lxv+Xdk4XRVccqpiY6d2Lq3YzU8y/xIBlMVa7hz
xJuaeEWtR9xIkQ0c88c5nMlkxVpcf2qYbQ6hP3+RozZBUewRiCQiQMbbZ1/D3vsRM/XBuO7mcUO3
xHNx3T/p1dJNwlEWUyfXi+j8GPpukbQAOR5z84/QxeyHcE+XMfnzKsbLvLiQrvTMi2bhpDUJyivm
9kiGK/wwfqYY9riT+wVFVCfEJ+8V8x+T/Q27EW04KpCVmwAAAABJRU5ErkJggg==")
	#endregion
	$picturebox4.Location = New-Object System.Drawing.Point(8,202)
	$picturebox4.Name = "picturebox4"
	$picturebox4.Size = New-Object System.Drawing.Size(21,20)
	$picturebox4.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom 
	$picturebox4.TabIndex = 14
	$picturebox4.TabStop = $False
	#
	# picturebox3
	#
	$picturebox3.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	#region Binary Data
	$picturebox3.Image = [System.Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAB4AAAAdCAYAAAC9pNwMAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAA1pJREFU
SEu9VmtIk2EY9YfiVCIYQmgIiv0QxUAF/xhOQkUhhMUKMlKCFDUiUCTwkpUVpJl5iWF5t3RZKWmW
l7wbs/Iy856WlZcU+6M2I107Pd+3TR05fYW1wWFj3/me85zzPN+7mZnt8VUUIygnTBF+azFB7zl7
LMNOp+KlBOyAFfZqjMz8KEFmoVa0+LwVKmKFhhpYZSzJRsuLtFoncVTGH8BcbTSW2xJI3NaQeA1b
VQaW9JwVZPEH8bM9CehNJ9zGfH0cyi7u305cxVByd0r2WesKacQ+LDbEakVJuO8OMJSPpbdZkOeF
oDr5EOquH0ZXrj/fyO5VGRiZ4TaNr9OPbIpyjvuzgJFiYLIK+NoAfGsCpl5ANVyKijhb4whnhNnU
ztRc0BdW5ACjZcDnWmCmDZjtpAYagYkn6JYGGUeYC2Wtlxzys9ViIBcYewR8eQnMvQEW3gPTLXwC
c/WXfjAEyUZRDxVsI1xOwq+A793AokLj/FM1fvXkVrFVZWDx8+zL+NfxVJ3WcQ8Jt/LCq++yShhK
slHUg/mAYkvcimyacSnNuEbjdK5Ls2CTz7AizzDe8bnWm6PCwL1Nx/13geEiXojf6ulmzbw/Pjbe
YnGZrMpvLeKDdMtzTLEP3QfGZeT6Of8ocTFj7KFxhZfbrzbzQnqbTQmMlpDLSnqMnmqaGC40rjDn
+o+ChLjZ6sS5uLlmuFmTU4yUQClPW2Dbmj2ylF03VOjP3DivwR0kgyTOHZ/tqcZ3q+tvqTlBvdyS
iPXumxpxesRUPRlYar3Mf7dHH+x0XcyrnVew3JpISIKyI2UjfvZKjExvb++6lrzoFb3l0s2aYtbF
X5ByatrDw6OIsaw+zc3NrZCERvz8/FRisRgSiYRHZPhJzNbrfo+1ZzY34wnaampiviEZEWEnNvgh
ISEQiUTrVGvc3d1dZrAZJycnWWBgIIKDgw0iVHIMjdIYKLtSoe5Jg5r+ECy1X0NdThRO07Wd7vX1
9d3+D4KPjw/oIhOC/P1w5ngAQsX+CDgqYrqHq+3q6jqr59zR0XHQy8sL/xuenp76m+/s7AwXFxeT
wM7ObmjDtYODA0wFe3t7jWtra+smoVAIU0IgEDwws7CwGLe0tIQpYW5uPqmLW04fuAhMgQ5O9C8K
ovh0w//cSgAAAABJRU5ErkJggg==")
	#endregion
	$picturebox3.Location = New-Object System.Drawing.Point(7,176)
	$picturebox3.Name = "picturebox3"
	$picturebox3.Size = New-Object System.Drawing.Size(22,20)
	$picturebox3.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom 
	$picturebox3.TabIndex = 13
	$picturebox3.TabStop = $False
	#
	# Password
	#
	$Password.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$Password.Location = New-Object System.Drawing.Point(36,202)
	$Password.Name = "Password"
	$Password.PasswordChar = '*'
	$Password.Size = New-Object System.Drawing.Size(282,20)
	$Password.TabIndex = 3
	#
	# UserName
	#
	$UserName.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$UserName.Location = New-Object System.Drawing.Point(36,176)
	$UserName.Name = "UserName"
	$UserName.Size = New-Object System.Drawing.Size(282,20)
	$UserName.TabIndex = 2
	$UserName.Text = "Username"
	#
	# ProgressTXT
	#
	$ProgressTXT.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$ProgressTXT.Enabled = $False
	$ProgressTXT.Location = New-Object System.Drawing.Point(0,294)
	$ProgressTXT.Name = "ProgressTXT"
	$ProgressTXT.Size = New-Object System.Drawing.Size(329,20)
	$ProgressTXT.TabIndex = 8
	$ProgressTXT.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center 
	#
	# ExitBTN
	#
	$ExitBTN.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$ExitBTN.Location = New-Object System.Drawing.Point(189,255)
	$ExitBTN.Name = "ExitBTN"
	$ExitBTN.Size = New-Object System.Drawing.Size(129,23)
	$ExitBTN.TabIndex = 6
	$ExitBTN.Text = "Exit"
	$ExitBTN.UseVisualStyleBackColor = $True
	$ExitBTN.add_Click($ExitBTN_Click)
	#
	# ConnectBTN
	#
	$ConnectBTN.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$ConnectBTN.Location = New-Object System.Drawing.Point(36,255)
	$ConnectBTN.Name = "ConnectBTN"
	$ConnectBTN.Size = New-Object System.Drawing.Size(129,23)
	$ConnectBTN.TabIndex = 5
	$ConnectBTN.Text = "Connect"
	$ConnectBTN.UseVisualStyleBackColor = $True
	$ConnectBTN.add_Click($ConnectBTN_Click)
	#
	# vCenterTXT
	#
	$vCenterTXT.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	$vCenterTXT.Location = New-Object System.Drawing.Point(36,149)
	$vCenterTXT.Name = "vCenterTXT"
	$vCenterTXT.Size = New-Object System.Drawing.Size(282,20)
	$vCenterTXT.TabIndex = 1
	$vCenterTXT.Text = "vCenter"
	#
	# picturebox1
	#
	$picturebox1.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
	#region Binary Data
	$picturebox1.Image = [System.Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAABMAAAASCAYAAAC5DOVpAAAAAXNSR0IArs4c6QAAAARnQU1BAACx
jwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlz
AAAOuQAADrkBuAYXvwAAAOBJREFUOE+9kyEWwjAMhieRyFqOwBV2nUmugET2CpXIyVnkZGUtEjkZ
mtKOdEvTAe/R92K2vG/ptz9N86+jxxZqtWkWhJyuCjojVL8L76tAhGGjMaZYtEcE0kYoHBG29JMm
C6ypBXBHmHoFo1bhUREWHPnGpSO8ZjgRdDf7bTDOkbX2NZj/EIKc/hDGKcKr0apek3MEw9vR8iOi
swzmHSHoQRwN7pKFuIs5Q69ZNFZRiCDOEf1JKYcirOaIhnkV2J9DSokJJi32+XaYV6y6j+JSx4Vn
HXFkaalFR9Uxv2h4AlX7X1Q4uiifAAAAAElFTkSuQmCC")
	#endregion
	$picturebox1.Location = New-Object System.Drawing.Point(8,149)
	$picturebox1.Name = "picturebox1"
	$picturebox1.Size = New-Object System.Drawing.Size(21,21)
	$picturebox1.TabIndex = 2
	$picturebox1.TabStop = $False
	$picturebox1.add_Click($picturebox1_Click)
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $HAandDRSForm.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$HAandDRSForm.add_Load($Form_StateCorrection_Load)
	#Show the Form
	return $HAandDRSForm.ShowDialog()

} #End Function

#Call OnApplicationLoad to initialize
if(OnApplicationLoad -eq $true)
{
	#Create the form
	Call-vSphere_5_License_Checker_pff | Out-Null
	#Perform cleanup
	OnApplicationExit
}
