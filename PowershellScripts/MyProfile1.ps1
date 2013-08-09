Param ([switch]$help,[switch]$history)
$HelpText = @'
 #######################################################################################
 Script        : {0}
 Title         : PoshTips Startup Profile Script
 Date          : (see maintenace log below)
 Author        : xb90@poshtips.com
 Purpose       : Use this setup commonly used functions, scripts dir, aliases, etc
 Disclaimer    : This script carries no warranty either expressed or implied
                 regarding suitability for use in your computing environment.
                 PoshTips.com highly recommends thorough testing of this script
                 before using it in a production environment. Users of this script
                 assume all risk for any undesireable results.
 Usage: 
                Script runs automatically once installed to your preferred $profile path 
 Optional Params:
                -Help    show this help page
				-History show this help page + maintenance history

 #######################################################################################
'@
$HistoryText = @'
 Maintenance Log
 Date       By   Updates (important: insert newest updates at top)
 ---------- ---- ---------------------------------------------------------------------
 03/18/2012 KES Dynamically insert $profile script name
 03/14/2012 KES Auto-create scripts directory if does not exist; header update
 09/29/2011 KES Added Alias for shortcuts to open office 3
 08/23/2011 KES Added Aliases for shortcuts to notepad++ and excel
 08/01/2011 KES New Script
 #######################################################################################
'@
$myScriptsDir = "$($env:SystemDrive)\scripts\powershell"
$myProfileScript = $MyInvocation.MyCommand.Path
switch ($myProfileScript) {
    $profile.AllUsersAllHosts
	    {$myProfileScript = "`$profile.AllUsersAllHosts"}
	$profile.AllUsersCurrentHost
	    {$myProfileScript = "`$profile.AllUsersCurrentHost"}
	$profile.CurrentUserAllHosts
	    {$myProfileScript = "`$profile.CurrentUserAllHosts"}
	$profile.CurrentUserCurrentHost
	    {$myProfileScript = "`$profile.CurrentUserCurrentHost"}
	}
function ShowHeader {
    $h = @()
    $h += $HelpText |% {($_.split("`n")[1].trim() -f $MyProfileScript )}
    $h += $HelpText |% {$_.split("`n")[2].trim()}
    $h += $HelpText |% {$_.split("`n")[4].trim()}
    $lmdte = $HistoryText |% {$_.split("`n")[3].split(" ")[1].trim()}
    $h += ("Last Updated  : {0}" -f $lmdte)
    foreach ($x in $h) { write-host $x.padright(80) -back cyan -fore black }
    write-host ""
    }
function CheckArgs {
    if ($help -or $History){
        write-host $HelpText
        if ($History){write-host $HistoryText}
        exit
        }
	}
