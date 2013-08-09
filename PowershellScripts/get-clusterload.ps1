function Get-ClusterLoad {
<#
.SYNOPSIS
  Get load average by cluster
.DESCRIPTION
  The function will display average load by 
  cluster with graph form.
.NOTES  
  Author:  www.vmdude.fr
.PARAMETER ClusterName
  The cluster name or names separated by coma
.PARAMETER Quickstat
  Switch, when true the method to get stats is based
  on quickstats through summary child properties.
  If not, the method will use PerfManager instance
  with QueryPerf method in order to get non computed stats.
  The default for this switch is $true.
.EXAMPLE
  PS> Get-ClusterLoad
  Get a graphical list for all cluster load
.EXAMPLE
  PS> Get-ClusterLoad -ClusterName vCluster01,vCluster02
  Get a graphical list for cluster load of vCluster01 and 02
.EXAMPLE
  PS> Get-ClusterLoad -Quickstat:$false
  Get a graphical list for all cluster load using quickstats infos
#>

	param(
		[parameter(Mandatory = $false)]
		[string]$ClusterName="",
		[parameter(Mandatory = $false)]
		[switch]$Quickstat = $true
	)
	
	begin{
		function Show-PercentageGraph([int]$percent, [int]$maxSize=20) {
			if ($percent -gt 100) { $percent = 100 }
			$warningThreshold = 60 # percent
			$alertThreshold = 80 # percent
			[string]$g = [char]9632 #this is the graph character, use [char]9608 for full square character
			if ($percent -lt 10) { write-host -nonewline "0$percent [ " } else { write-host -nonewline "$percent [ " }
			for ($i=1; $i -le ($barValue = ([math]::floor($percent * $maxSize / 100)));$i++) {
				if ($i -le ($warningThreshold * $maxSize / 100)) { write-host -nonewline -foregroundcolor darkgreen $g }
				elseif ($i -le ($alertThreshold * $maxSize / 100)) { write-host -nonewline -foregroundcolor yellow $g }
				else { write-host -nonewline -foregroundcolor red $g }
			}
			for ($i=1; $i -le ($traitValue = $maxSize - $barValue);$i++) { write-host -nonewline "-" }
			write-host -nonewline " ]"
		}
	}

	process{
		if ($ClusterName) {
			$clusterView = Get-View -ViewType ClusterComputeResource -Filter @{"name"=$ClusterName.Replace(",","|")} -Property resourcePool,name,host
		} else {
			$clusterView = Get-View -ViewType ClusterComputeResource -Property resourcePool,name,host
		}
		if ($Quickstat) {
			# using QuickStat for getting "realtime"-ish stats
			foreach ($cluster in $clusterView | sort name) {
				$rootResourcePool = get-view $cluster.resourcePool -Property summary
				if ($rootResourcePool.summary.runtime.cpu.maxUsage -ne 0 -And $rootResourcePool.summary.runtime.memory.maxUsage -ne 0) {
					if ($cluster.name.length -gt 20) { write-host -nonewline $cluster.name.substring(0, $cluster.name.length -5) "... CPU:" } else { write-host -nonewline $cluster.name (" "*(20-$cluster.name.length)) "CPU:"	}
					Show-PercentageGraph([math]::floor(($rootResourcePool.summary.runtime.cpu.overallUsage*100)/($rootResourcePool.summary.runtime.cpu.maxUsage)))
					write-host -nonewline `t"MEM:"
					Show-PercentageGraph([math]::floor(($rootResourcePool.summary.runtime.memory.overallUsage*100)/($rootResourcePool.summary.runtime.memory.maxUsage)))
					write-host ""
				}
			}
		} else { 
			# using PerfManager instance in order to bypass Get-Stat cmdlet for speed
			# but this method is quite low to get stats
			$objPerfManager = Get-View (Get-View ServiceInstance -Property content).content.PerfManager
			$avgConsumedMemCounter = ($objPerfManager.PerfCounter | ?{ $_.groupinfo.key -match "mem" } | ?{ $_.nameinfo.key -match "usage$" } | ?{ $_.RollupType -match "average" -And $_.Level -eq 1}).key
			$avgUsageCpuCounter = ($objPerfManager.PerfCounter | ?{ $_.groupinfo.key -match "cpu" } | ?{ $_.nameinfo.key -match "usage$" } | ?{ $_.RollupType -match "average" }).key
			foreach ($cluster in $clusterView | sort name) {
				if ($cluster.name.length -gt 20) { write-host -nonewline $cluster.name.substring(0, $cluster.name.length -5) "... CPU:" } else { write-host -nonewline $cluster.name (" "*(20-$cluster.name.length)) "CPU:"	}
				Show-PercentageGraph([math]::floor((($objPerfManager.QueryPerf((New-Object VMware.Vim.PerfQuerySpec -property @{entity = $cluster.moref;format = "normal";IntervalId = "300";StartTime=((Get-Date).AddDays(-1));EndTime=(Get-Date);MetricId = (New-Object VMware.Vim.PerfMetricId -property @{instance = "";counterId = $avgUsageCpuCounter})})) |%{$_.value}|%{$_.value}|measure -Average).average/100)))
				write-host -nonewline `t"MEM:"
				Show-PercentageGraph([math]::floor((($objPerfManager.QueryPerf((New-Object VMware.Vim.PerfQuerySpec -property @{entity = $cluster.moref;format = "normal";IntervalId = "300";StartTime=((Get-Date).AddDays(-1));EndTime=(Get-Date);MetricId = (New-Object VMware.Vim.PerfMetricId -property @{instance = "";counterId = $avgConsumedMemCounter})})) |%{$_.value}|%{$_.value}|measure -Average).average/100)))
				write-host ""
			}
		}
	}
}