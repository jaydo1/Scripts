Function Export-VMLocation {
  <#
.SYNOPSIS
  Creates a csv file with the folder location of each VM.
.DESCRIPTION
  The function will export VM locations from vCenter Server 
  and add them to a CSV file.
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER DC
  The Datacenter where the folders reside
.PARAMETER Filename
  The path of the CSV file to use when exporting
.EXAMPLE 1
  PS> Export-VMLocation -DC "DC01" -Filename "C:\VMLocations.csv"
#>

  param( 
  [String]$DC,
  [String]$Filename
  )
  
  Process {
   $report = @()
   $report = get-datacenter $dc | get-vm | Get-Folderpath
   $report | Export-Csv $filename -NoTypeInformation
  }
}

Export-Folders "Blue" "DC01" "C:\BlueFolders.csv"
Export-VMLocation "DC01" "C:\VMLocation.csv"
Export-Folders "Yellow" "DC01" "C:\YellowFolders.csv"

