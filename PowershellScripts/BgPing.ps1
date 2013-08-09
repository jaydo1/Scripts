Param ($HostFile, `
	   [switch]$DnsLookup,  [int]$BatchSize=100, `
	   [int]$CheckAfter=0,  $OutFile, `
	   [switch]$OutObject,  $Show="ALL", `
	   [switch]$Help,	   [switch]$History)
$HelpText = @'
 #######################################################################################
 Name	: BgPing.ps1
 Date	: 03/22/2011
 Author  : xb90@PoshTips.com
 Site	: http://poshtips.com
 Purpose : BgPing is a "Background Ping" script designed to quickly check network status
		   of a large list of hostnames (or IP Addresses) using PowerShell background
		   jobs. Under normal conditions the script is capable of returning results for
		   thousands of hosts in less than 10 minutes. Results may be output to a CSV file
		   or returned as a PowerShell object.
 
 Usage:
 
	./BgPing -HostFile  [-DnsLookup][-BatchSize ][-CheckAfter ][-OutFile ][-OutObject][-Help]
 
 Where:
 
	-HostFile	 Specifies a text file containing a list of network devices to
				  be pinged. List items can be either host names or IP Addresses.
				  Hostnames, or IP Addresses are accepted (IPv4 or IPv6 ok); only
				  ONE ITEM per line. Entries beginning with "#" will be treated as
				  comments and ignored.
	-DnsLookup	Causes two additional fields to be added to the results (named
				  "DnsHostName" and "DnsIpAddress". Both fields will be populated
				  with content if a DNS host lookup is successful, otherwise they
				  will be empty. Note that either entry could be redundant depending
				  on what was passed in the -HostFile entry. Only the first IP Address
				  found in DNS will be returned regardless of how many may be assigned.
				  CAUTION: Use of this option can add significant processing time.
	-BatchSize	Specifies the maximum number of hosts that will be submitted to
				  a background job. Default is 100.
	-CheckAfter   Begin checking (and collecting) job results after the the number
				  of active background jobs reaches this number. The default value
				  is 0 (zero) which has the effect of no limit at all whereby job
				  results are not collected until after all background jobs have
				  been submitted.
	-OutFile	  Specifies a filename to which the CSV-formatted results will be
				  written. Omitting this parameter will cause the results to be output
				  as a PowerShell object. See examples for usage.
	-OutObject	Causes script to return an array of Ping Result objects which can be
				  captured to a local PowerShell variable for further processing.
	-Show		 Specifies which type of ping result to output. Options are:
					 "FAIL"	= Only output non-successful results
					 "SUCCESS" = Only output successful results
					 Omit this parameter to show all results
	-Help		 Displays this help
 
 Examples:
	./bgping -hostfile servers.txt -batchsize 200 -OutFile pingresult.csv
		 Results will be written to the the file "pingresult.csv"
 
	$result = ./bgping -hostfile servers.txt -batchsize 200 -OutObject
		 Results will be assigned to the variable "$result" as a PowerShell object array
 
 Comments: Output from this script will be sorted by hostname with any duplicate entries
		   removed. Source entries (in the -HostFile file) beginning with "#" character
		   will be treated as comments and ignored.
 
 #######################################################################################
'@
$HistoryText = @'
 Maintenance Log
 Date	   By   Updates (insert newest updates at top)
 ---------- ---- ---------------------------------------------------------------------
 04/01/2011 xb90 Bugfix - force statuscode to 99999 for non-resolvable hostnames
 03/28/2011 xb90 New Script
#######################################################################################
'@
 
#Note: Status Code 99999  has been added to flag test-connectin call failures
$StatusCodes = @{
		0 =	"Success";
	11001 = "Buffer Too Small";
	11002 = "Destination Net Unreachable";
	11003 = "Destination Host Unreachable";
	11004 = "Destination Protocol Unreachable";
	11005 = "Destination Port Unreachable";
	11006 = "No Resources";
	11007 = "Bad Option";
	11008 = "Hardware Error";
	11009 = "Packet Too Big";
	11010 = "Request Timed Out";
	11011 = "Bad Request";
	11012 = "Bad Route";
	11013 = "TimeToLive Expired Transit";
	11014 = "TimeToLive Expired Reassembly";
	11015 = "Parameter Problem";
	11016 = "Source Quench";
	11017 = "Option Too Big";
	11018 = "Bad Destination";
	11032 = "Negotiating IPSEC";
	11050 = "General Error has occurred";
	99999 = "CALL FAILED"}
 
if ($help -or $History -or (!$HostFile)){
	write-host $HelpText
	if ($History){write-host $HistoryText}
	exit
	}
 
function isIPAddress(){
	param ($object)
	($object -as [System.Net.IPAddress]).IPAddressToString -eq $object -and $object -ne $null
	}
 
######################################################
## MAIN
######################################################
 
$elapsedTime = [system.diagnostics.stopwatch]::StartNew()
 
$result = @()
$itemCount = 0
$callFailure = test-connection -computername localhost -count 1
$callFailure.statuscode = 99999
$callFailure.address = "notset"
 
if (get-job|? {$_.name -like "BgPing*"}){
	write-host "ERROR: There are pending background jobs in this session:" -back red -fore white
	get-job |? {$_.name -like "BgPing*"} | out-host
	write-host "REQUIRED ACTION: Remove the jobs and restart this script" -back black -fore yellow
	$yn = read-host "Automatically remove jobs now?"
	if ($yn -eq "y"){
		get-job|? {$_.name -like "BgPing*"}|% {remove-job $_}
		write-host "jobs have been removed; please restart the script" -back black -fore green
		}
	exit
	}
 
if (!(test-path $HostFile)){
	write-host "ERROR: `"$HostFile`" is not a  valid file" -back black -fore red
	write-host "REQUIRED ACTION: Re-run this script using a valid filename" -back red -fore white
	exit
	}
 
$offset = 0
$itemCount = gc $HostFile |sort |get-unique | ? {((!$_.startswith("#")) -and ($_ -ne ""))} | measure-object -line |% {$_.lines}
 
write-host " BgPing started at $(get-date) ".padright(60)			 -back darkgreen -fore white
write-host "   -HostFile	  : $HostFile"							-back black -fore green
write-host "					(contains $itemCount unique entries)" -back black -fore green
if ($DnsLookup){$temp="Selected"}else{$temp="Not Selected"}
write-host "   -DnsLookup	 : $temp"								-back black -fore green
write-host "   -BatchSize	 : $BatchSize"						   -back black -fore green
if ($CheckAfter){$temp="Selected"}else{$temp="Not Selected"}
write-host "   -CheckAfter	: $temp"								-back black -fore green
write-host "   -Show		  : $Show"								-back black -fore green
if ($OutFile){$temp=$OutFile}else{$temp="Not Selected"}
write-host "   -OutFile	   : $temp"								-back black -fore green
if ($OutObject){$temp="Selected"}else{$temp="Not Selected"}
write-host "   -OutObject	 : $temp"								-back black -fore green
write-host ""
 
$activeJobCount = 0
$totalJobCount = 0
 
write-host "Submitting background ping jobs..." -back black -fore yellow
 
for ($offset=0; $offset -lt $itemCount;$offset += $batchSize){
	$activeJobCount += 1; $totalJobCount += 1; $HostList = @()
	$HostList += gc $HostFile |sort |get-unique |? {((!$_.startswith("#")) -and ($_ -ne ""))} | select -skip $offset -first $batchsize
	$j = test-connection -computername $HostList -count 4 -throttlelimit 32 -erroraction silentlycontinue -asjob
 
	# Initial Job Name Format: BgPing:N:N:N
	#   where numeric placeholders (N) =
	#	 JobCount
	#	 Starting Line to begin reading from HostFile
	#	 Number of Lines read from hostfile
	$j.name = "BgPing`:$totalJobCount`:$($offset+1)`:$($HostList.count)"
 
	#write-host "$($j.name)"
	write-host "+" -back black -fore cyan -nonewline
 
	if (($checkAfter) -and ($activeJobCount -ge $checkAfter)){
		write-host "`n$totaljobCount jobs submitted; checking for completed jobs..." -back black -fore yellow
		foreach ($j in get-job | ? {$_.name -like "BgPing*" -and $_.state -eq "completed"}){
			$result += receive-job $j
			remove-job $j
			$activeJobcount -= 1
			write-host "-" -back black -fore cyan -nonewline
			}
		}
	}
 
write-host "`n$totaljobCount jobs submitted, checking for completed jobs..." -back black -fore yellow
 
$recCnt = 0
while (get-job |? {$_.name -like "BgPing*"}){
	foreach ($j in get-job | ? {$_.name -like "BgPing*"}){
		#write-host "Job: $($j.name) State: $($j.state) " -back black -fore cyan -nonewline
		$temp = @()
		if ($j.state -eq "completed"){
			$temp = @()
			$temp += receive-job $j
			$result += $temp
			#write-host " (read $($temp.count) Lines - result count : $($result.count))"  -back black -fore green
			remove-job $j
			$ActiveJobCount -= 1
			write-host "-" -back black -fore cyan -nonewline
			}
		elseif ($j.state -eq "failed"){
			$temp = $j.name.split(":")
			if ($temp[1] -eq "R"){
				#
				# This is a single-entry recovery Job failure
				#	extract hostname from the JobName and update our callFailure record
				#	force-feed callFailure record into the results array
				#	delete the job
				#
				write-host " "
				write-host "Call Failure on Host: $($temp[2]) " -back red -fore white
				remove-job $j
				$callFailure.address = $temp[2]
				$result += $callFailure
				write-host "resuming check for completed jobs..." -back black -fore yellow
				}
			else{
				#
				# The original background job failed, so need to resubmit each hostname from that job
				# to determine which host failed and gather accurate ping results for the others
				#
				# Recovery Job Name Format: BgPing:R:
				#   where "R" indicates a Recovery job and  is the hostname or IP Address to be pinged
				#   Recovery jobs will only have ONE hostname specified
				#
				write-host "`nFailure detected in job: $($j.name); recovering now..." -back black -fore red
				remove-job $j
				$ActiveJobCount -= 1
				$HostList = gc $HostFile |sort|get-unique|? {((!$_.startswith("#")) -and ($_ -ne ""))} | select -skip $($temp[2]-1) -first $temp[3]
				foreach ($x in $HostList){
					$j = test-connection -computername $x -count 4 -throttlelimit 32 -erroraction silentlycontinue -asjob
					$j.name = "BgPing:R:$x"
					write-host "." -back black -fore cyan -nonewline
					}
				write-host "`nresuming check for completed jobs..." -back black -fore yellow
				}
			}
		}
 
	if ($result.count -lt $itemCount){
		sleep 5
		}
	}
 
write-host " "
write-host  " BgPing finished Pinging at $(get-date) ".padright(60) -back darkgreen -fore white
write-host ("   Hosts Pinged : {0}" -f $($result.count)) -back black -fore green
write-host ("   Elapsed Time : {0}" -f $($ElapsedTime.Elapsed.ToString())) -back black -fore green
 
$result | add-member -membertype NoteProperty -Name StatusDescr -value "" -Force
foreach ($r in $result){
	if ($r.statusCode -eq $null){
		$r.statusCode = 99999
		}
	$r.StatusDescr = $statusCodes.item([int]$r.statusCode)
	}
 
if ($DnsLookup){
	write-host "DNS Hostname lookup started..." -back black -fore yellow
	write-host "BE PATIENT - this could take a while!" -back black -fore yellow
	$result | add-member -membertype noteproperty -name DnsHostName -value "" -Force
	$result | add-member -membertype noteproperty -name DnsIpAddress -value "" -Force
	$DnsLookupFailures = 0
	foreach ($r in $result){
		try{
			# gethostentry only thows errors on invalid IP Addresses
			# if returned hostname is IpAddress, then the lookup failed
			$x = [system.net.dns]::gethostentry($r.address)
			if (isIPAddress $x.hostname){
				throw "no such host is known"
				}
			else{
				$r.DnsHostName = $x.hostname
				$r.DnsIpAddress = $x.addresslist[0].ipaddresstostring
				}
			write-host "." -back black -fore cyan -nonewline
			}
		catch{
			write-host "." -back red -fore black -nonewline
			#write-host "`nDNS Lookup Failed: $($r.address)" -back red -fore black -nonewline
			$DnsLookupFailures += 1
			}
		}
	write-host  ""
	write-host  " BgPing finished DNS Lookup at $(get-date) ".padright(60) -back darkgreen -fore white
	write-host ("   Lookup Failures : {0}" -f $DnsLookupFailures) -back black -fore green
	write-host ("   Lookup Success  : {0}" -f ($itemCount - $DnsLookupFailures)) -back black -fore green
	write-host ("   Elapsed Time	: {0}" -f $($ElapsedTime.Elapsed.ToString())) -back black -fore green
	}
 
write-host "`nSUMMARY:" -back black -fore cyan
$result | group statuscode | sort count | `
	ft -auto `
		@{Label="Status"; Alignment="left"; Expression={"$($_.name)"}}, `
		@{Label="Description"; Alignment="left"; Expression={"{0}" -f $statuscodes.item([int]$_.name)}}, `
		count `
	| out-host
 
switch ($show){
	SUCCESS{
		write-host "extracting Successful ping results..." -back black -fore yellow
		$result = $result|? {$_.statuscode -eq 0}
		write-host "done" -back black -fore yellow
		write-host ("  Elapsed Time : {0}" -f $($ElapsedTime.Elapsed.ToString())) -back black -fore green
		}
	FAIL{
		write-host "extracting UnSuccessful ping results..." -back black -fore yellow
		$result = $result|? {$_.statuscode -ne 0}
		write-host "done" -back black -fore yellow
		write-host ("  Elapsed Time : {0}" -f $($ElapsedTime.Elapsed.ToString())) -back black -fore green
		}
	}
 
if ($OutFile){
	write-host "writing results to $outfile... " -back black -fore yellow
	if ($DnsLookup){
		$result | select address,statuscode,statusdescr,dnshostname,dnsipaddress | export-csv -notypeinfo -path $OutFile
		}
	else{
		$result | select address,statuscode,statusdescr | export-csv -notypeinfo -path $OutFile
		}
	write-host "done" -back black -fore yellow
	}
if ($OutObject){
	$result
	}
write-host  " BgPing completed all requested operations at $(get-date) ".padright(60) -back darkgreen -fore white
write-host ("   Elapsed Time : {0}" -f $($ElapsedTime.Elapsed.ToString())) -back black -fore green
