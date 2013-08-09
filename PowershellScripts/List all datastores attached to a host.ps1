# Gets a list of all datastores attached to MyESXHost.mydomain.com 

Connect-VIServer MYVISERVER

Get-Datastore -VMHost (Get-VMHost "MyESXHost.mydomain.com") 