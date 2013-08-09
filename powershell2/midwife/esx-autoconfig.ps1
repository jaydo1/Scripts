# esx-autoconfig.ps1 [hostname|ipaddress]

& {
  $ErrorActionPreference = "silentlycontinue"
  $vmwareSnap = get-pssnapin -name "VMware.VimAutomation.Core"
  if (! $?) { add-pssnapin "VMware.VimAutomation.Core" }
}

. .\esx-master.ps1

#$ErrorActionPreference = "silentlycontinue"
 
function configureNetworking($h) {
  $hs = Get-View $h.ID
  $ns = $hs.configManager.networkSystem
  $mor = Get-View $ns

  $nicmapping = @{}
  foreach ($pnic in $hs.config.network.pnic) {
    $device = $pnic.device
    # We're talking to it via vmnic0, so don't reconfigure it.  This is ugly
    if ($device -eq "vmnic0") { continue }
    $vs = $nicAssignments.$device
    if ($vs -eq $null) {
      $vs = $nicAssignments.default
    }
    if ($vs -eq $null) {
      log "$device not assigned to a virtual switch"
      continue
    }
	       
    if ($vswitches.keys -notcontains $vs) {
      log "Virtual switch $vs not defined"
      continue
    }
    $nicmapping.$vs += @( $device )
  }

  foreach ($sw in $vswitches.keys) {
    if ($sw -eq "vSwitch0") {
      # Special case vSwitch0 since it already exists and is what we're talking through
      Get-VirtualSwitch --VMhost $h | % {
        if (($_.Name -eq "vSwitch0") -and ($nicmapping.$sw -ne $null)) {
          $newSwitch = Set-VirtualSwitch -VirtualSwitch $_ -Nic $nicmapping.$sw
          if (! $?) { log "Properties on vSwitch0 failed" }
        }
      }
      continue
    }

    if ($verbose) { log "Create Virtual Switch $sw" }
    if ($nicmapping.keys -contains $sw) {
      $newSwitch = New-VirtualSwitch -VMHost $h -Name $sw -NumPorts $vswitches.$sw.numports -Nic $nicmapping.$sw
    } else {
      $newSwitch = New-VirtualSwitch -VMHost $h -Name $sw -NumPorts $vswitches.$sw.numports
    }
    if (! $?) { log "New Virtual Switch {0} failed" -f $sw }
  }

  foreach ($pg in $portgroups.keys) {
    if ($verbose) { log "Create Portgroup $pg" }
    $vsw = Get-Virtualswitch -VMHost $h -Name $portgroups.$pg.vSwitch
    $newPortGroup = New-VirtualPortGroup -VirtualSwitch $vsw -Name $pg
    if (! $?) { log "New Port Group {0} on {1} failed" -f $pg, $vsw.Name }
  }
}
     
function configureNFSStorage($h) {
  foreach ($n in $nas) {
    if ($verbose) { log ('Mount NFS filestore {0}:{1}' -f $n.host, $n.path) }
    if ($n.mode -eq "readOnly") {
      $newDS = New-Datastore -VMHost $h -name $n.ds -Path $n.path -NFS -NFShost $n.host -readOnly
    } else {
      $newDS = New-Datastore -VMHost $h -name $n.ds -Path $n.path -NFS -NFShost $n.host
    }
    if (! $?) { log ("Mounting {0}:{1} failed" -f $n.host, $n.path) }
  }
}

function configureISCSIStorage($h) {
  if ($iSCSI.length -eq 0) { return }
  $ErrorActionPreference = "continue"

  $is = $null
  $hv = Get-View $h.ID
  $ss = $hv.ConfigManager.StorageSystem
  $mor = Get-View $ss
  if ($verbose) { log "Enable SW iSCSI" }
  $mor.UpdateSoftwareInternetScsiEnabled($true)
  # Have to get the view again since enabling SW iSCSI creates devices
  $mor = Get-View $ss
  $sdi = $mor.storageDeviceInfo
  $sdi.HostBusAdapter | % { if ($_.IsSoftwareBased) { $is = $_ } }
  if (!$is) { log "No SW iSCSI HBA found"; return }

  if ($verbose) {
    log ("SW iSCSI device {0}" -f $is.device)
    log ("SW iSCSI name   {0}" -f $is.iSCSIName)
    log ("SW iSCSI alias  {0}" -f $is.iSCSIAlias)
  }
  
  $iSCSIHBA = $is.Device 

  $tgts = @();  
  foreach ($t in $iSCSI) {
    $tgt = New-Object VMware.Vim.HostInternetScsiHBASendTarget
    $tgt.address = $t.addr
    $tgt.port = $t.port
    $s = "{0}:{1}" -f $t.addr, $t.port
    log "Add iSCSI Send Target $s"
    $tgts += $tgt
  }
  $mor.addInternetScsiSendTargets($iSCSIHBA, $tgts)

  if ($verbose) { log ("Rescan SW iSCSI HBA {0}" -f $iSCSIHBA) }
  $mor.RescanHba($iSCSIHBA)

# Something like this code may be needed to mount the iSCSI VMFS volumes
# Get lunPath and create new storage
#  $lunpath = Get-ScsiLun $h | where  {$_.CanonicalName.StartsWith($iSCSIHBA)} | Get-ScsiLunPath
  $st = get-VMHostStorage -VMHost $addr
  $sluns = $st.SCSILUN | where {$_.CanonicalName.StartsWith($iSCSIHBA)}
  if ($verbose) { 
    $sluns | % { log ("{0} {1} {2} {3} {4} {5}" -f $_.CanonicalName, $_.Key, $_.LunType, $_.Model, $_.SerialNumber, $_.Vendor) }
#    write-host ($sluns | gm)
#    $sluns | % { write-host ("{0} {1} {2} {3} {4} {5}" -f $_.CanonicalName, $_.Key, $_.LunType, $_.Model, $_.SerialNumber, $_.Vendor) }
  }
  
#  New-Datastore -Vmfs -VMHost $h -Path $lunpath.LunPath -Name iSCSI
}

