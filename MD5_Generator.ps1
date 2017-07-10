# Written by Edwin Millan July 2017

[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

Function Get-FileName
{
    # Function came from this website: http://www.workingsysadmin.com/open-file-dialog-box-in-powershell/
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = Get-Location
    $OpenFileDialog.ShowHelp = $true
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

Function Get-FolderName
{
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        SelectedPath = Get-Location
    }
    $FolderBrowser.ShowDialog() | Out-Null
    $FolderBrowser.SelectedPath
}

Function Write-MD5File()
{
    param(
        [Parameter(Mandatory=$true)][string]$file,
        [Parameter(Mandatory=$true)][string]$single
    )
    
    # Use an older method of calculating MD5 if Powershell version is less than 4.0
    if ($host.Version.Major -lt 4)
    {
        $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $filehash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($file))) -replace "-", ""
    }
    else
    {
        $filehash = (Get-FileHash -Algorithm MD5 -Path $file).Hash 
    }
    $filepath = Split-Path $file
    $filename = Split-path $file -Leaf
    #$md5filename = "$([io.path]::GetFileNameWithoutExtension($file)).md5"
    Write-Output "$filehash  $filename" > (Join-Path $filepath "$filename.md5")
    if ($single -eq $true) {Write-Host "[$filehash  $filename] has been written to $filename.md5"}
}

# Ask the user what scope they will be using the MD5 generator.
Write-Host "Select one option:
1) Get MD5 for a single File
2) Get MD5 for all files in a folder
> " -NoNewline
$ScopeOption = Read-Host
$ScopeOption = $ScopeOption.Trim()

if($ScopeOption -eq "1")
{
    $file = Get-FileName
    Write-MD5File $file $true
}

elseif($ScopeOption -eq "2")
{
    $folderpath = Get-FolderName
    # Exclude already provided *.md5 files and any folders
    $folderfiles = Get-ChildItem $folderpath -Exclude *.md5 | ?{ -not $_.PsIsContainer }
    foreach ($file in $folderfiles){
        Write-MD5File $file $false
    }
    Write-Host "MD5 files have been written to $folderpath"
}
else
{
    Write-Error "Please provide a valid option"
}

Read-Host "Press Enter to continue"
