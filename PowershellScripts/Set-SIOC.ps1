Function Set-SIOC
{
  <#
  .SYNOPSIS
    Enables/disables Storage IO Control for a a datastore
  .DESCRIPTION
    The function enables or disables SIOC for a datastore.
  .NOTES
    Authors:    Luc Dekens
  .PARAMETER Datastore
    On or more datastores
  .PARAMETER Name
    Name of datststore to update
  .PARAMETER Enabled
    Should SIOC be enabled or disabled
  .PARAMETER Threshold
    Specify the threshold in milliseconds
  .EXAMPLE
    Set-Sioc -Datastore (Get-Datastore -Name DS1) -Enabled $true
  .EXAMPLE
    Get-Datastore | Set-SIOC -Enabled $true -Threshold 30
  .EXAMPLE
    Get-Datastore | Set-SIOC -Enabled $false
  .EXAMPLE
    Get-Datastore | Get-SIOC | 
    Where-Object {$_.SIOCSupported -And -Not $_.SIOCEnabled} |
    Set-SIOC -Enabled $true
  #>
  [cmdletBinding(SupportsShouldProcess=$true)]
  param(
    [parameter(
        valuefrompipeline = $true
    ,   valuefrompipelinebypropertyname=$true
    ,   HelpMessage = "Enter a datastore"
    )]
    [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.DatastoreImpl[]]
    $Datastore
  ,
    [parameter(
        valuefrompipelinebypropertyname=$true
    ,   HelpMessage = "Enter a datastore name"
    )]
    [string]
    $Name
  ,
    [parameter(
        valuefrompipeline = $true
    ,   valuefrompipelinebypropertyname=$true
    )]
    [Alias("SIOCEnabled")]
    [bool]
    $Enabled
  ,
    [parameter(
        valuefrompipeline = $true
    ,   valuefrompipelinebypropertyname=$true
    ,   HelpMessage='The latency in ms beyond which the storage array is considered congested'
    )]
    [Alias("SIOCThreshold")]
    [ValidateRange(10,100)]
    [int]
    $Threshold = 30
  )
  process
  {
    If ($name)
    {
        Try
        {
           $Datastore += Get-Datastore -Name $Name -EA Stop
        }
        Catch
        {
            Write-Warning "$Name not found!"
            continue;
        }
    }    
    If ($Enabled)
    {
      $Msg = "Enabling SIOC"
    }
    else
    {
      $Msg = "Disabling SIOC (WHY?!?)"
    }
    $msg = "{0} and setting the threshold t0 {1}" -f `
        $msg,$Threshold
    $si = Get-View ServiceInstance
    $VimService = $si.Client.VimService
    $spec = New-Object VMware.Vim.StorageIORMConfigSpec
    $spec.congestionThreshold = $Threshold
    $spec.enabled = $Enabled
    Foreach ($ds in $Datastore)
    {
      If ($PSCMdlet.Shouldprocess($ds.Name,$msg))
      {
      $taskMoRef = $VimService.ConfigureDatastoreIORM_Task(
        [VMWare.Vim.VIConvert]::ToVim41( `
            $si.Content.StorageResourceManager),
        [VMWare.Vim.VIConvert]::ToVim41( `
            $ds.Extensiondata.MoRef),
        [VMWare.Vim.VIConvert]::ToVim41($spec))
      $task = Get-View ( `
        [VMWare.Vim.VIConvert]::ToVim($taskMoRef))
      while ("running","queued" -contains $task.Info.State)
      {
        $task.UpdateViewData("Info.State")
      }
      }
    }
  }
}
