function Add-SVNFile {
    # Usage Get-Childitem \\detnsw.win\0916\Teams2\IS_Enterprise_Systems\Virtualisation\Documentation\password database | Add-SVNFile -Uri https://unixvcs.services.det.nsw.edu.au/svn/virt/password database -Comment "Not sure if it's working"
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$File,
        [Parameter(Position=1,Mandatory=$true)]
        [String]$Uri, #Ton dépot SVN ex: https://unixvcs.services.det.nsw.edu.au/svn/virt/password database
        [Parameter(Position=2,Mandatory=$true)]
        [String]$Comment = "Nothing"
    )

    Start-Process -Filepath "svn.exe" -ArgumentList "co $uri" -Wait -WindowStyle Hidden
    Start-Process -Filepath "svn.exe" -ArgumentList "add $File" -Wait -WindowStyle Hidden
    Start-Process -Filepath "svn.exe" -ArgumentList "ci -m $Comment $File" -Wait -WindowStyle Hidden
