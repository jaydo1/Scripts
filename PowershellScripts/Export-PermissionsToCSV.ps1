Function Export-PermissionsToCSV {
 <#
.SYNOPSIS
  Exports all Permissions to CSV file
.DESCRIPTION
  The function will export all permissions to a CSV
  based file for later import
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER Filename
  The path of the CSV file to be created
.EXAMPLE 1
  PS> Export-PermissionsToCSV -Filename "C:\Temp\Permissions.csv"
#>


  param( 
  [String]$Filename
  )
  
  Process {
   $folderperms = get-datacenter | Get-Folder | Get-VIPermission
   $vmperms = Get-Datacenter | get-vm | Get-VIPermission


   $permissions = get-datacenter | Get-VIpermission


   $report = @()
      foreach($perm in $permissions){
        $row = "" | select EntityId, Name, Role, Principal, IsGroup, Propagate
        $row.EntityId = $perm.EntityId
        $Foldername = (Get-View -id $perm.EntityId).Name
        $row.Name = $foldername
        $row.Principal = $perm.Principal
        $row.Role = $perm.Role
        $row.IsGroup = $perm.IsGroup
        $row.Propagate = $perm.Propagate
        $report += $row
    }


    foreach($perm in $folderperms){
        $row = "" | select EntityId, Name, Role, Principal, IsGroup, Propagate
        $row.EntityId = $perm.EntityId
        $Foldername = (Get-View -id $perm.EntityId).Name
        $row.Name = $foldername
        $row.Principal = $perm.Principal
        $row.Role = $perm.Role
        $row.IsGroup = $perm.IsGroup
        $row.Propagate = $perm.Propagate
        $report += $row
    }


    foreach($perm in $vmperms){
        $row = "" | select EntityId, Name, Role, Principal, IsGroup, Propagate
        $row.EntityId = $perm.EntityId
        $Foldername = (Get-View -id $perm.EntityId).Name
        $row.Name = $foldername
        $row.Principal = $perm.Principal
        $row.Role = $perm.Role
        $row.IsGroup = $perm.IsGroup
        $row.Propagate = $perm.Propagate
        $report += $row
    }


    $report | export-csv $Filename -NoTypeInformation
  }
}