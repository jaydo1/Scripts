# Add the NFSStore01 NFS share to all hosts in the Non Production cluster. 
 
Connect-VIServer MYVISERVER

Get-Cluster "Non Production" | Get-VMHost | New-Datastore -Nfs -Name NFSStore01 -NFSHost nfs.mydomain.com -Path NFSStore01 