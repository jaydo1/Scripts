function Get-VMHostAuthentication
{
<#
.SYNOPSIS
    The function retrieves the authentication services from a
	vSphere host.
.DESCRIPTION
    This function retrieves the configured authentication 
	services from a vSphere host.
.NOTES
    Authors: Luc Dekens, Glenn Sizemore
.PARAMETER VMHost
    Specify the vSphere host
.EXAMPLE
    Get-VMHost | Get-VMHostAuthentication
#>
    param(
      [parameter(
          ValueFromPipeline = $true
      ,   Mandatory = $true)]
      [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
      $VMHost
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
            Select -First 1 -ExpandProperty PropSet | 
            Where-Object {$_.Name -eq "info"}
        foreach ($authConfig in $stores.Val.AuthConfig|
            Where-Object {$_.Enabled})
        {
            switch($authConfig.GetType().Name)
            {
                'HostLocalAuthenticationInfo'
                {
                    New-Object PSObject -Property @{
                        Name = $VMHost.Name
                        Enabled = $authConfig.Enabled
                        Type = 'Local authentication'
                        Domain = $null
                        Membership = $Null
                        Trust = $null
                    }
                }
                'HostActiveDirectoryInfo'{
                    New-Object PSObject -Property @{
                        Name = $VMHost.Name
                        Enabled = $authConfig.Enabled
                        Type = 'Active Directory'
                        Domain = $authConfig.JoinedDomain
                        Membership = `
                            $authConfig.DomainMembershipStatus
                        Trust = $authConfig.TrustedDomain
                    }
                }
            }
        }
    }
}
