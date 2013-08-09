# Setup Variables...
# You are prompted for Datacenter / Cluster / Datastore / Template / Resource Pool & Folder location
$clusname = Read-Host "Enter Target VMware Cluster: " 
$dsname = Read-Host "Enter Target Datastore: "
$templatename = Read-Host "Enter Source VM Template Name: "
$rpname = Read-Host "Enter Target (Root) Resource Pool: "
$foldername = Read-Host "Enter Target (Root) VM Folder: "
$csvfile = Read-Host "Enter the CSV file location: "

# Select Cluster
$cluster = Get-Cluster -Name $clusname

# Select Datastore
Set VM_DS $dsname

# Select Template
Set VM_Template $templatename

#Select root Resource Pool
$rp_root = Get-ResourcePool -Name $rpname -Location $cluster

# To select child ResourcePool.  
# If child ResourcePool required remove # and replace <Sub_RP> with name of the actual ResourcePool that's child of the previous ResourcePool
#$rp_1 = Get-ResourcePool -Name <Sub_RP> -Location $rp_root

# Select root Folder
$folder_root = Get-Folder -Name $foldername

# Select 1st level child Folder
#$folder_child1 = Get-Folder -Name '1stchildfoldername' -Location $folder_root

# Select 2nd level child Folder
#$folder_child2 = Get-Folder -Name '2ndchildfoldername' -Location $folder_child1

# Create VM from a template and import VM names from a csv file

$vm_names = Import-CSV $csvfile
$vm_names | ForEach-Object {
	Write-Host "creating VM" $_.NameVM "on cluster" $cluster -ForegroundColor Green
	New-VM -ResourcePool $rp_root -Location $folder_root -Datastore $VM_DS -Name $_.NameVM -Template $VM_Template
}
Write-Host "created VMs on” $cluster “now updating annotations..." -ForegroundColor Yellow

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