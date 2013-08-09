# Registers PROD1 from the SAN001 datastore onto a host called 
# MyHost in the MyDataCenter DataCenter: 

Connect-VIServer MYVISERVER

Get-VM PROD1 | Set-VM –MemoryMB (256GB / 1MB) 
 
$Datacenter = "MyDataCenter" 
$ESXHost = "MyESXHost.mydomain.com" 
 
$ResourcePool = Get-VMHost $ESXHost | Get-ResourcePool | Get-View 
$vmFolder = Get-View (Get-Datacenter -Name $Datacenter | Get-Folder -Name "vm").id 
$vmFolder.RegisterVM_Task("[SAN001] PROD1\PROD1.vmx", "PROD1", $false, $ResourcePool.MoRef, $null)