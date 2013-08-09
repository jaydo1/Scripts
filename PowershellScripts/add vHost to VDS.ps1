# Add a VMhost to a vDS
Get-VMhost �vSphere01*� |
    Add-DistributedSwitchVMHost -VMhost $_ `
         -DistributedSwitch vDS01 `
         -Pnic vmnic2,vmnic3