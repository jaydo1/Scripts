function Get-ConsoleCommand
{
$ext = $env:pathext -split ';' -replace '\.','*.'
$desc = @{N='Description'; E={$_.FileVersionInfo.FileDescription}}
Get-Command -Name $ext | 
   Select-Object Name, Extension, $desc |
   Out-GridView
}
