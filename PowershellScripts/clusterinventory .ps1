Connect-VIServer hpvvcs001

$clusterName = Read-host "enter Cluster name" 
$cluster = Get-Cluster -Name $clusterName


$clusterInfo = New-Object PSObject -Property @{
    VCname = $cluster.Uid.Split(':@')[1]
    DCname = (Get-Datacenter -Cluster $cluster).Name
    Clustername = $cluster.Name
    "Total Physical Memory (GB)" = "{0:f1}" -f (($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum / 1KB)
    "Configured Memory (GB)" = "{0:f1}" -f (($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum / 1KB)
    "Available Memory (GB)" = "{0:f1}" -f (($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum / 1KB)
    "Total CPU (Mhz)" = ($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
    "Configured CPU (Mhz)" = ($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
    "Available CPU (Mhz)" = ($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum
    "Total Disk Space (GB)" = "{0:f1}" -f (($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityMB -Sum).Sum / 1KB)
    "Configured Disk Space (GB)" = "{0:f1}" -f (($ds | Measure-Object -InputObject {$_.CapacityMB - $_.FreeSpaceMB} -Sum).Sum / 1KB)
    "Available Disk Space (GB)" = "{0:f1}" -f (($ds | Measure-Object -Property FreeSpaceMB -Sum).Sum / 1KB)
    "Nr of hosts" = @($esx).Count
    "Nr of VMs" = ($esx | Measure-Object -InputObject {$_.Extensiondata.Vm.Count} -Sum).Sum
}

$VmInventory = ForEach ($VM in ($Cluster | Get-VM | Sort-Object -Property Name)){
      ForEach ($HardDisk in ($VM | Get-HardDisk | Sort-Object -Property Name)){
        "" | Select-Object -Property @{N="VM";E={$VM.Name}},
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
 


$clusterInfo | Export-Csv -NoTypeInformation -UseCulture -Path "ClusterInfo.csv" 
$VmInventory | Export-Csv -NoTypeInformation -UseCulture -Path "VmInventory.csv"
