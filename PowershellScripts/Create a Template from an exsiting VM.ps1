# Creates a new template called Windows2003SP1-GOLD from an 
# existing VM called TemplateVM and places it in the Production datacenter
 
Connect-VIServer MYVISERVER

New-Template -VM (Get-VM "TemplateVM") -Name "Windows2003SP1-GOLD" -Location (Get-Datacenter "Production") 