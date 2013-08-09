
$clustername = Read-Host "enter cluster name"
$cluster = Get-Cluster $clustername


$VMhosts = ($cluster | Get-VMHost)| Sort-Object -Property Name){
foreach ($VMHost in $VMhosts) 
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name DataMover.HardwareAcceleratedMove -Value 0
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name DataMover.HardwareAcceleratedInit -Value 0
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name VMFS3.HardwareAcceleratedLocking -Value 0
}