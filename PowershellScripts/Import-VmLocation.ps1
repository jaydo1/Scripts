Function Import-VMLocation {
 <#
.SYNOPSIS
  Imports the VMs back into their Blue Folders based on
  the data from a csv file.
.DESCRIPTION
  The function will import VM locations from CSV File 
  and add them to their correct Blue Folders.
.NOTES
  Authors:  Luc Dekens & Alan Renouf
.PARAMETER DC
  The Datacenter where the folders reside
.PARAMETER Filename
  The path of the CSV file to use when importing
.EXAMPLE 1
  PS> Import-VMLocation -DC "DC01" -Filename "C:\VMLocations.csv"
#>

  param( 
  [String]$DC,
  [String]$Filename
  )
  
  Process {
   $Report = @()
   $Report = import-csv $filename | Sort-Object -Property Path
   foreach($vmpath in $Report){
      $key = @()
      $key =  Split-Path $vmpath.Path | split-path -leaf
      Move-VM (get-datacenter $dc `
      | Get-VM $vmpath.Name) -Destination (get-datacenter $dc | Get-folder $key) 
   }
  }
}

Import-VMLocation "DC01" "C:\VMLocation.csv"


New-VIRole `
-Name 'New Custom Role' `
-Privilege (Get-VIPrivilege `
-PrivilegeGroup "Interaction","Provisioning")

