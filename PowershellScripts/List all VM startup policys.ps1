# To view all current start policy settings for each VM
 
Connect-VIServer MYVISERVER

Get-VM | Get-VMStartPolicy 