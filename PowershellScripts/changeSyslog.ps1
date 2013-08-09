
$changedValue = New-Object VMware.Vim.OptionValue[] (1)
$changedValue[0] = New-Object VMware.Vim.OptionValue
 $changedValue[0].key = "Syslog.global.logHost"
 $changedValue[0].value = "tcp:/192.168.78.77:514"

Get-View -ViewType HostSystem -Searchroot (Get-Cluster "infra_serv_U").Id | %{
  $optMgr = Get-View $_.ConfigManager.AdvancedOption
  $optMgr.UpdateOptions($changedValue)
}