$DRSMigrateAge = 1 

Get-VIEvent -maxsamples ([int]::MaxValue) -Start (Get-Date).AddDays(-$DRSMigrateAge ) | where {$_ -is [VMware.Vim.DrsVmMigratedEvent]} | select createdTime, fullFormattedMessage | Out-File c:\drsmirgartion.csv