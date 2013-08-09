param (
	[switch] $Physical = $false, 
	[switch] $Virtual = $true
)

Process {
	if ( $_ -isnot [VMware.VimAutomation.Client20.VMHostImpl] ) {
		Write-Error "VMHost expected, skipping object in pipeline."
		continue
	}
	$net = Get-VMHostNetwork -VMHost $_
	if ( $Physical ) {
		$net | Select-Object -expandProperty PhysicalNic
	}
	if ( $Virtual ) {
		$net | Select-Object -expandProperty VirtualNic
	}
}