function list-profiles {
    #use to quickly check which (if any) profile slots are inuse
    $profile|gm *Host*| `
    % {$_.name}| `
    % {$p=@{}; `
    $p.name=$_; `
    $p.path=$profile.$_; `
    $p.exists=(test-path $profile.$_); 
    new-object psobject -property $p} | ft -auto
    }
new-item -path alias:LPro -value list-profiles | out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function split-envpath {
  #display system path components in a human-readable format
  $p = @(get-content env:path|% {$_.split(";")})
  "Path"
  "===="
  foreach ($p1 in $p){
    if ($p1.trim() -gt ""){
      $i+=1;
      "$i : $p1"
      }
    }
  ""
  }
new-item -path alias:epath -value split-envpath |out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Get-LocalDisk{
  Param ([string] $hostname="localhost")
  #Quick Local Disk check
  "***************************************************************"
  "*** $hostname : Local Disk Info"
  Get-WmiObject `
    -computer $hostname `
    -query "SELECT * from Win32_LogicalDisk WHERE DriveType=3" `
    | format-table -autosize `
      DeviceId, `
      VolumeName, `
      @{Label="FreeSpace(GB)"; Alignment="right"; Expression={"{0:N2}" -f ($_.FreeSpace/1GB)}},`
      @{Label="Size(GB)"; Alignment="right"; Expression={"{0:N2}" -f ($_.size/1GB)}} `
    | out-default
    }
new-item -path alias:gld -value Get-LocalDisk |out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function CountDown() {
    param(
    [int]$hours=0, 
    [int]$minutes=0, 
    [int]$seconds=0,
    [switch]$help)
    $HelpInfo = @'

    Function : CountDown
    By       : xb90 at http://poshtips.com
    Date     : 02/22/2011 
    Purpose  : Pauses a script for the specified period of time and displays
               a count-down timer to indicate the time remaining.
    Usage    : Countdown [-Help][-hours n][-minutes n][seconds n]
               where      
                      -Help       displays this help
                      -Hours n    specify the number of hours (default=0)
                      -Minutes n  specify the number of minutes (default=0)
                      -Seconds n  specify the number of seconds (default=0)
                      
'@    
    if ($help -or (!$hours -and !$minutes -and !$seconds)){
        write-host $HelpInfo
        return
        }
    $startTime = get-date
    $endTime = $startTime.addHours($hours)
    $endTime = $endTime.addMinutes($minutes)
    $endTime = $endTime.addSeconds($seconds)
    $timeSpan = new-timespan $startTime $endTime
    write-host $([string]::format("`nScript paused for {0:#0}:{1:00}:{2:00}",$hours,$minutes,$seconds)) -backgroundcolor black -foregroundcolor yellow
    while ($timeSpan -gt 0) {
        $timeSpan = new-timespan $(get-date) $endTime
        write-host "`r".padright(40," ") -nonewline
        write-host "`r" -nonewline
        write-host $([string]::Format("`rTime Remaining: {0:d2}:{1:d2}:{2:d2}", `
            $timeSpan.hours, `
            $timeSpan.minutes, `
            $timeSpan.seconds)) `
            -nonewline -backgroundcolor black -foregroundcolor yellow
        sleep 1
        }
    write-host ""
    }
new-item -path alias:CntDn -value CountDown |out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function NewTimestampedFile() {
Param
	(
	[string]$Folder="",
	[string]$Prefix="temp",
	[string]$Type="log",
    [switch]$Help
	)
    $HelpInfo = @'

    Function : NewTimestampedFile
    By       : xb90 at http://poshtips.com
    Date     : 02/23/2011 
    Purpose  : Creates a unique timestamp-signature text file.
    Usage    : NewTempFile [-Help][-folder <text>][-prefix <text>][-type <text>]
               where      
                      -Help       displays this help
                      -Folder     specify a subfolder or complete path
                                  where the new file will be created
                      -Prefix     a text string that will be used as the 
                                  the new file prefix (default=TEMP)
                      -Type       the filetype to use (default=LOG)
    Details  : This function will create a new file and any folder (if specified)
               and return the name of the file.
               If no parameters are passed, a default file will be created in the
               current directory. Example:
                                           temp_20110223-164621-0882.log
'@    
    if ($help){
        write-host $HelpInfo
        return
        }
	
	#create the folder (if needed) if it does not already exist
	if ($folder -ne "") {
		if (!(test-path $folder)) {
			write-host "creating new folder `"$folder`"..." -back black -fore yellow
			new-item $folder -type directory | out-null
			}
		if (!($folder.endswith("\"))) {
			$folder += "\"
			}
		}

	#generate a unique file name (with path included)
	$x = get-date
	$TempFile=[string]::format("{0}_{1}{2:d2}{3:d2}-{4:d2}{5:d2}{6:d2}-{7:d4}.{8}",
		$Prefix,
		$x.year,$x.month,$x.day,$x.hour,$x.minute,$x.second,$x.millisecond,
		$Type)
	$TempFilePath=[string]::format("{0}{1}",$folder,$TempFile)
		
	#create the new file
	if (!(test-path $TempFilePath)) {
		new-item -path $TempFilePath -type file | out-null
		}
	else {
		throw "File `"$TempFilePath`" Already Exists!"
		}

	return $TempFilePath
}
new-item -path alias:ntf -value NewTimestampedFile |out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Export-PSCredential {
    param ( 
        #$Credential = (Get-Credential), 
        $Credential = "", 
        $Path = "credentials.enc.xml",
        [switch]$Help)
        
    $HelpInfo = @'

    Function : Export-PSCredential
    Date     : 02/24/2011 
    Purpose  : Exports user credentials to an encoded XML file. Resulting file 
               can be imported using function: Import-PSCredential
    Usage    : Export-PSCredential [-Credential <[domain\]username>][-Path <filename>][-Help]
               where      
                  -Credential specify the user account for which we will create a credential file
                              password will be collected interactively
                  -Path       specify the file to which credential information will be written.
                              if omitted, the file will be "credentials.enc.xml" in the current
                              working directory.
                  -Help       displays this help information
    Note     : Import-PSCredential can be used to decode this file into a PSCredential object and
               MUST BE executed using the same user account that was used to create the encoded file.
               
'@    

    if ($help){
        write-host $HelpInfo
        return
        }
    $Credential = (Get-Credential $credential)
    # Look at the object type of the $Credential parameter to determine how to handle it
    switch ( $Credential.GetType().Name ) {
        # It is a credential, so continue
        PSCredential { continue }
        # It is a string, so use that as the username and prompt for the password
        String { $Credential = Get-Credential -credential $Credential }
        # In all other caess, throw an error and exit
        default { Throw "You must specify a credential object to export to disk." }
        }
    # Create temporary object to be serialized to disk
    $export = "" | Select-Object Username, EncryptedPassword
    # Give object a type name which can be identified later
    $export.PSObject.TypeNames.Insert(0,’ExportedPSCredential’)
    $export.Username = $Credential.Username
    # Encrypt SecureString password using Data Protection API
    # Only the current user account can decrypt this cipher
    $export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString
    # Export using the Export-Clixml cmdlet
    $export | Export-Clixml $Path
    Write-Host -foregroundcolor Green "Credentials saved to: " -noNewLine
    # Return FileInfo object referring to saved credentials
    Get-Item $Path
	}
new-item -path alias:ecred -value Export-PSCredential |out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Import-PSCredential {
    param ( $Path = "credentials.enc.xml",
    [switch]$Help)
        
    $HelpInfo = @'

    Function : Import-PSCredential
    Date     : 02/24/2011 
    Purpose  : Imports user credentials from an encoded XML file. 
    Usage    : $cred = Import-PSCredential [-Path <filename>][-Help]
               where   
                  $cred       will contain a PSCredential object upon successful completion               
                  -Path       specify the file from which credentials will be read
                              if omitted, the file will be "credentials.enc.xml" in the current
                              working directory.
                  -Help       displays this help information
    Note     : Credentials can only be decoded by the same user account that was used to 
               create the encoded XML file
               
'@    

    if ($help){
        write-host $HelpInfo
        return
        }

    # Import credential file
        $import = Import-Clixml $Path
        # Test for valid import
        if ( !$import.UserName -or !$import.EncryptedPassword ) {
            Throw "Input is not a valid ExportedPSCredential object, exiting."
	        }
        $Username = $import.Username
        # Decrypt the password and store as a SecureString object for safekeeping
        $SecurePass = $import.EncryptedPassword | ConvertTo-SecureString
        # Build the new credential object
        $Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePass
        Write-Output $Credential
	}
new-item -path alias:icred -value Import-PSCredential |out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
New-Alias which get-command

ShowHeader
if (!(test-path $myScriptsDir)){
    write-host "creating default scripts directory ($myScriptsDir)" -back black -fore green
    new-item -path $myScriptsDir -type directory
	}
set-location $myScriptsDir | out-null
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


write-host "** New Declarations **".padright(50) -back black -fore yellow
write-host "Type      Name                  Alias".padright(50) -back yellow -fore black
write-host "Function  list-profiles         lpro ".padright(50) -back black -fore yellow
write-host "Function  split-envpath         epath ".padright(50) -back black -fore yellow
write-host "Function  Get-LocalDisk         gld  ".padright(50) -back black -fore yellow
write-host "Function  CountDown             CntDn".padright(50) -back black -fore yellow
write-host "Function  NewTimestampedFile    ntf  ".padright(50) -back black -fore yellow
write-host "Function  Export-PSCredential   ecred".padright(50) -back black -fore yellow
write-host "Function  Import-PSCredential   icred".padright(50) -back black -fore yellow
write-host "CmdLet    Get-Command           which".padright(50) -back black -fore yellow
write-host ""
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
$PgmAliasList = (
	"npp    |c:\program files\notepad++\notepad++.exe; `
	         c:\program files (x86)\notepad++\notepad++.exe",
    "excel  |C:\Program Files\Microsoft Office\Office12\EXCEL.EXE",
	"oo3    |C:\Program Files (x86)\OpenOffice.org 3\program\soffice.exe; `
	         C:\Program Files\OpenOffice.org 3\program\soffice.exe"
	)
write-host "Setting up Program Aliases...`n" -background black -foreground green
write-host "  Alias       Path"
write-host "  ==========  ======================================="

foreach ($alias in $PgmAliasList) {
	$name = $alias.split("|")[0].trim()
	write-host "  $($name.padright(12))" -nonewline
	if (!(test-path Alias:\$name)){
		$pgmPaths = $alias.split("|")[1].split(";")
		$pathOk = $false
		foreach ($pgmPath in $pgmPaths) {
			if (test-path $pgmPath.trim()){
				set-alias $name $pgmPath.trim() -scope Global
				write-host $pgmPath.trim() -background black -foreground green
				$pathOk = $true
				break
				}
			}
			if (!$pathOk) {
				write-host "No valid path found" -background black -foreground red
				}
		}
	else {
		$x = get-alias $name 
		write-host "Already defined ($($x.definition))" -background black -foreground yellow
		}
	}
write-host ""
