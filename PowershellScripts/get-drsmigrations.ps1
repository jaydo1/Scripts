
function get-DRSMigrations {
<#
    .Synopsis
        Retrieves DRS migrations over set time .
    .Description
        Queries the local VC events for DRS migrations over a set time and save them to a csv file 
    .Parameter 
    .Example
        C:\PS> get-DRSMigations

                                                                                                                                                                                                                                                      

        Description
        -----------
        Retrieves the DRS migration over set date 

    .Example
        C:\PS> get-drsmigration | out-file c:\drsmigration.csv

        
        Description
        -----------
        Retrieves the DRS migrations over set date 

    .Notes
        AUTHOR:Jamie Smith     
    #>

$DRSMigrateAge = Read-host "enter number of days" 

Get-VIEvent -maxsamples ([int]::MaxValue) -Start (Get-Date).AddDays(-$DRSMigrateAge ) | where {$_ -is [VMware.Vim.DrsVmMigratedEvent]} | select createdTime, fullFormattedMessage }