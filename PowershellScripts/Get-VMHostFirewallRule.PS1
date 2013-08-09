param ( 
	[switch] $ShowDisabled = $false
)
Process {
	if ( $_ -isnot [VMware.VimAutomation.Client20.VMHostImpl] ) {
		Write-Error "VMHost expected, skipping object in pipeline."
		continue
	}
	$HostView = $_ | Get-View
	$FWSystem = Get-View $HostView.ConfigManager.FirewallSystem
	$FWRuleset = $FWSystem.FirewallInfo.Ruleset
	if ( $ShowDisable ) { Write-Output $FWRuleset }
	else {
		Write-Output $FWRuleset | Where-Object { $_.Enabled }
	}
}