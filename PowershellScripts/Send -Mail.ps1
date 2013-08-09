#Here is a function that can send mails to multiple recipients. Just fill in the placeholders with your SMTP server and credentials:

function Send-Mail {
    param(
     [Parameter(Mandatory=$true)]
     [String[]]
     $To,        
     [Parameter(Mandatory=$true)]
     $Body,
     $Subject = 'Email from YOURNAME',
     $From = 'YOURNAME@company.com',
     $SmtpServer = 'YOURSMTPSERVER',
     $Credential = $(New-Object System.Management.Automation.PSCredential('YOURLOGONNAME', 'YOURLOGONPASSWORD' | ConvertTo-SecureString -AsPlainText -Force))
    ) 
    try {
      Send-MailMessage -To $To -Body $Body -Subject $Subject -From $From -SmtpServer $SMTPServer -Credential $Credential -ErrorAction Stop
      Write-Host 'Email successfully sent.' -ForegroundColor Green
    }
    catch {
        Write-Host "Email did not go through: $_" -ForegroundColor Red
    }
} 
