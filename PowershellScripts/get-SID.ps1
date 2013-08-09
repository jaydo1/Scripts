strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set objAccount = objWMIService.Get _
    ("Win32_UserAccount.Name='jamie.smith',Domain='FFX'")
Wscript.Echo objAccount.SID