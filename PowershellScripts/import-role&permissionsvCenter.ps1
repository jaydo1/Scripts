###
# Purpose        : Import vCenter roles and permissions into a new vCenter.
# Created        : 26/08/2010
# Author         : VMware Community, namely Alan Renouf and Luc Dekens & me (D Woollard)
#                : Added menu for various imports and file checkifng
# Pre-requisites : Source files
###

###
# define functions
function New-Role
{
    param($name, $privIds)
    Begin{}
    Process{

        $roleId = $authMgr.AddAuthorizationRole($name,$privIds)
    }
    End{
        return $roleId
    }
}
function Set-Permission
{
param(
[VMware.Vim.ManagedEntity]$object,
[VMware.Vim.Permission]$permission
)
Begin{}
Process{
    $perms = $authMgr.SetEntityPermissions($object.MoRef,@($permission))
}
End{
    return
}
}
function CheckPermissionFile
{
    Write-Host "Looking for $goldfile"
	$filepresent = test-path $goldfile    
    if ($filepresent -eq $True) {
	    Write-Host "Found XML file for your choice."
		}
    else {
	    Write-Host "The XML file for your selected environment is not present in the current <DIR>, exiting."
		exit
	}
}

###
# Main body
clear
$menuchoice = @" 
+========================================+
|  Which file would you like to import?  |
+========================================+
|                                        |
|        [A]  -> Live                    |
|        [B]  -> Development             |
|        [C]  -> Test                    |
|        [Q]  -> Quit                    |
|                                        |
+========================================+

Enter the letter next to your choice 
"@ 
$importchoice = Read-Host $menuchoice 

switch ($importchoice.toCharArray()){ 
"a" {
    "
You selected Live"
    $goldfile = "./vcenter-permissions-master-live.xml"
    CheckPermissionFile
	} 
"b" {
    "
You selected Development"
	$goldfile = "./vcenter-permissions-master-dev.xml"
    CheckPermissionFile
	} 
"c" {
    "
You selected Test"
    $goldfile = "./vcenter-permissions-master-test.xml"
    CheckPermissionFile
	} 
"q" {
    "
You selected to QUIT"
exit
    }
default {
        "
You selected $_ which is not a valid choice, now exiting."
exit
	    } 
}

# Create hash table with the current roles
$authMgr = Get-View AuthorizationManager
$roleHash = @{}
$authMgr.RoleList | % {
    $roleHash[$_.Name] = $_.RoleId
}
# Read XML file
$XMLfile = $goldfile
Write-Host "$XMLfile"
$vInventory = [xml]"<dummy/>"
$vInventory.Load($XMLfile)

# Define Xpaths for the roles and the permissions
$XpathRoles = “Inventory/Roles/Role”
$XpathPermissions = “Inventory/Permissions/Permission”
# Create custom roles
$vInventory.SelectNodes($XpathRoles) | % {
    if(-not $roleHash.ContainsKey($_.Name)){
        $privArray = @()
        $_.Privilege | % {
            $privArray += $_.Name
        }
        $roleHash[$_.Name] = (New-Role $_.Name $privArray)
    }
}
# Set permissions
$vInventory.SelectNodes($XpathPermissions) | % {
    $perm = New-Object VMware.Vim.Permission
    $perm.group = &{if ($_.Group -eq “true”) {$true} else {$false}}
    $perm.principal = $_.Principal
    $perm.propagate = &{if($_.Propagate -eq “true”) {$true} else {$false}}
    $perm.roleId = $roleHash[$_.Role]

    $EntityName = $_.Entity.Replace(“(“,“\(“).Replace(“)”,“\)”)
    $EntityName = $EntityName.Replace(“[","\[").Replace("]“,“\]”)
    $EntityName = $EntityName.Replace(“{“,“\{“).Replace(“}”,“\}”)

    $entity = Get-View -ViewType $_.EntityType -Filter @{“Name”=("^" + $EntityName + "$")}
    Set-Permission $entity $perm
}