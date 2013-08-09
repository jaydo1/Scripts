# Show CPU Affinity settings for all VMs

Connect-VIServer MYVISERVER

$Information = @()
Foreach ($VM in (Get-VM | Sort Name | Get-View)){
	$MyDetails = "" | Select-Object VMName,Affinity
	$MyDetails.VMName = $VM.Name
	if ($VM.Config.CpuAffinity.AffinitySet -eq $null){
		$Affinity = "Not Set"
	}
	Else{
		$Affinity = $VM.Config.CpuAffinity.AffinitySet
	}
	$MyDetails.Affinity = $Affinity
	$Information += $MyDetails
}
$Information
