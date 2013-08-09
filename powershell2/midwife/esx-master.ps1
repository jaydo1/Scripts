$verbose = $true
# To run as current user:
$VC = "localhost"; $VCpassword = $null
#$VC = '10.17.145.6' ; $VCpassword = 'CHANGEME'
$defaultESXPassword = ''
#$newESXPassword = $VCpassword
$newESXPassword = 'CHANGEME'

function getProfile($cfg) {
  log ("Name     - {0}" -f $sysInfo.Name)
  log ("Vendor   - {0}" -f $sysInfo.Vendor)
  log ("Model    - {0}" -f $sysInfo.Model)
  log ("UUID     - {0}" -f $sysInfo.UUID)
  log ("Hostname - {0}" -f $sysInfo.DNSHostname)
  log ("IP Addr  - {0}" -f $sysInfo.IPAddr)

# In theory this is where you can apply different profiles
# for different hosts - $sysInfo should have enough to help
# decide where this host goes
  return ".\esx-profile.ps1"
}
