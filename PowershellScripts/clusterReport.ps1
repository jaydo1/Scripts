$report = @()
# $clusterName = "MyCluster"  
$clusterName = "*" 

foreach($cluster in Get-Cluster -Name $clusterName){
    $esx = $cluster | Get-VMHost    
    $ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS" -and (Get-View $_).Summary.MultipleHostAccess}
        
    $row = "" | Select VCname,DCname,Clustername,"Total Physical Memory (GB)",
                "Configured Memory (GB)","Available Memroy (GB)",
                "Total CPU (Mhz)","Configured CPU (Mhz)",
                "Available CPU (Mhz)","Total Disk Space (GB)",
                "Configured Disk Space (GB)","Available Disk Space (GB)",
                "Nr of hosts","Nr of VMs"
    $row.VCname = $cluster.Uid.Split(':@')[1]
    $row.DCname = (Get-Datacenter -Cluster $cluster).Name
    $row.Clustername = $cluster.Name
    $row."Total Physical Memory (GB)" = "{0:f1}" -f (($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum / 1KB)
    $row."Configured Memory (GB)" = "{0:f1}" -f (($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum / 1KB)
    $row."Available Memroy (GB)" = "{0:f1}" -f (($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum / 1KB)
    $row."Total CPU (Mhz)" = ($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
    $row."Configured CPU (Mhz)" = ($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
    $row."Available CPU (Mhz)" = ($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum
    $row."Total Disk Space (GB)" = "{0:f1}" -f (($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityMB -Sum).Sum / 1KB)
    $row."Configured Disk Space (GB)" = "{0:f1}" -f (($ds | Measure-Object -InputObject {$_.CapacityMB - $_.FreeSpaceMB} -Sum).Sum / 1KB)
    $row."Available Disk Space (GB)" = "{0:f1}" -f (($ds | Measure-Object -Property FreeSpaceMB -Sum).Sum / 1KB)
    $row."Nr of hosts" = @($esx).Count
    $row."Nr of VMs" = ($esx | Measure-Object -InputObject {$_.Extensiondata.Vm.Count} -Sum).Sum
    $report += $row
} 
$report | Export-Csv "C:\Cluster-Report.csv" -NoTypeInformation -UseCulture