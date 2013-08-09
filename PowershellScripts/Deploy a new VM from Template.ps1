# Deploys a virtual machine called NewVM from a template called 
# Windows2003SP1-GOLD to a host called MyESXHost.mydomain.com 

Connect-VIServer MYVISERVER

New-VM -Name "NewVM" -Template "Windows2003SP1-GOLD" -VMHost (Get-VMHost "MyESXHost.mydomain.com")