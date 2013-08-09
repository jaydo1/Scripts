$domains = @(
    @{ Domain = "halr9000.com"; Credential = ( Get-Credential "@halr9000.com"  ) },
    @{ Domain = "domain2.com"; Credential = ( Get-Credential "@domain2.com" ) },
    @{ Domain = "domain3.com"; Credential = ( Get-Credential "@domain3.com" ) }
)
$domains | ForEach-Object {    
    New-OSCustomizationSpec -Name "Win-$( $_.Domain )" -OSType "Windows" `
        -Domain $_.Domain `
        -DomainCredentials $_.Credential `
        -FullName "Hal Rottenberg" -OrgName "PowerShellCommunity.org" `
        -Description "Windows spec for $( $_.Domain ) domain."
}