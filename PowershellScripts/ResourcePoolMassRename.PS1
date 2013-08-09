# Change these values to suit
$RenameSet = @(
	@{ OldName = "Gold";     NewName = "High" },
	@{ OldName = "Silver";     NewName = "Medium" },
	@{ OldName = "Bronze";     NewName = "Low" }
)

$NameCount = $RenameSet.Count
Write-Host "Retriving resource pools"
$ResPool = Get-ResourcePool

# Loop through each old name
for ( $i = 0; $i -lt $NameCount; $i++ ) {
	Write-Progress -activity 'Rename Resource Pools' -id 1 `
		-Status $RenameSet[$i].OldName `
		-percentComplete ( $i / $NameCount * 100 )

	# Grab just the ones which match the old name
	$ToRename = $ResPool | Where-Object { $_.Name -eq $RenameSet[$i].OldName }
	$RenameCount = $ToRename.Count
	
	# Loop through each of the matches
	for ( $j = 0; $j -lt $RenameCount; $j++ ) {
		Write-Progress -activity "Resource Pool" -parentId 1 `
			-status $ToRename[$j].Id `
			-currentOperation "Renaming..." `
			-percentComplete ( ( $j + 1 ) / $RenameCount * 100 )
		
		# This is the only line which actually does real work! Remove the WhatIf to make changes
		Set-ResourcePool -ResourcePool $ToRename[$j] -Name $RenameSet[$i].NewName -WhatIf
	}
}