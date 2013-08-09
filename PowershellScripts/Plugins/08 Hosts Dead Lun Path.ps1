$Title = "Hosts Dead Lun Path"
$Header =  "Dead LunPath : $($deadluns.count)"
$Comments = "Dead LUN Paths may cause issues with storage performance or be an indication of loss of redundancy"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$deadluns = @()
foreach ($esxhost in ($VMH | where {$_.ConnectionState -eq "Connected" -or $_.ConnectionState -eq "Maintenance"}))
{
	if ((((Get-View $esxhost).configmanager.StorageSystem).StorageDeviceInfo.ScsiLun |Measure-Object).count -gt 0)
	{
		$esxluns = Get-ScsiLun -vmhost $esxhost |Get-ScsiLunPath -ErrorAction SilentlyContinue
		foreach ($esxlun in $esxluns){
			if ($esxlun.state -eq "Dead") {
				$myObj = "" |
				Select VMHost, Lunpath, State
				$myObj.VMHost = $esxhost
				$myObj.Lunpath = $esxlun.Lunpath
				$myObj.State = $esxlun.state
				$deadluns += $myObj
			}    
		}
	}
}
$deadluns
