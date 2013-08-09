Process {
    if ( $_.gettype().Name -ne 'VMHostImpl' ) {
        Throw ( 'Pipeline must contain VMHost (ESX Server) objects.' )
    }
    $HostView = $_ | Get-View # Obtain managed object view of VMHost

    # Create custom object to hold output
    $Process = "" | Select-Object "VMHostName", "Condition", "ConnectionState",
        "PowerState", "CpuUsage%", "CpuUsageMhz", "MemoryUsage%", "MemoryUsageMB"

    # Assign values to custom object
    $Process.VMHostName = $_.Name
    # The OverallStatus property is set to green, yellow or red
    $Process.Condition = $HostView.Summary.OverallStatus
    $Process.ConnectionState = $HostView.Runtime.ConnectionState
    $Process.PowerState = $HostView.Runtime.PowerState
    $Process.CpuUsageMhz = $HostView.Summary.Quickstats.OverallCpuUsage
    $CpuTotalMhz = $HostView.Summary.Hardware.CpuMhz * $HostView.Summary.Hardware.NumCpuCores
    $Process."CpuUsage%" = [math]::Round( ( $Process.CpuUsageMhz  / $CpuTotalMhz ), 2 ) * 100
    $Process.MemoryUsageMB = $HostView.Summary.Quickstats.OverallMemoryUsage 
    $MemTotalBytes = $HostView.Summary.Hardware.MemorySize
    $Process."MemoryUsage%" = [math]::Round(
        ( $Process.MemoryUsageMB * 1MB / $MemTotalBytes ) ,2
    ) * 100
    Write-Output $Process
}