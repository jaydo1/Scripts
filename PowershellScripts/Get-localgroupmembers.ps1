function Get-localgroupmembers ([string]$localcomputername, [string]$localgroupname) { 
$groupobj =[ADSI]"WinNT://$localcomputername/$localgroupname" 
$localmembers = @($groupobj.psbase.Invoke("Members")) 
$localmembers | foreach {$_.GetType().InvokeMember("AdsPath","GetProperty",$null,$_,$null)} 