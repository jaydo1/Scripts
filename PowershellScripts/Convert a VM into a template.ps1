# Convert an existing virtual machine called PROD1 to a template

Connect-VIServer MYVISERVER
 
$ToBeTemplate = Get-VM "PROD1" | Get-View 
$ToBeTemplate.MarkAsTemplate()