function configureNTP($h) {
  $hs = Get-View $h.ID
  $dtSys = $hs.ConfigManager.DateTimeSystem
  $mor = Get-View $dtSys
  $hsntpConfig = New-Object VMware.Vim.HostNtpConfig 
  $hsntpConfig.server =  $ntpServers
  $dateConfig = New-Object VMware.Vim.HostDateTimeConfig 
  $dateConfig.timeZone = "UTC"
  $dateConfig.ntpConfig = $hsntpConfig
  if ($verbose) { log "Configure NTP" }
  $mor.updateDateTimeConfig($dateConfig)
  if (! $?) { log "Couldn't update NTP config" }
  
  $svcSys = $hs.ConfigManager.ServiceSystem
  $mor = Get-View $svcSys
  if ($verbose) { log "Start NTP Service" }
  $mor.StartService("ntpd")
  if (! $?) { log "Couldn't start NTP service" }
}

function configureVMotion($h) {
  $hs = Get-View $h.ID
  $advOpt = $hs.ConfigManager.AdvancedOption
  $mgr = Get-View $advOpt
  $opts = $mgr.QueryOptions('Migrate.Enabled')
  if (($opts[0].Key -eq 'Migrate.Enabled') -and ($opts[0].Value -eq 0)) {
    if ($verbose) { log "Enable VMotion" }
    $opts[0].Value = 1
    $mgr.UpdateOptions($opts)
  }

  $vmotionSys = $hs.ConfigManager.vmotionSystem
  $mgr = Get-View $vmotionSys
  $mgr.SelectVNIC($vmotionNIC)
}

$hostd = $null

function configurePassword() {
  # Setting the password can only be done when directly connected to ESXi
  # If the connect fails, assume that the password is already set
  if ($verbose) { log "Configure Password" }
  $global:hostd = Connect-VIserver -Server $addr -User 'root' -Password $defaultESXPassword
  if ($?) {
    $root = Get-VMHostaccount -user root
    $pw = Set-VMHostAccount -UserAccount $root -Password $newESXPassword
    if (! $?) { log "Couldn't set password"; return $false }
    if ($verbose) { log "Password updated" }
   } else {
    $global:hostd = Connect-VIserver -Server $addr -User 'root' -Password $newESXPassword
    if ($?) {
      log "Password previously set"
    } else {
      log "Invalid default password"
      return $false
    }
  }
  return $true
}

$sysInfo = @{}

function fetchHWInfo() {
  $ErrorActionPreference = "continue"
   if ($global:hostd -eq $null) {
    log "Reconnect directly"
    $global:hostd = Connect-VIserver -Server $addr -User 'root' -Password $newESXPassword
  }
  $hv = Get-View -Server $global:hostd "hostsystem-ha-host"
  if (! $?) { log "Get-View hostsystem-ha-host failed"; return $null }
  if ($hv -eq $null) { log "Get-View hostsystem-ha-host returned null"; return $null }
  $si = $hv.hardware.systemInfo
  $sysInfo.Name = $hv.name
  $sysInfo.Vendor = $si.Vendor
  $sysInfo.Model = $si.model
  $sysInfo.UUID = $si.Uuid
  $sysInfo.DNSHostname = $hv.config.network.dnsConfig.hostName

  $ns = Get-View -Server $global:hostd $hv.configManager.networkSystem
  $vnics = $ns.networkConfig.vnic
  # Should check for proper vmkN
  $vnic = $vnics[0]  
  $sysInfo.IPAddr = $vnic.spec.ip.ipAddress
  
  $hv.config.network.pnic | % {
    $sysInfo.($_.device) = $_.mac
    if ($verbose) { log ("{0,8} - {1} ({2} pci {3})" -f $_.device, $_.mac, $_.driver, $_.pci) }
  }
}

function log($m) {
  $now = get-date
  write-host ("{0:d2}-{1:d2}-{2:d2} {3:d2}:{4:d2}:{5:d2} {6,15}: {7}" -f ($now.Year - 2000), $now.Month, $now.Day, $now.Hour, $now.Minute, $now.Second, $addr, $m);
}

$addr = $args[0]
if ($args.length -eq 0) {
  write-host "No target VMHost specified"
  exit
}

log "New Host"

$global:clean = $false
& {$global:clean = .\esx-cleanup.ps1 $addr }

log ("Configure Host (Clean {0})" -f $global:clean.ToString())

$pw = configurePassword
if ($pw) {
  $info = fetchHWInfo
  Disconnect-VIserver -server $global:hostd -Confirm:$false
} else {
  log "Couldn't directly connect"
}

$profile = getProfile

. $profile

if (($VC -eq "localhost") -and ($VCpassword -eq $null)) {
  $server = Connect-VIserver -Server localhost
} else {
  $server = Connect-VIserver -Server $VC -User administrator -Password $VCpassword
}

if (! $?) {
  $err = $error[0]
  log "Connect-VIserver error"
}
$where = Get-Cluster -name $cluster
$add = Add-VMHost -Name $addr -Location $where -User 'root' -Password $newESXPassword
$h = Get-VMHost $addr
configureNetworking($h)
configureNFSStorage($h)
configureISCSIStorage($h)
configureNTP($h)
configureVMotion($h)
$connected = Set-VMHost -VMHost $h -state Connected
$disconnect = Disconnect-VIServer -Confirm:$false

log "Complete"
