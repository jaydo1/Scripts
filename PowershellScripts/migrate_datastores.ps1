# Migrate all virtual machines based on source and target datastores identified
# in an input CSV file. The input CSV file must contain rows with at least the
# following columns defined:
# CLUSTER,SRC_DS,TGT_DS

$csv_schedule = 'C:\Path\To\ds_migrate_schedule.csv'
$logfile      = 'C:\Path\To\migrate.log'
$vc_server    = 'hpvvcs001.detnsw.win'
$vc_user      = 'srvVMAdmin'
$vc_password  = 'N]pk65T5=020235'

Function NotifyGeneral {
	Param(
		[string]$msg,
		[string]$nonewline
	)

	if ($nonewline) {
		Write-Host -NoNewline $msg
	}
	else {
		Write-Host $msg
	}
	
	LogWrite $msg	
}

Function NotifySuccess {
	Param([string]$msg)
	
	Write-Host -ForegroundColor "green" $msg
	LogWrite $msg
}

Function NotifyFailure {
	Param([string]$msg)
	
	Write-Host -ForegroundColor "red" $msg
	LogWrite $msg
}

Function LogWrite {
	Param([string]$msg)

	$ts = Get-Date -Format s

	$msg = $ts.ToString() + " " + $msg
	
	Add-Content $logfile -Value $msg
}

Function Migrate {
	Import-CSV $csv_schedule | ForEach-Object {
    	$cluster = $_.CLUSTER
		$src_ds  = $_.SRC_DS
		$tgt_ds  = $_.TGT_DS
		$ds_count = 0
	
		NotifyGeneral "Locating target datastore '$tgt_ds' " '1'
		$tgt_ds_obj = Get-Cluster -Name $cluster | Get-VMHost | Get-Datastore -Name $tgt_ds -ErrorAction SilentlyContinue -ErrorVariable e

		if ($e.Count -ne 0 ) {
			NotifyFailure 'not found'
		}
		else {
			NotifySuccess 'found'
			$ds_count++
		}
		$e = $null

		NotifyGeneral "Fetching VM's on source datastore '$src_ds' " '1'
		$vms = Get-Cluster -Name $cluster | Get-VMHost | Get-Datastore -Name $src_ds -ErrorAction SilentlyContinue -ErrorVariable e | Get-VM
		if ($e.Count -ne 0 ) {
			NotifyFailure 'not found'
		}
		else {
			$vm_count = 0
			if ($vms) {
				$vm_count = @($vms).Count
			}
			NotifySuccess "found $vm_count VM's"
			$ds_count++
		}
		$e = $null

	    if ($ds_count -eq 2 -and $vm_count -gt 0) {
			NotifyGeneral "Evacuating $src_ds"

			FOREACH($VM in $vms) {
				# TODO: check disk space requirements first
				NotifyGeneral "  Migrating $vm to $tgt_ds " '1'
				$e = @( ) # fake success instead of performing the move-vm
				#move-VM -ErrorVariable e -VM $vm -Datastore $tgt_ds_obj
				if ($e.Count -ne 0 ) {
					NotifyFailure 'failed'
					LogWrite $e
				}
				else {
					NotifySuccess 'succeeded'
				}
				$e = $null
			}
		}
	}
}

# Main script
Connect-VIServer -Server $vc_server -User $vc_user -Password $vc_password

# Run the migration up to three times in case some VM's fail due to intermittent load 
for ($i = 1; $i -le 3; $i++) {
	NotifyGeneral "Staring run number $i"
	Migrate
	NotifyGeneral "Run number $i completed"
}

NotifyGeneral "Datastore evacuation complete"