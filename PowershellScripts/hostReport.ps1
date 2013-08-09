
$HostReport = @()
Get-VMHost |%{     
     $Report = "" | select Hostname, version, Build, manufacture, Model,cpu_model, core_num, totalmemoryMB, P_nic
     $Report.Hostname = $_.Name 
     $Report.version =$_.Version 
     $Report.Build =$_.Build 
     $Report.manufacture =$_.ExtensionData.Hardware.SystemInfo.Vendor 
     $Report.Model =$_.Model 
     $Report.cpu_model =$_.ExtensionData.Summary.Hardware.CpuModel 
     $Report.core_num =$_.ExtensionData.Hardware.CpuInfo.NumCpuCores 
     $Report.totalmemoryMB =$_.MemoryTotalMB 
     $Report.P_nic =$_.ExtensionData.Config.Network.Pnic.count 
     $HostReport += $Report
} 
$HostReport | Export-Csv "C:\HostReport.csv" –NoTypeInformation