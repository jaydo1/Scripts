#Usage migrate-storage -vc vcenter -datastores ("datastore1","datastore2","datastore3")

#lets get our cli args
param([string]$vc = "vc", [string[]]$datastores = "datastores")
 
#add the snapin, just in case
Add-PSSnapin VMware.VimAutomation.Core
 
#check to make sure we have both args we need
if (($vc -eq "vc") -or ($datastores -eq "datastores"))
	{
	write-host `n "Migrate-Datastores moves all running VMs from one LUN to a new LUN of the same name with `"_New`" on the end" `n
	Write-host `n "Required parameters are vc and datastore" `n `n "Example: `"Migrate-Datastores -vc vcenterserver -datastores `(`"datastore1`",`"datastore2`",`"datastore3`)`"`"" `n
	break
	}
 
#connect to VC
 
Connect-VIServer $vc
 
write-host "Migrating these datastores:" $datastores
 
foreach ($datastore in $datastores)
{
    Write-host "Moving all Servers residing on" $datastore
    $servers = get-vm -datastore $datastore
    foreach ($server in $servers)
        {
        $datastore_new = $datastore.ToString() + "_New"
        write-host "Moving" $server "from" $datastore "to" $datastore_new
        Move-VM $server -datastore $datastore_new
        }
}
 
Write-host "Done moving to new LUNs"
 
Disconnect-VIServer -confirm:$false