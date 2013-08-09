Function Get-LicenseKey {
 <#
.SYNOPSIS
  Retrieves License Key information
.DESCRIPTION
  This funtion will list all licence keys added to 
  vCenter Server
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.EXAMPLE 1
  PS> Get-LicenseKey
#>
 
  Process {
   $servInst = Get-View ServiceInstance
   $licMgr = Get-View (Get-View ServiceInstance).Content.licenseManager
   $licMgr.Licenses
  }
}

Get-LicenseKey
