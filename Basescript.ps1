Function Get-FileName
{
    # Function came from this website: http://www.workingsysadmin.com/open-file-dialog-box-in-powershell/
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = Get-Location
    #$OpenFileDialog.filter = "Text Document (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

# Make a text file that contains your server names each in a line of its own. 

$inputfile = Get-FileName
$serverlist = (Get-Content $inputfile)

$credentials = Get-Credential

ForEach($server in $serverlist) {
    
    #$servername = "$server.$DomainName"
    
    #Write-Host "################## $servername ##################"
    
    # Uncomment and fill in the scriptblock with a custom command, here a simple google ping has been set up.
    #Invoke-Command -ComputerName $servername -Credential $credentials -ScriptBlock {ping google.com}
}