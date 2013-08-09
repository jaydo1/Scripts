

$server = '172.26.40.209'

$user = 'jsmith'

$pass = 'mother12'

if ($pass -eq '') {

echo 'Enter the password to log in to VirtualCenter: '

$password = read-host -assecurestring

$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $user, $password

get-viserver -server $server -credentials $credentials

} else {

  get-viserver -server $server -user $user -pass $pass

}

$password = $null

foreach ($f in (import-csv "C:\parameters.csv")) {
  $credentials = $null

  $baseCommand = 'add-vmhost -name $f."Host Name" -force -location (get-datacenter $f.Datacenter)'

  if ($f.Password) {
    $baseCommand += '-user $f.Login -pass $f.Password '
  } else {
    if ($password -eq $null) {
      # Prompt for a password.
      echo "Enter the password to be used for all hosts: "
      $password = read-host -assecurestring
    }
    $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $f.Login, $password
    $baseCommand += '-credential $credential '
  }
  if ($f.Port) {
    $baseCommand += '-port $f.Port '
  }

  invoke-expression $baseCommand
}
