#Add-PSSnapin Quest.ActiveRoles.ADmanagement 
#Add-PSSnapin VMware.VimAutomation.core 
$pw = Read-Host "enter password" -AsSecureString 
Connect-QADService -Service 'win.f2network.com.au' -ConnectionAccount 'f2network\jsmith' -ConnectionPassword $pw
$computerlist = Get-QADGroupMember "patching test" 

$date = get-date 
Connect-VIServer 'apinfpvc011' 
foreach ($vm in [array]$computerlist)
{New-Snapshot -Vm $vm -Name "before Patch" `
	-Description "installation of patches + $date" -Memory }
