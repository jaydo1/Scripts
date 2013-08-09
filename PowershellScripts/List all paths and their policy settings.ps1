# Gets a list of all paths and their policy settings 

Connect-VIServer MYVISERVER

$ESX = get-vmhost "MyESXHost.mydomain.com" | Get-View 
 
$Information = @() 
foreach($disk in $esx.Config.StorageDevice.ScsiLun){ 
	$MyDetails = "" | Select-Object Name, Policy 
	foreach($lun in $esx.Config.StorageDevice.MultipathInfo.Lun){ 
		if($disk.CanonicalName -eq $lun.Id){ 
			$MyDetails.Name = $disk.CanonicalName  
			$Mydetails.Policy = $lun.Policy.Policy 
			$Information += $MyDetails 
		} 
	} 
} 
$Information 
 