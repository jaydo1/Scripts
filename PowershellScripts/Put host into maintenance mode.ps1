# The example below puts MyESXHost.mydomain.com into maintenance mode

Connect-VIServer MYVISERVER

(Get-VMHost "MyESXHost.mydomain.com" | Get-View).EnterMaintenanceMode_Task(-1, $true)  
 
  