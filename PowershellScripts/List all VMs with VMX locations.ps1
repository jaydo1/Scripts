# List all VMs and their current VMX Location: 

Connect-VIServer MYVISERVER

$Information = @()
Foreach ($VM in (Get-VM | Sort Name | Get-View)){ 
	$MyDetails = "" | Select-Object VMName,VMXLocation 
	$MyDetails.VMName = $VM.Name 
	$MyDetails.VMXLocation = $VM.Config.Files.VmPathName 
	$Information += $MyDetails 
} 
$Information