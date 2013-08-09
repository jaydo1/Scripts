Function Get-MotionDuration { 
    $events = Get-VIEvent -Start (Get-Date).AddDays(-1) 
    $relocates = $events | 
        where {$_.GetType().Name -eq "TaskEvent" -and $_.Info.DescriptionId -eq "VirtualMachine.migrate" -or $_.Info.DescriptionId -eq "VirtualMachine.relocate"} 
    foreach($task in $relocates){ 
        $tEvents = $events | where {$_.ChainId -eq $task.ChainId} | 
            Sort-Object -Property CreatedTime 
        if($tEvents.Count){ 
            New-Object PSObject -Property @{ 
                Name = $tEvents[0].Vm.Name 
                Type = &{if($tEvents[0].Host.Name -eq $tEvents[-1].Host.Name){"svMotion"}else{"vMotion"}} 
                StartTime = $tEvents[0].CreatedTime 
                EndTime = $tEvents[-1].CreatedTime 
                Duration = New-TimeSpan -Start $tEvents[0].CreatedTime -End $tEvents[-1].CreatedTime 
            } 
        } 
    } 
}