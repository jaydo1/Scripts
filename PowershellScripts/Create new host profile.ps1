# Create a new host profile
New-VMHostProfile -Name Prod01 `
    -ReferenceHost (Get-VMHost vSphere01*) `
    -Description "Host profile for cluster Prod01"