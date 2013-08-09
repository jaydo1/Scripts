# Variables
$pgs = @("test1","test","portgroup")
$newfolder = ""
$vcenter = "" 
$array = @()
$outputpath = c:\csv\test.csv



# Connect
Connect-VIServer $vcenter



# Do work
foreach ($pg in $pgs) {
    $netview = Get-View -ViewType network -Property Name,VM -Filter @{"Name"=$pg}
    $vmview = $netview | % {Get-view $_.vm}
    foreach ($vm in $vmview) {
        $info = "" | select Name, CurrentFolder, NewFolder
        $info.Name = $vm.name
        $location = get-view $vm.parent
        $info.CurrentFolder = $location.name
        if ($info.currentfolder -ne $newfolder) {
            Move-VM $vm.name -Destination $newfolder
        }
        $location = get-view $vm.parent
        $info.NewFolder = $location.name
        $array += $info 
    }
}



# Export
$array | Export-Csv $outputpath