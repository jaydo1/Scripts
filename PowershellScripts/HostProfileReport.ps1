$HPDetails = @()
Foreach ($VMHost in Get-VMHost) {
	$HostProfile = $VMHost | Get-VMHostProfile
	if ($VMHost | Get-VMHostProfile) {
		$HP = $VMHost | Test-VMHostProfileCompliance
		If ($HP.ExtensionData.ComplianceStatus -eq "nonCompliant") {
			Foreach ($issue in ($HP.IncomplianceElementList)) {
				$Details = "" | Select VMHost, Compliance, HostProfile, IncomplianceDescription
				if ($HP.VMHostProfile -eq $null) {$Details.HostProfile = $HostProfile.Name}
				else {$Details.HostProfile = $HP.VMHostProfile}
				$Details.Compliance = $HP.ExtensionData.ComplianceStatus
				$Details.HostProfile = $HP.VMHostProfile
				$Details.IncomplianceDescription = $Issue.Description
				$HPDetails += $Details
			}
		} Else {
			$Details = "" | Select VMHost, Compliance, HostProfile, IncomplianceDescription
			$Details.VMHost = $VMHost.Name
			$Details.Compliance = "Compliant"
			$Details.HostProfile = $HostProfile.Name
			$Details.IncomplianceDescription = ""
			$HPDetails += $Details
		}
	} Else {
		$Details = "" | Select VMHost, Compliance, HostProfile, IncomplianceDescription
		$Details.VMHost = $VMHost.Name
		$Details.Compliance = "No profile attached"
		$Details.HostProfile = ""
		$Details.IncomplianceDescription = ""
		$HPDetails += $Details
	}
}
$HPDetails