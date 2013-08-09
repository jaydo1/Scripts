################################################################
# Listing 4.1: Creating a new vDS
################################################################
$Datacenter = Get-Datacenter -Name �PROD01�
New-DistributedSwitch -Name PROD01-vDS01 `
-Datacenter $Datacenter `
-NumberOfUplinks 4