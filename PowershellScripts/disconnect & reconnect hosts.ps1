# Variables
$VCServer = "vcserver.yourdomain.local"
$password = "rootPassword"

#Connect to vCenter Server
$VC = Connect-VIServer $VCServer

get-vmhost | % {
    $view = get-view $_.id
    $arg = new-object VMware.Vim.HostConnectSpec
    $arg.userName = "root"
    $arg.password = $password
    $arg.force = $true

    $view.DisconnectHost()
    $view.ReconnectHost($arg)
    }

Disconnect-VIServer -Confirm:$false