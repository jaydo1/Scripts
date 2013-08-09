function set-VMHostAuthentication
{
<#
.SYNOPSIS
    Add or Remove a vSphere host from active directory
.DESCRIPTION
    By adding a vSphere host to an AD domain, you can use AD 
    authentication for console access, SSH and permissions on 
    the host's child objects.
.NOTES
    Authors: Luc Dekens, Glenn Sizemore
.PARAMETER VMHost
    Specify the vSphere host.
.PARAMETER Domain
    The name of the Active Directory domain in FQDN notation.
.PARAMETER User
    An Active Directory account that administrative authority 
    to add hosts to AD.
.PARAMETER Password
    The password for the AD account specified in -User
.PARAMETER Credential
    The credentials for an AD account with administrative 
    authority to add hosts to AD.
.PARAMETER Join
    A switch indicating if the host shall be added.
.PARAMETER Remove
    A switch indicating if the host shall be removed from
    The Domain.
.PARAMETER RemovePermission
    Will remove all AD permissions that still exist on the 
    vSphere host and its children.
.EXAMPLE
    Get-VMHost | Set-VMHostAuthentication -Join `
        -Domain vSphere.local `
        -User glnsize@vSphere.local
.EXAMPLE
    Get-VMHost | Set-VMHostAuthentication -Credential $cred
.EXAMPLE
    Get-VMHost | Set-VMHostAuthentication -Remove
#>
    [cmdletbinding(SupportsShouldProcess=$true, 
        DefaultParameterSetName='JoinUser')]
    param(
        [parameter(
            ParameterSetName='JoinUser'
        ,    ValueFromPipeline = $true
        ,   Mandatory = $true)]
        [parameter(
            ParameterSetName='JoinCred'
        ,    ValueFromPipeline = $true
        ,   Mandatory = $true)]
        [parameter(
            ParameterSetName='Remove'
        ,    ValueFromPipeline = $true
        ,   Mandatory = $true)]
      [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
        $VMHost
    ,   [parameter(
            ParameterSetName='JoinUser'
        ,   ValueFromPipeline = $true
        ,   Mandatory = $true)]
        [parameter(
            ParameterSetName='JoinCred'
        ,   ValueFromPipeline = $true
        ,   Mandatory = $true)]
        [string]
        $Domain
    ,
        [parameter(
            ParameterSetName='JoinUser'
        ,   ValueFromPipelinebyPropertyName = $true
        ,   Mandatory = $true)]
        [string]
        $User
    ,
        [parameter(
            ParameterSetName='JoinUser'
        ,   ValueFromPipelinebyPropertyName = $true
        ,   Mandatory = $true)]
        [string]
        $Password
    ,
        [parameter(
            ParameterSetName='JoinCred'
        ,   ValueFromPipelinebyPropertyName = $true
        ,   Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential
    ,
        [parameter(ParameterSetName='JoinCred')]
        [parameter(ParameterSetName='JoinUser')]
        [switch]
        $Join
    ,
        [parameter(ParameterSetName='Remove'
        ,   Mandatory = $true)]
        [switch]
        $Remove
     ,
        [parameter(ParameterSetName='Remove')]
        [switch]
        $RemovePermission
    )

    process
    {
        $confMgr = $VMHost.ExtensionData.ConfigManager
        $filter = New-Object VMware.Vim.PropertyFilterSpec `
            -Property @{
                ObjectSet = New-Object VMware.Vim.ObjectSpec `
                    -Property @{
                        Obj=$confMgr.AuthenticationManager
                    }
            PropSet = New-Object VMware.Vim.PropertySpec `
                -Property @{
                    Type = "HostAuthenticationManager"
                    All = $true
            }
        }
        $sc = $VMHost.ExtensionData.Client.ServiceContent
        $collector = Get-View $sc.PropertyCollector
        $content = $collector.RetrieveProperties($filter)
        $stores = $content | 
            Select-Object -First 1 -ExpandProperty PropSet | 
            Where-Object {$_.Name -eq "supportedStore"}
        $result = $stores.Val | 
            ? {$_.Type -eq "HostActiveDirectoryAuthentication"}
        $hostADAuth = [VMware.Vim.VIConvert]::ToVim41($result)

        Switch ($pscmdlet.parameterSetName)
        {
            'JoinUser'
            {
                $msg = "Joining $Domain"
                $action = {$VimSvc.JoinDomain_Task($hostADAuth,
                        $Domain,$User,$Password)}
            }
            'JoinCred'
            {
                $User,$Pass=$Credential.GetNetworkCredential()|
                    Foreach-Object {$_.UserName,$_.Password}
                $msg = "Joining $Domain"
                $action = {$VimSvc.JoinDomain_Task($hostADAuth,
                    $Domain,$User,$Pass)}
            }
            'Remove'
            {
                $msg="Removing from Domain"
                if ($RemovePermission) {$r = $True} 
                Else {$r = $false}
                $action = {$VimSvc.LeaveCurrentDomain_Task( `
                    $hostADAuth,$r)}
            }
        }
        if ($PSCMdlet.Shouldprocess($VMhost.Name,$msg))
        {
            $VimSvc = $VMHost.ExtensionData.Client.VimService
            $taskMoRef = &$action
            $VMHost.ExtensionData.WaitForTask(`
                [VMware.Vim.VIConvert]::ToVim($taskMoRef))
        }
    }
}