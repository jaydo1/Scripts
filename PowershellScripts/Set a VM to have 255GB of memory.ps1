# Alters an existing VM named PROD1 to change the current amount 
# of memory to 255GB: 

Connect-VIServer MYVISERVER
 
Get-VM PROD1 | Set-VM –MemoryMB (255GB / 1MB) 