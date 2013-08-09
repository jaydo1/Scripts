$(foreach ($cluster in get-cluster) { get-view -viewtype VirtualMachine -SearchRoot $cluster.id | select @{N="VM name";E={$_.Name} },@{N=
"PowerState";E={$_.Summary.Runtime.PowerState}} ,@{N="Guest OS";E={$_.Config.GuestFullName} } , @{N="Cluster";E={$cluster.name} },@{N="VM .Notes";E={$_.Summary.
Config.Annotation} }, @{N="AD Description";E={(Get-QADComputer $_.Name).Description} },@{N="AD ManagedBy";E={((Get-QADComputer $_.name).ManagedBy | Get-QADUser)
.DisplayName} } }) | export-csv -NoTypeInformation c:\report.csv