###################################################################################
# Cmdlets to create a New-VM
###################################################################################
New-VM -Name REL5_01 `
   -DiskMB 10240 `
   -DiskStorageFormat thin
   -MemoryMB 1024 `
   -GuestId rhel5Guest `
   -NetworkName vSwitch0_VLAN22 `
   -CD |
   Get-CDDrive | 
      Set-CDDrive -IsoPath "[datastore0] /REHL5.2_x86.iso" `
         -StartConnected:$true `
         -Confirm:$False