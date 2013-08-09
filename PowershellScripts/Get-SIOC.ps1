function Get-Sioc
{
  <#
  .SYNOPSIS
    Get the Storage IO Control settings for a host or a 
	datastore
  .DESCRIPTION
    When called against a VMHost, the cmdlet will return the 
	SIOC settings on the host
    When called against a Datastore, the cmdlet will return the 
	SIOC settings for all hosts on which the datastore is 
	accessible
  .NOTES
    Authors:    Luc Dekens, Glenn Sizemore
  .PARAMETER VMHost
    On or more hosts
  .PARAMETER Datastore
    On or more datastores
  .EXAMPLE
    PS> Get-Sioc -VMHost (Get-VMHost)
  .EXAMPLE
    PS> Get-VMHost -Name "esx41" | Get-Sioc
  .EXAMPLE
    PS> Get-Sioc -Datastore (Get-Datastore)
  .EXAMPLE
    PS> Get-Datastore -Name "DS1" | Get-Sioc
  #>
  param(
    [parameter(
        ParameterSetName = "VMHost"
    ,   valuefrompipeline = $true
    ,   position = 0
    ,   HelpMessage = "Enter a host"
    )]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]
    $VMHost
  , [parameter(
        ParameterSetName = "Datastore"
    ,   valuefrompipeline = $true
    ,   position = 0
    ,   HelpMessage = "Enter a datastore"
    )]
    [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.DatastoreImpl[]]
    $Datastore
  )
  process
  {
    switch($PsCmdlet.ParameterSetName)
    {
      "VMHost"
      {
        $si = Get-View 'ServiceInstance'
        $VimService = $si.Client.VimService
        Foreach ($vmh in $VMHost)
        {
          $result =$VimService.QueryIORMConfigOption(`
            [VMWare.Vim.VIConvert]::ToVim50(`
              $si.Content.StorageResourceManager),
            [VMWare.Vim.VIConvert]::ToVim50(`
              $vmh.Extensiondata.MoRef))
          $enabled = $result.enabledOption
          $Threshold = $result.congestionThresholdOption
          New-Object PSObject -Property @{
            'Name' = $vmh.Name
            'SIOCSupported' = $enabled.supported
            'SIOCStateDefault' = $enabled.defaultValue
            'SIOCThresholdMinimum' = $Threshold.min
            'SIOCThresholdMaximum' = $Threshold.max
            'SIOCThresholdDefault' = $Threshold.defaultValue
          }
        }
      }
      "Datastore"
      {
        Foreach ($ds in $DataStore)
        {
          $iorm = $ds.Extensiondata.iormConfiguration
          $cap = $ds.ExtensionData.Capability
          New-Object PSObject -Property @{
            'Name' = $Ds.Name
            'SIOCEnabled' = $iorm.enabled
            'SIOCThreshold' = `
                $iorm.congestionThreshold
            'SIOCSupported' = $cap.StorageIORMSupported
          } 
        }
      }
	}
  }
}