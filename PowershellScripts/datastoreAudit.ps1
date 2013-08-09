$report = @()

foreach($cluster in Get-Cluster){
    Get-VMHost -Location $cluster | Get-Datastore | %{
        $info = "" | select DataCenter, Cluster, Name, Capacity, Provisioned, Available 
        $info.Datacenter = $_.Datacenter
        $info.Cluster = $cluster.Name
        $info.Name = $_.Name 
        $info.Capacity = [math]::Round($_.capacityMB/1024,2) 
        $info.Provisioned = [math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2) 
        $info.Available = [math]::Round($info.Capacity - $info.Provisioned,2) 
        $report += $info
    }
}

$report | Export-Csv "C:\cluster-ds.csv" -NoTypeInformation -UseCulture 