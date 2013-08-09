#will remove any file that hasn't been access in the last month

$date = (Get-Date).Adddays(-28) 
$files = Get-ChildItem "c:\Temp" | where{!$_.PsIsContainer}
foreach($file in $files){
	if ($file.lastAccessTime -lt $date) {
		Remove-Item -Path $file.fullname -WhatIf
		}
}