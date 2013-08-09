# The following shows how PowerCLI can be used to scan hosts in 
# your infrastructure for new storage volumes
 
# For a Specific Host: 
Connect-VIServer MYVISERVER
Get-VMHost "MyESXHost.mydomain.com" | Get-VMHostStorage -RescanAllHBA 
 
# For a Specific Cluster: 
Connect-VIServer MYVISERVER
Get-Cluster -name "MY CLUSTER" | Get-VMHost | Get-VMHostStorage -RescanAllHBA 
 
# All Hosts in VC: 
Connect-VIServer MYVISERVER
Get-VMHost | Get-VMHostStorage –RescanAllHBA 