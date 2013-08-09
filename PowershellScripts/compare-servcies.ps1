#compare services 

$pc1 = Get-Service -ComputerName server1
$pc2 = Get-Service -ComputerName server2 
Compare-Object $pc1 $pc2 -Property Name, Status -PassThru |
    Sort-Object -Property Name  |
    Select-Object -Property MachineName, Name, Status
