###################################################################################
# Listing 5.2: Querying vCenter for operating systems and Guest IDs
###################################################################################
Function Get-VMGuestId
{
    <#
    .SYNOPSIS
        Query VMHost for a list of the supported Operating systems, and their
        GuestIds.
    .DESCRIPTION
        Query VMHost for a list of the supported Operating systems, and their
        GuestIds.
    .PARAMETER VMHost
        VMHost to query for the list of Guest Id's
    .PARAMETER Version
        Virtual Machine Hardware version, if not supplied the default for that
        host will be returned. I.E. ESX3.5 = 4, vSphere = 7
    .EXAMPLE
        Get-VMGuestId -VMHost vSphere1
    .EXAMPLE
        Get-VMGuestId -VMHost vSphere1 | Where {$_.family -eq 'windowsGuest'} 
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true
        ,   HelpMessage="VMHost object to scan for suppported Guests."
        ,   ValueFromPipeline=$true
        )]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
        $VMHost
    ,
        [int]
        $Version
    )
    Process
    {
        $HostSystem = Get-View -VIObject $VMHost
        $compResource = Get-View -id $HostSystem.Parent
        $EnvironmentBrowser = Get-View -Id $compResource.EnvironmentBrowser
        $VMConfigOptionDescriptors =$EnvironmentBrowser.QueryConfigOptionDescriptor()

        if ($Version)
        {
            $Key = $VMConfigOptionDescriptors |
                Where-Object {$_.key -match "$($Version)$"} |
                Select-Object -ExpandProperty Key
        }
        Else
        {
            $Key = $VMConfigOptionDescriptors |
                Where-Object {$_.DefaultConfigOption} |
                Select-Object -ExpandProperty Key
        }
        #$EnvironmentBrowser.QueryConfigOption($Key, $HostSystem.MoRef) 
        $EnvironmentBrowser.QueryConfigOption($Key, $HostSystem.MoRef) |
            Select-Object -ExpandProperty GuestOSDescriptor | 
            Select-Object @{
                    Name='GuestId' 
                    Expression={$_.Id}
                },
                @{
                    Name='GuestFamily'
                    Expression={$_.Family}
                },
                @{        
                    Name='FullName'
                    Expression={$_.FullName}
                }
    }
}