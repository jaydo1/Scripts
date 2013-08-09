# Alters an existing VMs to set  memory reservation to 8Gb #


$csvfile = Read-Host "Enter the CSV file location:"

$vm_names = Import-CSV $csvfile


foreach ($vm in $vm_names) {Get-VM -Name $vm.namevm | Set-VMResourceConfiguration -MemReservationMB 16384 }