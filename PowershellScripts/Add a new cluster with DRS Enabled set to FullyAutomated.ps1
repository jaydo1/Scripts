# Adds a new cluster to the “Production” Datacenter with DRS Enabled and set to FullyAutomated

Connect-VIServer MYVISERVER
 
$DataCenter = Get-Datacenter "Production" 
New-Cluster -Location $DataCenter -Name Accounts -DRSEnabled -DRSMode FullyAutomated 
