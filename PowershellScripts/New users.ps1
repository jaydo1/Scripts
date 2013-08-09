$cred = Get-Credential
Get-VIServer apinfsvh051.mgt.f2.com.au -User root -Credential $cred 
$u = New-VMHostAccount -Id Ldixon -Password Solace82 -Description "Liam Dixon" -GrantShellAccess:$true -AssignGroups root,wheel,users

 