Connect-VIServer "hpvvcs001"

$ClusterReport = @()
Foreach($cluster in Get-Cluster ){
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
    $ClusterReport += $row
}

$HostReport = @()
ForEach ($esx in ($Cluster | Get-VMhost | Sort-Object -Property Name)) { 
  $Report = "" | select Hostname, version, Build, manufacture, Model,cpu_model, core_num, totalmemoryMB
  $Report.Hostname = $esx.Name
  $Report.version =$esx.Version
  $Report.Build =$esx.Build
  $Report.manufacture =$esx.ExtensionData.Hardware.SystemInfo.Vendor
  $Report.Model =$esx.Model
  $Report.cpu_model =$esx.ExtensionData.Summary.Hardware.CpuModel
  $Report.core_num =$esx.ExtensionData.Hardware.CpuInfo.NumCpuCores
  $Report.totalmemoryMB =$esx.MemoryTotalMB
  $HostReport += $Report
}

$VmInventory = @()
ForEach ($VM in ($Cluster | Get-VM | Sort-Object -Property Name)){
  ForEach ($HardDisk in ($VM | Get-HardDisk | Sort-Object -Property Name)){
    $VmInventory += "" | Select-Object -Property @{N="VM";E={$VM.Name}},
    @{N="Cluster";E={$Cluster.Name}},
    @{N="Host";E={$vm.Host.Name}},
    @{N="IP";E={[string]::Join(',',$VM.Guest.IPAddress)}},
    @{N="NIC";E={$vm.NetworkAdapters.Count}},
    @{N="Operating System";E={$vm.Guest.OSFullName}},
    @{N="CPU";E={$vm.NumCpu}},
    @{N="Memory(GB)";E={($VM | select -ExpandProperty MemoryMB)/1KB}},
    @{N="Hard Disk";E={$HardDisk.Name}},
    @{N="VMConfigFile";E={$VM.ExtensionData.Config.Files.VmPathName}},
    @{N="VMDKpath";E={$HardDisk.FileName}},
    @{N="VMDK Size";E={($vm.extensiondata.layoutex.file|?{$_.name -contains $harddisk.filename.replace(".","-flat.")}).size/1GB}}
  }
}
$ClusterReport | Export-Csv -NoTypeInformation -UseCulture -Path "ClustersReport.csv"
$HostReport | Export-Csv –NoTypeInformation -useCulture -Path "HostsReport.csv" 
$VmInventory | Export-Csv -NoTypeInformation -UseCulture -Path "VmsInventory.csv"

