# Get a list of all WWNs for all HBAs in MyESXHost.mydomain.com 
 
Connect-VIServer MYVISERVER

$ESXHost = get-vmhost "MyESXHost.mydomain.com" | Get-View 
$storageSystem = get-view $ESXHost.ConfigManager.StorageSystem 
$storageSystem.StorageDeviceInfo.HostBusAdapter | select Device, Model, PortWorldWideName, NodeWorldWideName 