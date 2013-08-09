$csvfile = Read-Host "Enter the CSV file location: "

$vm_names = Import-CSV $csvfile

$attribute1 = "Created"
$attribute2 = "Function"
$attribute3 = "Managed By"
$attribute4 = "System Owner"
$attribute5 = "Notes"
# note, set-customfield has been depreciated, therefore script updated with set-CustomAttribute.
# Attribute 2 must be used with 'Service' if running in Herbert St - also remember to update header on csv file
foreach ($vm in $vm_names) {
Get-VM -Name $vm.namevm | Set-Annotation -CustomAttribute $attribute1 -Value $vm.'Created'
Get-VM -Name $vm.namevm | Set-Annotation -CustomAttribute $attribute2 -Value $vm.'Service'
Get-VM -Name $vm.namevm | Set-Annotation -CustomAttribute $attribute3 -Value $vm.'Managed By'
Get-VM -Name $vm.namevm | Set-Annotation -CustomAttribute $attribute4 -Value $vm.'System Owner'
Get-VM -Name $vm.namevm | Set-VM -Notes $vm.'Notes' -confirm:$false
}
Write-Host "updated annotations for VMs on” $cluster “please check viclient..." -ForegroundColor Yellow