function Get-HostDetailedNetworkInfo{
    <#
    .SYNOPSIS
        Retrieve ESX(i) Host Networking Info.
    .DESCRIPTION
        Retrieve ESX(i) Host Networking Info using CDP.
    .NOTES
        Source:  Automating vSphere Administration
        Authors: Luc Dekens, Arnim van Lieshout, Jonathan Medd,
                 Alan Renouf, Glenn Sizemore
    .PARAMETER VMHost
        Name of Host to Query
	.PARAMETER Cluster
        Name of Cluster to Query	
    .PARAMETER Filename
        Name of File to Export
    .EXAMPLE
        Get-HostDetailedNetworkInfo -Cluster Cluster01 -Filename C:\Scripts\CDP.csv
    #>
	[CmdletBinding()]
	param( 
		[String]
		$VMHost
	,
	    [String]
        $Cluster
    ,
		[parameter(Mandatory=$True
        ,    HelpMessage='Name of File to Export'
        )]
        [String]
        $filename
	)
	

Write-Host "Gathering VMHost objects"

if ($Cluster){
	$vmhosts = Get-Cluster $Cluster | Get-VMHost | Where-Object {$_.State -eq "Connected"} | Get-View
	}
else { 
	$vmhosts = Get-VMHost $VMHost | Get-View
	}

$MyCol = @()
foreach ($vmwarehost in $vmhosts){
 $ESXHost = $vmwarehost.Name
 Write-Host "Collating information for $ESXHost"
 $networkSystem = Get-View $vmwarehost.ConfigManager.NetworkSystem
 foreach($pnic in $networkSystem.NetworkConfig.Pnic){
     $pnicInfo = $networkSystem.QueryNetworkHint($pnic.Device)
     foreach($Hint in $pnicInfo){
         $NetworkInfo = "" | Select-Object Host, PNic, Speed, MAC, DeviceID, PortID, Observed, VLAN
         $NetworkInfo.Host = $vmwarehost.Name
         $NetworkInfo.PNic = $Hint.Device
         $NetworkInfo.DeviceID = $Hint.connectedSwitchPort.DevId
         $NetworkInfo.PortID = $Hint.connectedSwitchPort.PortId
         $record = 0
         Do{
             If ($Hint.Device -eq $vmwarehost.Config.Network.Pnic[$record].Device){
                 $NetworkInfo.Speed = $vmwarehost.Config.Network.Pnic[$record].LinkSpeed.SpeedMb
                 $NetworkInfo.MAC = $vmwarehost.Config.Network.Pnic[$record].Mac
             }
             $record ++
         }
         Until ($record -eq ($vmwarehost.Config.Network.Pnic.Length))
         foreach ($obs in $Hint.Subnet){
             $NetworkInfo.Observed += $obs.IpSubnet + " "
             Foreach ($VLAN in $obs.VlanId){
                 If ($VLAN -eq $null){
                 }
                 Else{
                     $strVLAN = $VLAN.ToString()
                     $NetworkInfo.VLAN += $strVLAN + " "
                 }
             }
         }
         $MyCol += $NetworkInfo
     }
 }
}
$Mycol | Sort-Object Host,PNic | Export-Csv $filename -NoTypeInformation

}
