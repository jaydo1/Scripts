# Monitors the License server service and emails if the service is not running 

Function EmailAlert () { 
  $smtpServer = "mysmtpserver.com" 
   
  $msg = new-object Net.Mail.MailMessage 
  $smtp = new-object Net.Mail.SmtpClient($smtpServer)
  $msg.From= "me@mydomain.com" 
  $msg.To.Add("me@mydomain.com") 
  $msg.Subject= "VMware License Server Check" 
  $msg.Body= "The VMware license Server service is not in a running state, please investigate." 
   
  $smtp.Send($msg) 
} 
 
Connect-VIServer MYVISERVER

$ServiceInstance = Get-View ServiceInstance 
$LicenseMan = Get-View $ServiceInstance.Content.LicenseManager 
 
$LicenseServer = (($LicenseMan.Source.LicenseServer).split('@'))[1] 
$State = get-wmiobject win32_service -ComputerName $LicenseServer -filter "Name='VMware License Server'" |Select State 
 
if ($State.State-ne "Running"){ 
	EmailAlert 
}  
