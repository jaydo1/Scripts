###################################################################################
# Listing 5.6: Deploying using a template, CustomizationSpec, and checks for 
# sufficient free space
###################################################################################
# Get source Template
$Template = Get-Template -Name 'REHL5.5'
# Get the OS CustomizationSpec
$OSCustomizationSpec = Get-OSCustomizationSpec -Name 'REHL5.5'
# Get a host within the development cluster
$VMHost = Get-Cluster 'dev01' | Get-VMHost | Get-Random
# Determine the capacity requirements of this VM
$CapacityKB = Get-HardDisk -Template $Template | 
    Select-Object -ExpandProperty CapacityKB |
    Measure-Object -Sum |
    Select-Object -ExpandProperty Sum
# Find a datastore with enough room
$Datastore = Get-Datastore -VMHost $VMHost| 
    Where-Object {($_.FreeSpaceMB * 1mb) -gt (($CapacityKB * 1kb) * 1.1 )} |
    Select-Object -first 1
# Deploy our Virtual Machine
$VM = New-VM -Name 'REHL_01' `
    -Template $Template `
    -VMHost $VMHost `
    -Datastore $Datastore
    -OSCustomizationSpec $OSCustomizationSpec
