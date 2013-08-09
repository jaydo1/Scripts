$cluster = Read-Host "enter cluster name"
Get-Cluster $cluster
$VMhosts = Get-VMHost -location (Get-Cluster $cluster)

foreach($esxhost in $VMhosts){  
$esxcli = Get-EsxCli -VMhost $esxhost
$esxcli.system.syslog.reload()
}