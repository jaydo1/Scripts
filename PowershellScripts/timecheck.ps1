$allowedDifferenceSeconds = 20

get-view -ViewType HostSystem -Property Name, ConfigManager.DateTimeSystem | %{    
    #get host datetime system
    $dts = get-view $_.ConfigManager.DateTimeSystem
    
    #get host time
    $t = $dts.QueryDateTime()
    
    #calculate time difference in seconds
    $s = ( $t - [DateTime]::UtcNow).TotalSeconds
    
    #check if time difference is too much
    if([math]::abs($s) -gt $allowedDifferenceSeconds){
        #print host and time difference in seconds
        $row = "" | select HostName, Seconds
        $row.HostName = $_.Name
        $row.Seconds = $s
        $row
    }
    else{
        Write-Host "Time on" $_.Name "within allowed range"
    }
}

Out-File c:

