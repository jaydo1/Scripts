<#
$Id$
$URL$

VERSION
	2.3
SUMMARY	
	Exports VM Information from vCenter into a .CSV file
DESCRIPTION
	Exports VM Information from vCenter into a .CSV file
NOTES
	By Julian Rattue. 
	LUCD
	wooditwork.com
PARAMETERS
	Enter VC names in $VCServerName
CHANGES
	2.0 Folder path extract in Lines 25-42 has stopped functioning so have removed in v2.0
	2.1 Removed depreciate commands: 
		line 77. $vm.HardDisks was replaced with $vm | Get-HardDisk. 
		line 73. $VMInfo.Cluster = $vm.host.Parent.Name was replaced with $vm.vmhost.Parent.Name
	2.2 Updated get-folderpath function and added folder path location back into script.
	2.3 Added email notification
FUTURE CHANGES
	
#>
#
 filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name
 
        $current = Get-View $_.Parent
#        $path = $_.Name # Uncomment out this line if you want the VM Name to appear at the end of the path
        $path = ""
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}
#>

$VCServerName = "hpvvcs001"
$VC = Connect-VIServer $VCServerName
$VMFolder = "*"
$TimeStamp = Get-Date -format "yyyyMMdd-HH.mm"
$Csvfile = "c:\temp\$VCServerName-VMExtract.csv"
 
$Report = @()
$VMs = Get-Folder $VMFolder | Get-VM
 
$Datastores = Get-Datastore | select Name, Id
$VMHosts = Get-VMHost | select Name, Parent
$Annotation1 = "Managed By"

If (Test-Path "$Csvfile")
{
	Remove-Item -Path "$Csvfile" -Force
}

Write-Host = "1. Gathering information from" $VCServerName -ForegroundColor Yellow
 
ForEach ($VM in $VMs) {
      $VMView = $VM | Get-View
      $VMInfo = {} | Select DC,VMName,Powerstate,OS,Folder,IPAddress,ToolsStatus,Cluster,Datastore,NumCPU,MemMB,DiskGB,DiskFreeGB,DiskUsedGB,Notes,"Managed By"
      $VmInfo.DC = (Get-Datacenter -VM $vm).name
      $VMInfo.VMName = $vm.name
      $VMInfo.Powerstate = $vm.Powerstate
      $VMInfo.OS = $vm.Guest.OSFullName
      $VMInfo.Folder = ($vm | Get-Folderpath).Path
      $VMInfo.IPAddress = $vm.Guest.IPAddress[0]
      $VMInfo.ToolsStatus = $VMView.Guest.ToolsStatus
      #$VMInfo.Host = $vm.vmhost.name
      $VMInfo.Cluster = $vm.vmhost.Parent.Name
      $VMInfo.Datastore = ($Datastores | where {$_.ID -match (($vmview.Datastore | Select -First 1) | Select Value).Value} | Select Name).Name
      $VMInfo.NumCPU = $vm.NumCPU
      $VMInfo.MemMB = [Math]::Round(($vm.MemoryMB),2)
	  $VMInfo.DiskGB = [Math]::Round((($vm | Get-HardDisk | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
      $VMInfo.DiskFreeGB = [Math]::Round((($vm.Guest.Disks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB),2)
      $VMInfo.DiskUsedGB = $VMInfo.DiskGB - $VMInfo.DiskFree
      $VMInfo.Notes = $vm.Notes 
      $VMInfo.("Managed By") = ($vm | Get-Annotation -name $Annotation1).value
      $Report += $VMInfo
}
$Report = $Report | Sort-Object VMName
IF ($Report -ne "") {
$report | Export-Csv $Csvfile -NoTypeInformation
}
Write-Host = "2. Script is complete...goto" $Csvfile -ForegroundColor Green
Write-Host = "3. Sending report" $Csvfile -ForegroundColor Green

# SMTP email details
$smtpServer = "smtp.det.nsw.edu.au"
$att = new-object Net.Mail.Attachment($Csvfile)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "upvutl001@det.nsw.edu.au"
$msg.To.Add("ITInfraservvmwaresupport@det.nsw.edu.au")
#$msg.To.Add("julian.rattue@det.nsw.edu.au")
$msg.Subject = "VM Extract for " + $VCServerName  
$msg.Body = "Attached is the VM extract for " + $VCServerName + " which was created on " + $TimeStamp 
$msg.Attachments.Add($att)
$smtp.Send($msg)
$att.Dispose()

# Disconnect from Virtual Center
$VC = Disconnect-VIServer $VCServerName -Confirm:$False