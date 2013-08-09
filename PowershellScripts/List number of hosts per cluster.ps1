# Reports a list of each cluster name and the number of hosts within the cluster

Connect-VIServer MYVISERVER

Get-Cluster | Select Name, @{N="NumHosts";E={@(($_ | Get-VMHost)).Count}} | Sort Name 