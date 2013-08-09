# The following shows how to view the type of logs which can be 
# viewed by PowerCLI: 

Connect-VIServer MYVISERVER
 
Get-LogType -VMHost (Get-VMHost "MyESXHost.MyDomain.com") 
 
