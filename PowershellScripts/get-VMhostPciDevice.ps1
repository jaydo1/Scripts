function Get-VMHostPciDevice {
<#
.SYNOPSIS
  Returns the ESX(i) host's PCI Devices
.DESCRIPTION
  This function returns the ESX(i) host's PCI devices en their associated ESX devices
.NOTES
  Author:  Arnim van Lieshout
.PARAMETER VMHost
  The ESX(i) host entity for which the PCI devices should be returned
.EXAMPLE
  PS> Get-VMHostPciDevice -VMHost (Get-VMHost "esx01")
.EXAMPLE
  PS> Get-VMHost "esx01" | Get-VMHostPciDevice
#>

	Param (
	[parameter(valuefrompipeline = $true, mandatory = $true,
	HelpMessage = "Enter an ESX(i) host entity")]
	[VMware.VimAutomation.Types.VIObject[]]$VMHost)

	Begin {
# Create PCI class array
		$PciClass = @("Unclassified device","Mass storage controller","Network controller","Display controller","Multimedia controller","Memory controller","Bridge","Communications controller","Generic system peripheral","Input device controller","Docking station","Processor","Serial bus controller","Wireless controller","Intelligent controller","Satellite communications controller"," Encryption controller","Signal processing controller")
	}

	Process {
		if($VMHost) {
			$VMHostView = $VMHost | Get-View
		}
		else {
			$VMHostView = $_ | Get-View
		}

# Get the PCI Devices
		$VMHostView | % {
			$PciDevices = @()
			foreach ($dev in $_.Hardware.PciDevice) {
				$objDevice = "" | Select Pci, ClassName, VendorName, DeviceName, EsxDeviceName
				$objDevice.Pci = $dev.Id
				$objDevice.ClassName = $PciClass[[int]($dev.ClassId/256)]
				$objDevice.VendorName = $dev.VendorName
				if ($dev.DeviceName -notmatch "Unknown") {
					$objDevice.DeviceName = $dev.DeviceName
				}
				$PciDevices += $objDevice
			}

# Find associated ESX storage devices
			foreach ($hba in $_.Config.StorageDevice.HostBusAdapter) {
				$PciDevices | ? {$_.Pci -match $hba.Pci} | % {$_.EsxDeviceName = "["+$hba.device+"]"}
			}

# Find associated ESX network devices
			foreach ($nic in $_.Config.Network.Pnic) {
				$PciDevices | ? {$_.Pci -match $nic.Pci} | % {$_.EsxDeviceName = "["+$nic.device+"]"}
			}
		}
	}

	End {
    	$PciDevices| Sort-Object -Property Pci
	}
}