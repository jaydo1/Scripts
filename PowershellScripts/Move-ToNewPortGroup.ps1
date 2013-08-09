# Moving VMs from one port group to another

function Move-ToNewPortGroup{

    <#
    .SYNOPSIS
        Move VMs from one Port Group to another.
    .DESCRIPTION
        Move VMs from one Port Group to another.
    .NOTES
        Source:  Automating vSphere Administration
        Authors: Luc Dekens, Arnim van Lieshout, Jonathan Medd,
                 Alan Renouf, Glenn Sizemore
    .PARAMETER Source
        Name of Port Group to move from
    .PARAMETER Target
        Name of Port Group to move to
    .PARAMETER Cluster
        Name of Cluster containing VMs
    .EXAMPLE
		Move-ToNewPortGroup -Source PortGroup01 -Target PortGroup02 -Cluster Cluster01
    #>
	[CmdletBinding()]
    Param(
         [parameter(Mandatory=$True
        ,    HelpMessage='Name of Port Group to move from'
        )]
        [String]
        $Source
    ,    
         [parameter(Mandatory=$True
        ,    HelpMessage='Name of Port Group to move to'
        )]
        [String]
        $Target
	,
	    [String]
        $Cluster
    )

		$SourceNetwork = $Source
		$TargetNetwork = $Target		
		
		if ($Cluster){		
		Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq $SourceNetwork } | Set-NetworkAdapter -NetworkName $TargetNetwork -Confirm:$false
		}
		else {
		Get-VM | Get-NetworkAdapter | Where-Object {$_.NetworkName -eq $SourceNetwork } | Set-NetworkAdapter -NetworkName $TargetNetwork -Confirm:$false
		}
}