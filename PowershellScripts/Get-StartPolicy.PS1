Process {
	$current = $_
	switch ( $current.GetType().Name ) {
		"VMHostImpl"			{
			$StartPolicy = Get-VMHostStartPolicy -VMHost $current
			$StartPolicy | Add-Member -Name InputObject -Value $current `
				-MemberType NoteProperty -PassThru
		}
		"VirtualMachineImpl"	{
			$StartPolicy = Get-VMStartPolicy -VM $current
			$StartPolicy | Add-Member -Name InputObject -Value $current `
				-MemberType NoteProperty -PassThru
		}
		Default					{ 
			Throw "Pipeline input must contain VMHost (ESX Server) or VM objects."
		}
	}	
}