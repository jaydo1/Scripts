# Display the NIC and MAC information for each VM

Connect-VIServer MYVISERVER
 
$Information = @() 
Get-VM | Get-View | ForEach-Object { 
	$VM = $_ 
		$_.Config.Hardware.Device | Where-Object {"VirtualPCNet32","VirtualE1000","VirtualVxmNet" -contains $_.gettype().Name} | ForEach-Object { 
		$MyDetails = "" | Select VMname, Nictype, MAC, MACtype 
		$MyDetails.VMname = $VM.Name 
		$MyDetails.Nictype = $_.gettype().Name 
		$MyDetails.MAC = $_.MacAddress 
		$MyDetails.MACtype = $_.AddressType 
		$Information += $MyDetails 
	} 
} 
$Information