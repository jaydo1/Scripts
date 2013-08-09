# Set a boot delay of 5 seconds on all VMs

Connect-VIServer MYVISERVER

$BootDelay = "5000" 
Get-VM | ForEach-Object { 
	$vm = Get-View $_.Id 
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec 
	$vmConfigSpec.BootOptions = New-Object VMware.Vim.VirtualMachineBootOptions 
	$vmConfigSpec.BootOptions.BootDelay = $BootDelay 
	$vm.ReconfigVM_Task($vmConfigSpec) 
} 