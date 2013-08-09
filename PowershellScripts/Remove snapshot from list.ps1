Get-VIServer 'apinfpvc011'
$date = get-date
$listVM = (Get-Content "C:\Temp\serverlist.txt")
foreach ($vm in [array]$listVM)
{Get-Snapshot -VM $vm -Name 'before patch' | Remove-Snapshot -Confirm: $false } 