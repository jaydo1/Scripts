function Get-Roles
{
  Begin{
    $authMgr = Get-View AuthorizationManager
    $report = @()
  }
  Process{
    foreach($role in $authMgr.roleList){
      $ret = New-Object PSObject
      $ret | Add-Member -Type noteproperty -Name “Name” -Value $role.name
      $ret | Add-Member -Type noteproperty -Name “Label” -Value $role.info.label
      $ret | Add-Member -Type noteproperty -Name “Summary” -Value $role.info.summary
      $ret | Add-Member -Type noteproperty -Name “RoleId” -Value $role.roleId
      $ret | Add-Member -Type noteproperty -Name “System” -Value $role.system
      $ret | Add-Member -Type noteproperty -Name “Privilege” -Value $role.privilege
      $report += $ret
    }
  }
  End{
    return $report
  }
}
function Get-Permissions
{
  Begin{
    $report = @()
    $authMgr = Get-View AuthorizationManager
    $roleHash = @{}
    $authMgr.RoleList | %{
      $roleHash[$_.RoleId] = $_.Name
    }
  }
  Process{
    $perms = $authMgr.RetrieveAllPermissions()
    foreach($perm in $perms){
      $ret = New-Object PSObject
      $entity = Get-View $perm.Entity
      $ret | Add-Member -Type noteproperty -Name “Entity” -Value $entity.Name
      $ret | Add-Member -Type noteproperty -Name “EntityType” -Value $entity.gettype().Name
      $ret | Add-Member -Type noteproperty -Name “Group” -Value $perm.Group
      $ret | Add-Member -Type noteproperty -Name “Principal” -Value $perm.Principal
      $ret | Add-Member -Type noteproperty -Name “Propagate” -Value $perm.Propagate
      $ret | Add-Member -Type noteproperty -Name “Role” -Value $roleHash[$perm.RoleId]
      $report += $ret
    }
  }
  End{
    return $report
  }
}
function New-XmlNode{
  param($node, $nodeName)
  $tmp = $vInventory.CreateElement($nodeName)
  $node.AppendChild($tmp)
}
function Set-XmlAttribute{
  param($node, $name, $value)
  $node.SetAttribute($name, $value)
}
function Get-XmlNode{
  param($path)
  $vInventory.SelectNodes($path)
}
$vInventory = [xml]“<Inventory><Roles/><Permissions/></Inventory>”
# Roles
$XMLRoles = Get-XmlNode “Inventory/Roles”
Get-Roles | where {-not $_.System} | % {
  $XMLRole = New-XmlNode $XMLRoles “Role”
  Set-XmlAttribute $XMLRole “Name” $_.Name
  Set-XmlAttribute $XMLRole “Label” $_.Label
  Set-XmlAttribute $XMLRole “Summary” $_.Summary
  $_.Privilege | % {
    $XMLPrivilege = New-XmlNode $XMLRole “Privilege”
    Set-XmlAttribute $XMLPrivilege “Name” $_
  }
}
# Permissions
$XMLPermissions = Get-XmlNode “Inventory/Permissions”
Get-Permissions | % {
  $XMLPerm = New-XmlNode $XMLPermissions “Permission”
  Set-XmlAttribute $XMLPerm “Entity” $_.Entity
  Set-XmlAttribute $XMLPerm “EntityType” $_.EntityType
  Set-XmlAttribute $XMLPerm “Group” $_.Group
  Set-XmlAttribute $XMLPerm “Principal” $_.Principal
  Set-XmlAttribute $XMLPerm “Propagate” $_.Propagate
  Set-XmlAttribute $XMLPerm “Role” $_.Role
}
$vInventory.Save(“C:\vInventory.xml”)