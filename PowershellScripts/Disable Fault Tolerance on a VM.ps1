# Disables Fault Tolerance on a VM called PROD1. 

Connect-VIServer MYVISERVER

Get-VM PROD1 | Select –First 1 | Get-View | ForEach-Object { $_.TurnOffFaultToleranceForVM() }