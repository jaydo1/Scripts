function Get-ProcessEx {
      param(
            $Name='*',           
            $ComputerName,            
            $Credential
      )
      $null = $PSBoundParameters.Remove('Name')
      $Name = $Name.Replace('*','%')      
      Get-WmiObject -Class Win32_Process @PSBoundParameters -Filter "Name like '$Name'" |
        ForEach-Object {
            $result = $_ | Select-Object Name, Owner, Description, Handle
            $Owner = $_.GetOwner()
            if ($Owner.ReturnValue -eq 2) {
                  $result.Owner = 'Access Denied'
            } else {
                  $result.Owner = '{0}\{1}' -f ($Owner.Domain, $Owner.User)
            }
            $result
        }
}
