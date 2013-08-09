# Apply host profile to any non-compliant host
Get-Cluster Prod01 |
Get-VMHost | 
Test-VMHostProfileCompliance | 
    ForEach-Object {
        $profile = Get-VMHostProfile $_.VMHostProfile
        Set-VMHost -State 'Maintenance' -VMHost $_.VMhost |
            Apply-VMHostProfile -Profile $Profile |
            Set-VMHost -State 'Connected' |
            Test-VMHostProfileCompliance
    }
