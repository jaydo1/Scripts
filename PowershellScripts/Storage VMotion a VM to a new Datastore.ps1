# Storage VMotion the VM called MyVM to a new datastore called “MyDatastore” 
 
Connect-VIServer MYVISERVER

Get-VM "MyVM" |Move-VM -datastore (Get-datastore "MyDatastore") 