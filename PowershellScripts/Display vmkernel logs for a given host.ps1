# The below example shows how to retrieve the vmkernel log from 
# "MyESXHost.MyDomain.com"

Connect-VIServer MYVISERVER
 
(Get-Log –VMHost (Get-VMHost "MyESXHost.MyDomain.com") vmkernel).Entries 