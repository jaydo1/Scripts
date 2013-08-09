$days = 1
$tasknumber = 999
$eventnumber = 100

$serviceInstance = get-view ServiceInstance
$taskMgr = Get-View TaskManager
$eventMgr = Get-View eventManager

$report = @()

$filter = New-Object VMware.Vim.TaskFilterSpec
$filter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
$filter.Time.beginTime = (Get-Date).AddDays(-$days)
$filter.Time.timeType = "startedTime"

$collectionImpl = Get-View ($taskMgr.CreateCollectorForTasks($filter))

$dummy = $collectionImpl.RewindCollector
$collection = $collectionImpl.ReadNextTasks($tasknumber)

$collection | Where-Object {$_.DescriptionId -like "Drm*" -or `
                            $_.DescriptionId -eq "VirtualMachine.migrate"} |`
			  Sort-Object StartTime | % {
	$efilter = New-Object VMware.Vim.EventFilterSpec
	$efilter.eventChainId = $_.EventChainId

	$ecollectionImpl = Get-View ($eventMgr.CreateCollectorForEvents($efilter))
	$ecollection = $ecollectionImpl.ReadNextEvents($eventnumber)
	while($ecollection -ne $null){
		foreach($event in $ecollection){
			switch($event.GetType()){
				{$_.Name -eq "DrsVmMigratedEvent" -or $_.Name -eq "VmMigratedEvent"} {
					$from = $event.SourceHost.Name
				}
				"VMware.Vim.VmBeingHotMigratedEvent"{
					$to = $event.DestHost.Name
				}
				Default {}
			}
		}
		$ecollection = $ecollectionImpl.ReadNextEvents($eventnumber)
	}
	$row = "" | Select StartTime, Entity, State, Description, From, To
	$row.StartTime = $_.StartTime
	$row.Entity = $_.EntityName
	$row.State = $_.State
	$row.Description = $_.DescriptionId
	$row.From = $from
	$row.To = $to
	$report += $row
	$ecollectionImpl.DestroyCollector()
}

$report
