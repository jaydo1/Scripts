# The following shows how PowerCLI can be used to report the 
# speed of each NIC for all hosts in your virtual 
# infrastructure: 

Connect-VIServer MYVISERVER

$Information = @() 
Foreach ($VMHost in Get-VMHost | Get-View | Sort Name) { 
	$MyDetails = "" | select VMHost 
	$MyDetails.VMHost = $VMHost.Name 
	$pnic = 0 
	Do { 
		$MyDetails | Add-Member -name "Nic$pnic" -memberType NoteProperty -value "$($VMHost.Config.Network.Pnic[$pnic].LinkSpeed.SpeedMb)MB" 
		$pnic ++ 
	} 
	Until ($pnic -eq ($VMHost.Config.Network.Pnic.Length)) 
  $Information += $MyDetails 
}
$Information