$dataCenterName = Read-Host "enter Datacenter name"  
$Clustername = Read-Host "enter Cluster name" 
$hours = 24 # Number of hours back
$start = (Get-Date).AddHours(-$hours)
$tasknumber = 999 # Windowsize for task collector
$eventnumber = 100 # Windowsize for event collector
$tgtTaskDescriptions = "VirtualMachine.migrate","Drm.ExecuteVMotionLRO"
$migrations = @()
$report = @()

# Get the guest for which we want the report
$vmHash = @{}
Get-Datacenter -Name "$datacentername" | get-cluster -Name "$clustername" | Get-VMHost | Get-VM | %{
	$vmHash[$_.Name] = $_.Host
}

# Retrieve the vMotion tasks and the corresponding events
$taskMgr = Get-View TaskManager
$eventMgr = Get-View eventManager

$tFilter = New-Object VMware.Vim.TaskFilterSpec
$tFilter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
$tFilter.Time.beginTime = $start
$tFilter.Time.timeType = "startedTime"

$tCollector = Get-View ($taskMgr.CreateCollectorForTasks($tFilter))

$dummy = $tCollector.RewindCollector
$tasks = $tCollector.ReadNextTasks($tasknumber)

while($tasks){
	$tasks | where {$tgtTaskDescriptions -contains $_.DescriptionId} | % {
		$task = $_
		$eFilter = New-Object VMware.Vim.EventFilterSpec
		$eFilter.eventChainId = $task.EventChainId

		$eCollector = Get-View ($eventMgr.CreateCollectorForEvents($eFilter))
		$events = $eCollector.ReadNextEvents($eventnumber)
		while($events){
			$events | % {
				$event = $_
				switch($event.GetType().Name){
					"VmBeingHotMigratedEvent" {
						$migrations += New-Object PSObject -Property @{
							VMname = $task.EntityName
							Source = $event.Host.Name
							Destination = $event.DestHost.Name
							Start = $task.StartTime
							Finish = $task.CompleteTime
							Result = $task.State
							User = $task.Reason.UserName
							DRS = &{if($task.DescriptionId -like "Drm.*"){$true}else{$false}}
						}
					}
					Default {}
				}
			}
			$events = $eCollector.ReadNextEvents($eventnumber)
		}
		$ecollection = $eCollector.ReadNextEvents($eventnumber)
# By default 32 event collectors are allowed. Destroy this event collector.
		$eCollector.DestroyCollector()
	}
	$tasks = $tCollector.ReadNextTasks($tasknumber)
}

# By default 32 task collectors are allowed. Destroy this task collector.
$tCollector.DestroyCollector()

# Handle the guests that have been vMotioned
$grouped = $migrations | Group-Object -Property VMname
$grouped | Sort-Object -Property Count -Descending | where{$vmHash.ContainsKey($_.Name)} | %{
	$i = 1
	$row = New-Object PSObject
	Add-Member -InputObject $row -Name VM -Value $_.Name -MemberType NoteProperty
	$_.Group | Sort-Object -Property Finish | %{
# The original location of the guest
		if($i -eq 1){
			Add-Member -InputObject $row -Name ("Time" + $i) -Value $start -MemberType NoteProperty
			Add-Member -InputObject $row -Name ("Host" + $i) -Value $_.Source -MemberType NoteProperty
			$i++
		}
# All the vMotion destinations
		Add-Member -InputObject $row -Name ("Time" + $i) -Value $_.Finish -MemberType NoteProperty
		Add-Member -InputObject $row -Name ("Host" + $i) -Value $_.Destination -MemberType NoteProperty
		Add-Member -InputObject $row -Name ("DRS" + $i) -Value $_.DRS -MemberType NoteProperty
		Add-Member -InputObject $row -Name ("User" + $i) -Value $_.User -MemberType NoteProperty
		$i++
	}
	$report += $row
	$vmHash.Remove($_.Name)
}

# Add remaining guests to report
$vmHash.GetEnumerator() | %{
	$row = New-Object PSObject
	Add-Member -InputObject $row -Name VM -Value $_.Name -MemberType NoteProperty
	Add-Member -InputObject $row -Name Time1 -Value $start -MemberType NoteProperty
	Add-Member -InputObject $row -Name Host1 -Value $_.Value -MemberType NoteProperty
	Add-Member -InputObject $row -Name DRS1 -Value $false -MemberType NoteProperty
	$report += $row
}

$report | Export-Csv "C:\vMotion-history.csv" -NoTypeInformation -UseCulture