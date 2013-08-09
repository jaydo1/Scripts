# Alters an existing VMs to change the current number of vCPUs to 8: 

Connect-VIServer upvvcs001

$csvfile = Read-Host "Enter the CSV file location: "

$vm_names = Import-CSV $csvfile


foreach ($vm in $vm_names) {Get-VM -Name $vm.namevm | Set-VM –NumCpu 4 -Confirm:$false}