# Enables Fault Tolerance on a VM called PROD1, this 
# example chooses the host to place the FT VM. 
 
Connect-VIServer MYVISERVER
Get-VM PROD1 | Get-View | ForEach-Object {$_.CreateSecondaryVM($null) } 