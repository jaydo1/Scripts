Import-Csv C:\dvportgroup.csv -UseCulture | %{
     $dvSw = Get-VDSwitch -Name $_.dvSw
     New-VDPortgroup -VDSwitch $dvSw -Name $_.dvPg -VlanId $_.VlanId -Confirm:$false
}