# esx-cleanup.ps1 [hostname|ipaddress]

$verbose = $true

function log($m) {
  $now = get-date
  write-host ("{0:d2}-{1:d2}-{2:d2} {3:d2}:{4:d2}:{5:d2} {6,15}: {7}" -f ($now.Year - 2000), $now.Month, $now.Day, $now.Hour, $now.Minute, $now.Second, $addr, $m);
}


$addr = $args[0]
log "Cleanup"

& {
  $ErrorActionPreference = 'Silentlycontinue'
  $vmwareSnap = get-pssnapin -name "VMware.VimAutomation.Core"
  if (! $?) { add-pssnapin "VMware.VimAutomation.Core" }
}

. .\esx-master.ps1

$ErrorActionPreference = 'Silentlycontinue'

if (($VC -eq "localhost") -and ($password -eq $null)) {
  $server = Connect-VIServer -Server $VC
} else {
  $server = Connect-VIServer -Server $VC -User administrator -password $VCpassword
}
if (! $?) { log "couldn't connect to VC " $VC; return $false }
$h = Get-VMHost -Name $addr
if (! $?) { log "Not found in Virtual Center"; return $true }


#$ErrorActionPreference = 'Continue'

$cState = $h.State
if ($cState -eq "NotResponding") {
  log "state: $cState"
#  Bug 305103
#  Set-VMHost -VMHost $h -state Disconnected
  $hv = Get-View $h.ID
  log "Disconnect"
  $hv.DisconnectHost()

  $h = Get-VMHost -Name $addr
  log "Remove"
  Remove-VMHost -VMHost $h -Confirm:$false
  if (! $?) { log "Remove-VMHost failed"; return $false }
  return $true
}

if ($cState -ne "Connected") {
  log "Attempt reconnect"
  $h = Set-VMHost -VMHost $h -State Connected
  if (! $?) { log "Reconnect failed" }
  $h = Get-VMHost -Name $addr
  if ($h.State -ne "Connected") {
    if ($cState -eq "NotResponding") {
      $hv = Get-View $h.ID
      $hv.DisconnectHost()
    }
    log "Remove Host"
    Remove-VMHost -VMHost $h -Confirm:$false
    if (! $?) { log "Remove-VMHost failed"; return $false }
    return $true
  }
}

log "Enter Maintenance Mode"
$mode = Set-VMHost -VMHost $h -State "Maintenance"  -Confirm:$false
if (! $?) {
  log "Did not enter Maintenance Mode" 

  $hv = Get-View $h.ID
  log "Disconnect"
  $hv.DisconnectHost()
  if (! $?) { log "DisconnectHost failed" }

  $h = Get-VMHost -Name $addr
  log "Remove"
  Remove-VMHost -VMHost $h -Confirm:$false
  if (! $?) { log "Remove-VMHost failed"; return $false }
  return $true
}

log "Remove Data Stores"
Get-DataStore -VMHost $h | % {
  Remove-DataStore -Datastore $_ -Host $h -Confirm:$false
  if (! $?) { log ("Could not remove Datastore {0}" -f $_.Name) }
}

log "Remove Port Groups"
Get-VirtualPortGroup -vmhost $h | % {
  if (($_.Name -ne "VM Network") -and ($_.Name -ne "Management Network")) {
    Remove-VirtualPortGroup $_ -Confirm:$false
    if (! $?) {log ("Could not remove Port Group {0}" -f $_.Name) }
  }
}

log "Remove Virtual Switches"
Get-VirtualSwitch -VMHost $h | % {
  if ($_.Name -ne "vSwitch0") {
    Remove-VirtualSwitch -VirtualSwitch $_ -Confirm:$false
    if (! $?) { log ("Could not remove Virtual Switch {0}" -f $_.Name) }
  }
}

log "Remove Host"
Remove-VMHost -VMHost $h -Confirm:$false
if (! $?) { log "Remove-VMHost failed"; return $false }
Disconnect-VIServer -Confirm:$false

# Setting the password can only be done when directly connected to ESXi
log "Reset Password"
$server = Connect-VIServer -Server $addr -User 'root' -Password $newESXPassword
if ($?) {
  $root = Get-VMHostaccount -User root
  $hostAccount = Set-VMHostaccount -UserAccount $root -Password $defaultESXPassword
  if (! $?) { log "Password reset failed" }
  Disconnect-VIServer -Confirm:$false
} else {
  log "Couldn't connect directly to reset password"
}

return $true
