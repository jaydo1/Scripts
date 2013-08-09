$objUser = New-Object System.Security.Principal.NTAccount("jamie.smith")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value