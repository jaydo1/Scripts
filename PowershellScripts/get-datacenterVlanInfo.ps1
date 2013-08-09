Get-Datacenter -Name Ultimo | 
Get-VirtualPortGroup | 
Select Name, @{N="VlanId";E={
    if($_.ExtensionData -is [VMware.Vim.HostPortGroup]){$_.VLanId}
    else{
      $t = $_.Extensiondata.Config.DefaultPortConfig.Vlan
      if($t.VlanId.Count){
        $t.VlanId | %{
          $_.Start.ToString() + "-" + $_.End.ToString()
        }
      }
      elseif($t.Pvlanid){
        $t.PvlanId
      }
      else{
        $t.VlanId
     }
    }
  }}