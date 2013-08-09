## TITLE: Get-VirtualSwitchUsage
## DESCRIPTION: Retrieves virtual switch port usage stat

Get-VMHost | ForEach-Object {
    $VMHost = $_
    $VMHostNameExp = @{ N = "VMHostName"; E = { $VMHost.name } }
    Get-VirtualSwitch -VMHost $_ | Select $VMHostNameExp, Name, NumPorts*
}