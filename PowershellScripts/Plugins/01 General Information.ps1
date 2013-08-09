$Title = "General Information"
$Header =  "General Information"
$Comments = "General details on the infrastructure"
$Display = "List"
$Author = "Alan Renouf"
$Version = 1.0

# Start of Settings 
# End of Settings 

$Info = New-Object -TypeName PSObject -Property @{
	"Number of Hosts:" = (@($VMH).Count)
	"Number of VMs:" = (@($VM).Count)
	"Number of Templates:" = (@($VMTmpl).Count)
	"Number of Clusters:" = (@($Clusters).Count)
	"Number of Datastores:" = (@($Datastores).Count)
	"Active VMs:" = (@($FullVM | Where { $_.Runtime.PowerState -eq "poweredOn" }).Count) 
	"In-active VMs:" = (@($FullVM | Where { $_.Runtime.PowerState -eq "poweredOff" }).Count)
}
$Info