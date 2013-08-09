$Computer = "."
$Class = "Win32_Share."
$Method = "Delete"

# Win32_Share. Key Properties :
$Name = [string]'Posh'

$filter="Name = '$Name'"
$MC = get-WMIObject $class -computer $Computer -Namespace "ROOT\CIMV2" -filter $filter


# $MC = [Wmi]"\\$Computer\Root\CimV2:$Class.$filter"
$InParams = $mc.psbase.GetMethodParameters($Method)



"Calling Win32_Share. : Delete "

$R = $mc.PSBase.InvokeMethod($Method,$Null)
"Result :"
$R | Format-list