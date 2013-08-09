$vmName = "MyVMName"
$destDatastoreName = "MyDatastoreName"
 
$vmQuery = Search-Cloud -QueryType AdminVM -Name $vmName
 
if ($destDatastoreName -eq $vmQuery.datastoreName)
{
 Write-Host -ForegroundColor Red "You are trying to sVmotion to the same Datastore."
 break
}
else
{
 $vm = Get-CIVM $vmName
 $dsQuery = Search-Cloud -QueryType Datastore -Name $destDatastoreName
 $dsRef = New-Object vmware.vimautomation.cloud.views.reference
 $dsRef.Href = "https://$($global:DefaultCIServers[0].name)/api/admin/extension/datastore/$($dsquery.id.split(':')[-1])"
 $vm.ExtensionData.Relocate($dsRef)
}
