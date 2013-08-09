<#
.SYNOPSIS
Send an email with an object in a pretty table
.DESCRIPTION
Send email
.PARAMETER InputObject
Any PSOBJECT or other Table
.PARAMETER Subject
The Subject of the email
.PARAMETER To
The To field is who receives the email
.PARAMETER From
The From address of the email
.PARAMETER CSS
This is the Cascading Style Sheet that will be used to Style the table
.PARAMETER SmtpServer
The SMTP relay server
.EXAMPLE
PS C:\> Send-HtmlEmail -InputObject (Get-process *vmware* | select CPU, WS) -Subject "This is a process report"
An example to send some process information to email recipient
.NOTES
NAME        :  Send-HtmlEmail
VERSION     :  1.0.0   
LAST UPDATED:  03/29/2010
AUTHOR      :  http://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=Ben%20Wilkinson
.INPUTS
None
.OUTPUTS
None
#> 

function Send-HTMLEmail {
#Requires -Version 2.0
[CmdletBinding()]
 Param 
   ([Parameter(Mandatory=$True,
               Position = 0,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Please enter the Inputobject")]
    $InputObject,
    [Parameter(Mandatory=$True,
               Position = 1,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Please enter the Subject")]
    [String]$Subject,    
    [Parameter(Mandatory=$False,
               Position = 2,
               ValueFromPipeline=$false,
               ValueFromPipelineByPropertyName=$false,
               HelpMessage="Please enter the To address")]    
    [Array]$To = "myuser@domain.org",
    [String]$From = "Admin@domain.org",    
    [String]$CSS,
    [String]$SmtpServer ="relay.nyumc.org"
   )#End Param

if (!$CSS)
{
    $CSS = @"
    <style type="text/css">
     table {
    	font-family: Verdana;
    	border-style: dashed;
    	border-width: 1px;
    	border-color: #FF6600;
    	padding: 5px;
    	background-color: #FFFFCC;
    	table-layout: auto;
    	text-align: center;
    	font-size: 8pt;
     }

     table th {
    	border-bottom-style: solid;
    	border-bottom-width: 1px;
     }
     table td {
    	border-top-style: solid;
    	border-top-width: 1px;
     }
     .style1 {
        font-family: Courier New, Courier, monospace;
        font-weight:bold;
        font-size:small;
     }
     </style>
"@
}#End if

$HTMLDetails = @{
    Title = $Subject
    Head = $CSS
    }
    
$Splat = @{
    To         =($To)
    Body       ="$($InputObject | ConvertTo-Html @HTMLDetails)"
    Subject    =$Subject
    SmtpServer =$SmtpServer
    From       =$From
    BodyAsHtml =$True
    }
    Send-MailMessage @Splat
    
}#Send-HTMLEmail