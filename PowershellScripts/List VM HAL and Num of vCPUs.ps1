# Display the HAL information and number of virtual CPUs for each VM

Connect-VIServer MYVISERVER

$HALInformation = @() 
ForEach ($VM in (Get-VM)) { 
	$MyDetails = "" | select-Object Name, HAL, NumvCPU 
	$MYDetails.Name = $VM.Name 
	$Hal = Get-WmiObject -ComputerName $VM.Name -Query "SELECT * FROM Win32_PnPEntity where ClassGuid = '{4D36E966-E325-11CE-BFC1-08002BE10318}'" | Select Name 
	$MYDetails.HAL = $Hal.Name 
	$MYDetails.NumvCPU = $VM.NumCPU 
	$HALInformation += $MYDetails 
} 
$HALInformation 