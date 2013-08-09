# Add a new “Test Datastore” to the “MyESXHost.mydomain.com”. 

Connect-VIServer MYVISERVER
 
Get-VMHost "MyESXHost.mydomain.com" | New-Datastore -Vmfs -Name "Test Datastore" -Path vmhba12:2:1:1 