$Cluster = "Staging Cluster" 
$OldNetwork = "PBR NAS 10g" 
$NewNetwork = "PBR NAS" 

get-viserver apinfpvc011 
Get-Cluster $Cluster |Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -NetworkName $NewNetwork -Confirm:$false

