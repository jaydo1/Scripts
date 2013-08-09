#get VM where harddisk are thick formated 
Get-VM | Get-HardDisk | where{$_.storageformat -eq 'thick'} 