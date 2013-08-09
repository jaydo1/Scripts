function get-serialnumber {
<#
    .Synopsis
        Retrieves the machines serial number from the bios.
    .Description
        Queries the local, or optionally remote machines serial number and returns it.
    .Parameter computername
        (Optional) the computername you wish to query.
    .Example
        C:\PS> get-serialnumber

        serialnumber
        ------------
        8DZ5X2J                                                                                                                                                                                                                                                            

        Description
        -----------
        Retrieves the serial number of the local machine and returns it.

    .Example
        C:\PS> get-serialnumber -computername xps

        serialnumber
        ------------
        8DZ5X2J 

        Description
        -----------
        Retrieves the serial number on the remote machine and returns it.

    .Notes
        AUTHOR:     Andrew Morgan
        Notes: this is confirmed to work on IBM and Dell Hardware, for other vendors this should work but is untested.        

    #>

    param(
    [Parameter(HelpMessage="Server Name, Default is Localhost")]
    [string]$computername=$env:computername)

    Return $serial=get-wmiobject win32_bios -computername $computername |
     select-object serialnumber}