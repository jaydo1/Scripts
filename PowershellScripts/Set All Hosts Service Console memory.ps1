# The following shows how PowerCLI can be used to change the  
# Service Console memory for all hosts to 800MB

Connect-VIServer MYVISERVER

$ConsoleMemMB = 800 
Get-VMHost | Get-View | Foreach-Object {(Get-View -Id $_.ConfigManager.MemoryManager).ReconfigureServiceConsoleReservation($ConsoleMemMB*1MB)} 