# Took Self Elevating Script from this Ben Guy:
# https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }

# Create a function to Extract zip files
function Extract-ZipFile($file, $destination){
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($file)
        foreach($item in $zip.items()){
            $shell.Namespace($destination).copyhere($item)
        }
    }


Write-Host "Downloading PSWindowsUpdate.zip"

# Download the PSWindowsUpdate file from my repository, easier than the source:
# https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc

$site = "https://github.com/edwinmillan/useful-tools-scripts/raw/master/Zip/PSWindowsUpdate.zip"

# Save to Temp file location
$output_file =  "$env:TMP\PSWindowsUpdate.zip"

# Get currently set proxy
$proxies = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer

if ($proxies.length -gt 0){
    # Connect to the site and download the zip file, use proxy. 
    $webrequest = Invoke-WebRequest -URI $site -Proxy "http://$proxies" -ProxyCredential (Get-Credential) -OutFile $output_file
}
else{
    # Connect to the site and download the zip file, do not use proxy. 
    $webrequest = Invoke-WebRequest -URI $site -OutFile $output_file
}


# Save to powershell module directory
$destination = "$env:WINDIR\System32\WindowsPowerShell\v1.0\Modules"

# Extract the zip file to destination
Extract-ZipFile -file $output_file -destination $destination

# Unblock Files
Get-ChildItem "$destination\PSWindowsUpdate" | Unblock-File

# Import the PSWindowsUpdate Module
Import-Module PSWindowsUpdate

#Add the Microsoft Update Service Manager
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d

# Clean up after yourself!
Remove-Item $output_file
