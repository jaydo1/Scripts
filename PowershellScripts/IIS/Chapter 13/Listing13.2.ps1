## PowerShell in Practice
## by Richard Siddaway
## Listing 13.2
## Create a site with .NET
#################################
[system.reflection.assembly]::loadfrom("c:\windows\system32\inetsrv\microsoft.web.administration.dll")

$server = New-Object microsoft.web.administration.servermanager 

$server.Sites.Add("TestNet", "http", "*:80:testnet.manticore.org", "c:\inetpub\testnet") 

$server.CommitChanges()                                                