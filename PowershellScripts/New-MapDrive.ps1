function New-MapDrive {
    param($Path) 
    $present = @(Get-WmiObject Win32_Networkconnection |
       Select-Object -ExpandProperty RemoteName)
    if ($present -contains $Path) {
        "Network connection to $Path is already present"
    } else {
        net use * $Path
    }
}
