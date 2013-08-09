Get-VIServer 'apinfpvc011'
$date = get-date
$listVM = (Get-Content "C:\Temp\serverlist.txt")
foreach ($vm in [array]$listVM)
{New-Snapshot -Vm $vm -Name "before Patch" `
	-Description "installation of patches + $date" -Memory }
