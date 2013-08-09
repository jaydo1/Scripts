# Adds a new cluster to the “Production” Datacenter with HA Enabled and set to Failover for 1 host

Connect-VIServer MYVISERVER
 
$DataCenter = Get-Datacenter "Production" 
New-Cluster -Location $DataCenter -Name Accounts -HAEnabled -HAFailoverLevel 1