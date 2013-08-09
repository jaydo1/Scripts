$Title = "Invalid or inaccessible VM"
$Header =  "VM invalid or inaccessible : $(($BlindedVM | Measure-Object).count)"
$Comments = "The following VMs are marked as inaccessible or invalid"
$Display = "Table"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$FullVM | Where {$_.Runtime.ConnectionState -eq "invalid" -or $_.Runtime.ConnectionState -eq "inaccessible"} | sort name |select name