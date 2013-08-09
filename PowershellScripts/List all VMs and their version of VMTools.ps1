# List all virtual machines and their version of VMTools: 

Connect-VIServer MYVISERVER

$VMTools = @() 
Foreach ($VM in (Get-VM)){ 
  $MyDetails = "" | Select-Object Name, Tools 
  $MyDetails.Name = $vm.Name 
  $MyDetails.Tools = $vm.config.tools.toolsVersion 
  $VMTools += $MyDetails 
} 
$VMTools 