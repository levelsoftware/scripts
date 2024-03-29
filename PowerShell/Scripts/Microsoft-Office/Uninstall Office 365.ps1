<#
This script is provided as a convenience for Level.io customers. We cannot 
guarantee this will work in all environments. Please test before deploying
to your production environment.  We welcome contribution to the scripts in 
our community repo!

.DESCRIPTION
    Uninstall Office 365 Editions.  To uninstall all versions of Office,
    see "Uninstall All Versions of Office.ps1".
.LANGUAGE
    PowerShell
.TIMEOUT
    900
.LINK
#>

#Setup
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TempFolder = 'C:\temp\'
if (Test-Path -Path $TempFolder) {
}
else {
    mkdir c:\temp
}

#Download installers to temp folder
Write-Host "Downloading required files"
$BaseURL = "https://github.com/levelsoftware/scripts/raw/main/PowerShell/Scripts/Microsoft-Office/Uninstall%20Office%20365/"
$O365Setup = "OfficeSetup.exe"
$ConfigFile = "UninstallOffice.xml"
$ListOfFiles = $O365Setup, $ConfigFile
$ProgressPreference = 'SilentlyContinue'
foreach ($File in $ListOfFiles) {
    iwr -uri $BaseURL$File -outfile $TempFolder$File
    $FileSize = [math]::round((Get-Item -Path $TempFolder$File).Length / 1MB, 2)
    "Downloaded $File - $FileSize MB"
}

#Install Office
& $TempFolder$O365Setup /configure $TempFolder$ConfigFile