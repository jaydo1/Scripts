$report = @()
foreach($esx in Get-VMHost){
    $vms = Get-VM -Location $esx
    foreach($pg in (Get-VirtualPortGroup -VMHost $esx)){
        $vms | where {$_.Guest.Nics | where {$_.NetworkName -eq $pg.Name}} | foreach {
            $Report += New-Object PSObject -Property @{
                "Host"=$esx.Name
                "VM"=$_.Name
                "VLAN ID"=$pg.VlanId
                "Port Group"=$pg.Name
                "IP"=[string]::Join(',',($_.Guest.Nics | where {$_.NetworkName -eq $pg.Name} | %{$_.IPAddress | %{$_}}))
            }
        }
    }
}
$report | Export-Csv "C:\herbertStVLAN-report.csv" -NoTypeInformation -UseCulture