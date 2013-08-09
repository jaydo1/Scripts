$Title = "VMs Ballooning or Swapping"
$Header =  "VMs Ballooning or Swapping : $($bs.count)"
$Comments = "Ballooning and swapping may indicate a lack of memory or a limit on a VM, this may be an indication of not enough memory in a host or a limit held on a VM, <a href='http://www.virtualinsanity.com/index.php/2010/02/19/performance-troubleshooting-vmware-vsphere-memory/' target='_blank'>further information is available here</a>."
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$BALSWAP = $vm | Where {$_.PowerState -eq "PoweredOn" }| Select Name, VMHost, @{N="SwapKB";E={(Get-Stat -Entity $_ -Stat mem.swapped.average -Realtime -MaxSamples 1 -ErrorAction SilentlyContinue).Value}}, @{N="MemBalloonKB";E={(Get-Stat -Entity $_ -Stat mem.vmmemctl.average -Realtime -MaxSamples 1 -ErrorAction SilentlyContinue).Value}}
@($BALSWAP | Where { $_.SwapKB -gt 0 -or $_.MemBalloonKB -gt 0}) | Sort SwapKB -Descending
