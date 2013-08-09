Function Export-Folders {
  <#
.SYNOPSIS
  Creates a csv file of folders in vCenter Server.
.DESCRIPTION
  The function will export folders from vCenter Server 
  and add them to a CSV file.
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER FolderType
  The type of folder to export
.PARAMETER DC
  The Datacenter where the folders reside
.PARAMETER Filename
  The path of the CSV file to use when exporting
.EXAMPLE 1
  PS> Export-Folders -FolderType "Blue" -DC "DC01" -Filename "C:\BlueFolders.csv"
.EXAMPLE 2
  PS> Export-Folders -FolderType "Yellow" -DC "Datacenter" 
  -Filename "C:\YellowFolders.csv"
#>

  param( 
  [String]$FolderType, 
  [String]$DC,
  [String]$Filename
  ) 
   
  Process {
   If ($Foldertype -eq "Yellow") {
      $type = "host"
   } Else {
     $type = "vm"
   }
   $report = @()
   $report = get-datacenter $dc | Get-folder $type | get-folder | Get-Folderpath
   $Report | foreach {
    if ($type -eq "vm") {
     $_.Path = ($_.Path).Replace($dc + "\","$type\")
    } 
   }
   $report | Export-Csv $filename -NoTypeInformation
  }
}

