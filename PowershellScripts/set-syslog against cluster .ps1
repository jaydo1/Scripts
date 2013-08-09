
$cluster = Read-host "enter cluster name"


get-cluster $cluster|get-vmhost| Set-VMHostAdvancedConfiguration -NameValue @{'Config.HostAgent.log.level'='info';'Vpx.Vpxa.config.log.level'='info';'Syslog.global.logHost'='tcp://192.168.14.37:514'}