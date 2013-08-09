$Title = "ESXi hosts which do not have Lockdown mode enabled"
$Header =  "ESXi Hosts with Lockdown Mode not Enabled : $($ESXiUnlocked.count)"
$Comments = "The following ESXi Hosts do not have lockdown enabled, think about using Lockdown as an extra security feature."
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$ESXiLockDown = $VMH | Where {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"} | Where {$_.ExtensionData.Summary.Config.Product.Name -match "i"} | Select Name, @{N="LockedMode";E={$_.ExtensionData.Config.AdminDisabled}}
@($ESXiLockDown | Where { $_.LockedMode -eq $false })
