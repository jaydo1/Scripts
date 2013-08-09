function Get-VMLastPoweredOffDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)
  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOffDate,UserName
	$Report.Name = $_.Name
    $Event = Get-VIEvent -Entity $vm | Sort-Object -Property CreatedTime -Descending | `
      Where-Object { $_.Gettype().Name -eq "VmPoweredOffEvent" } | `
	  Select-Object -First 1
	$Report.LastPoweredOffDate = $Event.CreatedTime
	$Report.UserName = $Event.UserName
	$Report
  }
}

function Get-VMLastPoweredOnDate {
  param([Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl] $vm)

  process {
    $Report = "" | Select-Object -Property Name,LastPoweredOnDate,UserName
	$Report.Name = $_.Name
	$Event = Get-VIEvent -Entity $vm | Sort-Object -Property CreatedTime -Descending |`
      Where-Object { $_.Gettype().Name -eq "VmPoweredOnEvent" } | `
	  Select-Object -First 1
	$Report.LastPoweredOnDate = $Event.CreatedTime
	$Report.UserName = $Event.UserName
	$Report
  }
}

New-VIProperty -Name LastPoweredOffDate -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOffDate -vm $Args[0]).LastPoweredOffDate}
New-VIProperty -Name LastPoweredOffUserName -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOffDate -vm $Args[0]).UserName}
New-VIProperty -Name LastPoweredOnDate -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOnDate -vm $Args[0]).LastPoweredOnDate}
New-VIProperty -Name LastPoweredOnUserName -ObjectType VirtualMachine -Value {(Get-VMLastPoweredOnDate -vm $Args[0]).UserName}

Get-VM | Select-Object -property Name,LastPoweredOnDate,LastPoweredOnUserName,LastPoweredOffDate,LastPoweredOffUserName
