# Upgrade hardware version for all virtual machines in a cluster 
# named Non-Production:

Connect-VIServer MYVISERVER
 
Get-Cluster "Non-Production" | Get-VM | Get-View | ForEach-Object { $_.UpgradeVM($null) } 