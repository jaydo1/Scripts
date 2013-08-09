$dsName = "SCSI_ESX1_VOL1"
Get-VMHost | ForEach-Object {
    if ( Get-Datastore -VMHost $_ -Name $dsName -ea "SilentlyContinue" ) {
        Write-Host -foregroundcolor Green "Server `"$_`" is connected to $dsName datastore"
    }
    else { Write-Host -foregroundcolor Red "You got problems on $_, Boss." }
}