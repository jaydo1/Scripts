function Get-VMHostAudit
{
param([parameter(mandatory=$true)][string]$vCenter,
        [parameter(mandatory=$true)][string]$Username,
        [parameter(mandatory=$true)][string]$Password,
        [parameter(mandatory=$true)][ValidateSet("List","Table")]$Format)

Connect-VIServer -Server $vCenter -User $Username -Password $Password
$ServiceInstance = Get-View ServiceInstance
$LicenseManager = Get-View $ServiceInstance.Content.LicenseManager
$LicenseManagerAssign = Get-View $LicenseManager.LicenseAssignmentManager
$VMhosts=Get-VMHost
$VMhostsTotal=@()
Foreach($VMhost in $VMHosts)
    {
    $VMHostView=Get-VMHost -Name $VMHost.name | Get-View
    $VMhostID=$VMHostView.Config.Host.Value
    $VMHostLM=$LicenseManagerAssign.QueryAssignedLicenses($VMhostID) 
    $VMhostsTotal+=$VMHostView | Select Name,
        @{n='Product';e={$_.Config.Product.Name}},
        @{n='Version';e={$_.Config.Product.Version}},
        @{n='Sockets';e={$_.Hardware.CpuInfo.NumCpuPackages}},    
        @{n='CPUCores';e={$_.Hardware.CpuInfo.NumCpuCores}},
        @{n='LicenseVersion';e={$VMHostLM.AssignedLicense.Name | Select -Unique}},
        @{n='LicenseKey';e={$VMHostLM.AssignedLicense.LicenseKey | Select -Unique}}
    }
If ($Format -eq "List"){$VMhostsTotal | Fl}
If ($Format -eq "Table"){$VMhostsTotal | Ft -AutoSize}
Disconnect-VIServer -Server $vCenter -Confirm:$False -Force
} # End Function