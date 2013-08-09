#Adds a new host named newESXhost.mydomain.com  to the Production Datacenter 

Connect-VIServer MYVISERVER
 
Add-VMHost "NewESXhost.mydomain.com" -Location (Get-Datacenter Production) -User root -Password MyPass
