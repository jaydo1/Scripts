foreach ($vmhost in Get-VMHost ) {
    $vnet = $vmhost | Get-VMHostNetwork
    $output = $vnet | select Name, HostName, DomainName, ConsoleIP, ConsoleNetmask, 
        ConsoleGateway, DnsAddress, ConsoleMAC
    $output.Name = $vmhost.Name
    $output.ConsoleIP = $vnet.ConsoleNic[0].IP
    $output.ConsoleNetmask = $vnet.ConsoleNic[0].SubnetMask
    $output.ConsoleGateway = $vnet.ConsoleGateway
    $output.ConsoleMAC = $vnet.ConsoleNic[0].Mac
    Write-Output $output 
}
