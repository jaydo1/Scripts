Get-VMHost | ForEach-Object {
    $VMHostName = $_.Name
    $VMHostNameExp = @{ Label = "VMHostName"; Expr = { $VMHostName } }
    $StorageView = Get-VMHostStorage -VMHost $_ | Get-View
    $StorageAdapter = $StorageView.StorageDeviceInfo.HostBusAdapter
    Write-Output $StorageAdapter 
} | Format-Table $VMHostNameExp , Device, Model, Driver -autosize