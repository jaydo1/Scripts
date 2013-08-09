Function Set-LicenseKey {
 <#
.SYNOPSIS
  Sets a License Key for a host
.DESCRIPTION
  This funtion will set a license key for a host
  which is attached to a vCenter server
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER LicKey
  The License Key
.PARAMETER VMHost
  The vSphere host which to set the license on
.PARAMETER Name
  The friendly name to give the license key
.EXAMPLE 1
  PS> Set-LicenseKey -LicKey "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE" `
	-VMHost "esxhost01.mydomain.com" `
	-Name $null
#>

param( 
  [String]$VMHost, 
  [String]$LicKey, 
  [String]$Name
  )
  
  Process {
   $vmhostId = (Get-VMHost $VMHost | Get-View).Config.Host.Value
   $servInst = Get-View ServiceInstance
   $licMgr = Get-View $servInst.Content.licenseManager
   $licAssignMgr = Get-View $licMgr.licenseAssignmentManager

   $license = New-Object VMware.Vim.LicenseManagerLicenseInfo
   $license.LicenseKey = $LicKey
   $licAssignMgr.UpdateAssignedLicense($VMHostId, $license.LicenseKey, $Name)
   }
}

Set-LicenseKey -LicKey "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE" `
-VMHost "esxhost01.mydomain.com" `
-Name $null
