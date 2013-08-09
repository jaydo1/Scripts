$outputFile = 'c:\test\host_log.html'
$output = @()
$output += '<html><head></head><body>'
$output += '<style>table{border-style:none;border-width:0px;font-size:8pt;background-color:#ccc;width:100%;}th{text-align:center;}td{background-color:#fff;width:20%;border-style:dotted;border-width:1px;}body{font-family:verdana;font-size:8pt;}h1{font-size:14pt;}h2{font-size:12pt;}</style>'
$output += '<h1>Hostlogs</h1>'
$output += '<p>List of all vmkwarning Logfiles:</p>'
$output += '<table>'
$Clusters = (Get-Folder 'ESX-Clusters')
ForEach ($Cluster in $Clusters)
{
$output += '<tr>'
$output += '<th>'
$output += $Cluster.Name
$output += '</th>'
$output += '</tr>'
ForEach ($ESXHost in ($Cluster | Get-VMHost | sort Name))
{
$output += '<tr>'
$output += '<td>'
$entries += (get-log -VMHost (Get-VMHost $ESXHost)vmkwarning).Entries
}
$entries_sorted = $entries | sort
ForEach ($entry in $entries_sorted)
{
$output += $entry
$output += '<br/>'
}
$output += '</td>'
$output += '</tr>'
}
$output += '</table>'
$output += '</body></html>'
$output | Out-File $outputFile -Force