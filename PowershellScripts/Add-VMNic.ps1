param (
    # Note the use of type constraints to validate parameters and
    # the setting of default values
    [VMware.VimAutomation.Client20.VirtualMachineImpl] $VM,
    [switch] $StartConnected = $true,
    [switch] $Confirm = $true
)

if ( !$VM ) { Throw "Specify a virtual machine with the VM parameter" }

# If there is no active VI session, prompt user for server name and create session
if ( !$DefaultVIServer ) {
    $viServer = Read-Host "Type VMWare Infrastructure Server name and press enter`n"
    Connect-VIServer -Server $viServer 
}

# Get list of available networks based on portgroups to which VM is accessible.
$VMHost = Get-VMHost -VM $VM
$PortGroup = Get-VirtualPortGroup -VMHost $VMHost
$AvailNetworks = $PortGroup | ForEach-Object { $_.Name }

# Present choices and prompt user
while ( $Answer -notmatch "[1-$( $AvailNetworks.Length )]" ) {
    Write-Host "Select name of virtual network for new network interface.`n"
    for ( $i = 1; $i -le $AvailNetworks.Length; $i++ ) {
        Write-Host ( "[$i] " + $AvailNetworks[$i-1] )
    }
        $Answer = Read-Host "`n [1-$( $AvailNetworks.Length )]"
}
$NetworkName = $AvailNetworks[$Answer - 1]

# Add vNIC to VM
New-NetworkAdapter -VM $VM -NetworkName $NetworkName -StartConnected:$StartConnected `
    -Confirm:$Confirm