Get-AlarmDefinition | %{
   $_ | Set-AlarmDefinition -ActionRepeatMinutes (60 * 24);
   $_ | New-AlarmAction -Email -To "vcenteralarms@customer.corp" | %{
      $_ | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow" -Repeat
      $_ | Get-AlarmActionTrigger | ?{$_.repeat -eq $false} | Remove-AlarmActionTrigger -Confirm:$false
      $_ | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat
   }
}
