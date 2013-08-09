

$clustername = Read-Host "enter cluster name"

Get-VMHost -location (Get-Cluster $clustername) | foreach-object {
$VMHost = $_   # or replace your $VMHost variables with $_
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name DataMover.HardwareAcceleratedMove -Value 0
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name DataMover.HardwareAcceleratedInit -Value 0
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name VMFS3.HardwareAcceleratedLocking -Value 0
}
