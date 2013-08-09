# Upgrade VMware Tools on all VMs: 

Connect-VIServer MYVISERVER

Get-VM | Update-Tools 
 
# Upgrade VMware Tools on a single virtual machine called PROD1: 

Connect-VIServer MYVISERVER

Get-VM PROD1 | Update-Tools 
 
