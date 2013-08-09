function Import-Permissions {
<#
.SYNOPSIS
  Imports all Permissions from CSV file
.DESCRIPTION
  The function will import all permissions from a CSV
  file and apply them to the vCenter objects.
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER DC
  The Datacenter to import the permissions into
.PARAMETER Filename
  The path of the CSV file to be imported
.EXAMPLE 1
  PS> Import-Permissions -DC "DC01" -Filename "C:\Temp\Permissions.csv"
#>


param(
[String]$DC,
[String]$Filename
)


process {
 $permissions = @()
 $permissions = Import-Csv $Filename
 foreach ($perm in $permissions) {
  $entity = ""
  $entity = New-Object VMware.Vim.ManagedObjectReference
  $object = Get-Inventory -Name $perm.Name
  if($object.Count){
   $object = $object | where {$_.Id -eq $perm.EntityId}
  }
  if($object){
   switch -wildcard ($perm.EntityId)
   {
    Folder* {
     $entity.type = "Folder"
     $entity.value = $object.Id.Trimstart("Folder-")
    }
    VirtualMachine* {
     $entity.Type = "VirtualMachine"
     $entity.value = $object.Id.Trimstart("VirtualMachine-")
    }
    ClusterComputeResource* {
     $entity.Type = "ClusterComputeResource"
     $entity.value = $object.Id.Trimstart("ClusterComputeResource-")
    }
    Datacenter* {
	$entity.Type = "Datacenter"
     $entity.value = $object.Id.Trimstart("Datacenter-")
    }
   }
   $setperm = New-Object VMware.Vim.Permission
   $setperm.principal = $perm.Principal
   if ($perm.isgroup -eq "True") {
    $setperm.group = $true
   } else {
    $setperm.group = $false
   }
   $setperm.roleId = (Get-virole $perm.Role).id
   if ($perm.propagate -eq "True") {
    $setperm.propagate = $true
   } else {
    $setperm.propagate = $false
   }
   $doactual = Get-View -Id 'AuthorizationManager-AuthorizationManager'
   Write-Host "Setting Permissions on $($perm.Name) for $($perm.principal)"
   $doactual.SetEntityPermissions($entity, $setperm)
  }
 }
 }
}


Import-Permissions -DC "DC01" -Filename "C:\Temp\Permissions.csv"


$ProductionCluster = New-Cluster `
-Location $BostonDC `
-Name "Production" `
-HAEnabled -HAAdmissionControlEnabled `
-HAFailoverLevel 1 `
-HARestartPriority "Medium"


Get-Cluster `
-Location $BostonDC `
-Name "Production" | `
Set-Cluster -HAEnabled $true `
-HAAdmissionControlEnabled $true `
-HAFailoverLevel 1 `
-HARestartPriority "Medium"


$ProductionCluster = New-Cluster "Production" `
-DrsEnabled `
-DrsAutomationLevel "FullyAutomated" `
-DrsMode "FullyAutomated"


Get-Cluster -Location $BostonDC `
-Name "Production" | Set-Cluster `
-DrsEnabled $true `
-DrsAutomationLevel "FullyAutomated" `
-DrsMode "FullyAutomated"
