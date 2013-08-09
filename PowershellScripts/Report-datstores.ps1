@"
===============================================================================
Title:             Report-Datastores.ps1
Description:     Report Datastore usage for all Datastores managed by vCenter
Requirements:     Windows Powershell and the VI Toolkit
Usage:            .\Report-Datastores.ps1
===============================================================================
"@

#Global Functions
#This function generates a nice HTML output that uses CSS for style formatting.
function Generate-Report {
    Write-Output "<html><head><title></title><style type=""text/css"">.Error {color:#FF0000;font-weight: bold;}.Title {background: #0077D4;color: #FFFFFF;text-align:center;font-weight: bold;}.Normal-left {text-align:left;}.Normal {text-align:right;}</style></head><body><table><tr class=""Title""><td colspan=""4"">VMware Datastore Report</td></tr><tr><td>Datastore  </td><td>Capacity(GB)  </td><td>Used(GB)  </td><td>% Free  </td></tr>"

                Foreach ($store in $report){
                    Write-Output "<td class=""Normal-left"">$($store.name)</td><td class=""Normal"">$($store.CapacityGB)</td><td class=""Normal"">$($store.UsedGB)</td><td class=""Normal"">$($store.PercFree)</td></tr> "
                }
        Write-Output "</table></body></html>"
    }

#Login details
$username = 'changeme'
$password = 'supersecret'

#Current, Previous, Difference File information
$digits = 2
$Folder = 'C:\Reports'

#List of servers including Virtual Center Server.  The account this script will run as will need at least Read-Only access to Cirtual Center
$VIServer = "vc1.example.net"    #Chance to DNS Names/IP addresses of your ESXi servers or Virtual Center Server

#Initialise Array
$Report = @()

# Connect to Virtual Center
$VC = Connect-VIServer $VIServer -user $username -password $password

# Get all datastores and put them in alphabetical order
#$datastores = Get-Datastore | Sort-Object Name

#Get all datastores and put them in alphabetical order
        foreach ($server in $serverlist){

        # Check is server is a Virtual Center Server and connect with current user
        if ($server -eq "VCServer"){Connect-VIServer $VIServer}

        # Use specific login details for the rest of servers in $serverlist
        else {Connect-VIServer $VIServer -user $username -password $password}

        Get-Datastore | Sort-Object Name | %{
            $Store = {} | Select Name, CapacityGB, UsedGB, PercFree
            $Store.Name = $_.name
            $Store.CapacityGB = [math]::Round($_.capacityMB/1024,$digits)
            $Store.UsedGB = [math]::Round(($_.CapacityMB - $_.FreeSpaceMB)/1024,$digits)
            $Store.PercFree = [math]::Round(100*$_.FreeSpaceMB/$_.CapacityMB,$digits)
            $Report += $Store
                                }
        # Disconnect from Virtual Center
        Disconnect-VIServer -Confirm:$False
        }

# Disconnect from Virtual Center
Disconnect-VIServer * -Confirm:$False

# Generate the report and email it as a HTML body of an email
Generate-Report > "$Folder\Report-Datastore.html"
    IF ($Report -ne ""){
    $SmtpClient = New-Object system.net.mail.smtpClient
    $SmtpClient.host = "my.smtp.host"   #Change to a SMTP server in your environment
    $MailMessage = New-Object system.net.mail.mailmessage
    $MailMessage.from = "System.Automation@example.com"   #Change to email address you want emails to be coming from
    $MailMessage.To.add("yomomma@example.com")    #Change to email address you would like to receive emails.
    $MailMessage.IsBodyHtml = 1
    $MailMessage.Subject = "VMware Datastore Report"
    $MailMessage.Body = Generate-Report
    $SmtpClient.Send($MailMessage)}