# Shutdown all guests currently powered on which are being 
# hosted by “HOST01.mydomain.com” and then put the host into 
# maintenance mode and shutdown the host: 
 
Connect-VIServer MYVISERVER

$ESXHost = "HOST01.mydomain.com" 
 
Get-VMHost $ESXHost | Get-VM | where {$_.PowerState -ne "PoweredOff"} | Shutdown-VmGuest 
(Get-VMHost $ESXHost | Get-View).EnterMaintenanceMode_Task(-1, $TRUE)  
((Get-VMHost $ESXHost | Get-View).ID).ShutdownHost_Task($TRUE)