# Upgrade hardware version for a virtual machine named PROD1

Connect-VIServer MYVISERVER
 
Get-VM PROD1 | Get-View | ForEach-Object { $_.UpgradeVM($null) } 
