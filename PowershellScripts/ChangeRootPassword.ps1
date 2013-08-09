#
# This script changes the root password on all ESX hosts in the esxservers.txt textfile
#

# Add VI-toolkit #
Add-PSsnapin VMware.VimAutomation.Core
Initialize-VIToolkitEnvironment.ps1

# Get old root credential
$oldrootPassword = Read-Host "Enter old root password" -AsSecureString
$oldrootCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist "root",$oldrootPassword

# Get new root credential
$newrootPassword = Read-Host "Enter new root password" -AsSecureString
$newrootCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist "root",$newrootPassword
$newrootPassword2 = Read-Host "Retype new root password" -AsSecureString
$newrootCredential2 = new-object -typename System.Management.Automation.PSCredential -argumentlist "root",$newrootPassword2

# Compare passwords
If ($newrootCredential.GetNetworkCredential().Password -ceq $newrootCredential2.GetNetworkCredential().Password) {

	# Create new root account object
	$rootaccount = New-Object VMware.Vim.HostPosixAccountSpec
	$rootaccount.id = "root"
	$rootaccount.password = $newrootCredential.GetNetworkCredential().Password 
	$rootaccount.shellAccess = "/bin/bash"

	# Get list of Host servers from textfile to change root password on
	Get-Content esxservers.txt | %{
		Connect-VIServer $_ -User root -Password $oldrootCredential.GetNetworkCredential().Password -ErrorAction SilentlyContinue -ErrorVariable ConnectError | Out-Null
		If ($ConnectError -ne $Null) {
			Write-Host "ERROR: Failed to connect to ESX server:" $_
		}
		Else {
			$si = Get-View ServiceInstance
			$acctMgr = Get-View -Id $si.content.accountManager
			$acctMgr.UpdateUser($rootaccount)
			Write-Host "Root password successfully changed on" $_
		    Disconnect-VIServer -Confirm:$False | Out-Null
		}
	}
}
Else {
Write-Host "ERROR: New root passwords do not match. Exiting..."
}