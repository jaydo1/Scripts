# The following shows how PowerCLI can be used to detail host information

#Connect-VIServer hpvvsc001

$Information = @() 
Foreach ($ESXHost in (Get-VMHost | Get-View )){ 
  $MyDetails = "" | Select-Object Name, Type, CPU, CPUUsageMhz, MEM, MEMUsageGB 
  $MyDetails.Name = $ESXHost.Name 
  $MyDetails.Type = $ESXHost.Hardware.SystemInfo.Vendor+ " " + $ESXHost.Hardware.SystemInfo.Model 
  $MyDetails.CPU = "PROC:" + $ESXHost.Hardware.CpuInfo.NumCpuPackages + " CORES:" + $ESXHost.Hardware.CpuInfo.NumCpuCores + " MHZ: " + [math]::round($ESXHost.Hardware.CpuInfo.Hz / 1000000, 0) 
  $MyDetails.CPUUsageMhz = ($ESXHost | Measure-Object -Property CpuUsageMhz -Sum).Sum
  $MyDetails.MEM = "" + [math]::round($ESXHost.Hardware.MemorySize / 1GB, 0) + " GB" 
  $MyDetails.MEMUsageGB =  (($ESXHost | Measure-Object -Property MemoryUsageMB -Sum).Sum / 1KB)
  $Information += $MyDetails 
} 
$Information