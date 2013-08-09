function Import-Folders{ 
<#
.SYNOPSIS
  Imports a csv file of folders into vCenter Server and
  creates them automatically.
.DESCRIPTION
  The function will import folders from CSV file and create
  them in vCenter Server.
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER FolderType
  The type of folder to create
.PARAMETER DC
  The Datacenter to create the folder structure
.PARAMETER Filename
  The path of the CSV file to use when importing
.EXAMPLE 1
  PS> Import-Folders -FolderType "Blue" -DC "DC01" -Filename "C:\BlueFolders.csv"
.EXAMPLE 2
  PS> Import-Folders -FolderType "Yellow" -DC "Datacenter" 
  -Filename "C:\YellowFolders.csv"
#>

  param( 
  [String]$FolderType, 
  [String]$DC,
  [String]$Filename
  ) 

  process{ 
    $vmfolder = Import-Csv $filename | Sort-Object -Property Path 
   If ($FolderType -eq "Yellow") {
      $type = "host"
   } Else {
      $type = "vm"
   }
   foreach($folder in $VMfolder){ 
      $key = @()
      $key =  ($folder.Path -split "\\")[-2] 
      if ($key -eq "vm") { 
         get-datacenter $dc | get-folder $type | New-Folder -Name $folder.Name 
      } else { 
        Get-Datacenter $dc | get-folder $type | get-folder $key | `
            New-Folder -Name $folder.Name  
      } 
   }
  } 
} 

Import-Folders -FolderType "blue" -DC "DC01" -Filename "C:\BlueFolders.csv"


Filter Get-FolderPath {
<#
.SYNOPSIS
  Colates the full folder path
.DESCRIPTION
  The function will find the full folder path returning a
  name and path
.NOTES
  Authors:  Luc Dekens & Alan Renouf
#>
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name

        $current = Get-View $_.Parent
        $path = $_.Name
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}