function Get-ProductKey {   
    $map="BCDFGHJKMPQRTVWXY2346789"
    $value = (get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42] 
    $ProductKey = "" 
    for ($i = 24; $i -ge 0; $i--) {
      $r = 0
      for ($j = 14; $j -ge 0; $j--) {
        $r = ($r * 256) -bxor $value[$j]
        $value[$j] = [math]::Floor([double]($r/24))
        $r = $r % 24
      }
      $ProductKey = $map[$r] + $ProductKey
      if (($i % 5) -eq 0 -and $i -ne 0) {
        $ProductKey = "-" + $ProductKey
      }
    }
    $ProductKey
} 
