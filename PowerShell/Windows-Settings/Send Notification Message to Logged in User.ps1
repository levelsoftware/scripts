<#
This script is provided as a convenience for Level.io customers. We cannot 
guarantee this will work in all environments. Please test before deploying
to your production environment.  We welcome contribution to the scripts in 
our community repo!

.DESCRIPTION
    Send a message to the logged in user using a Windows native 
    notification 
    
    Uses the following PowerShell Modules:
    https://github.com/Windos/BurntToast - Toast Library
    https://github.com/KelvinTegelaar/RunAsUser - To run as logged-in user
.LANGUAGE
    PowerShell
.TIMEOUT
    100
.LINK
#>

#Put your message down on line 63.  Can't pass variables to the invoke-ascurrentuser
#scriptblock.  Even if the variable is expanded as a string and converted back to 
#a scriptblock, the command won't take.  :eyeroll:

#Check if a user is logged in.  Can't send a toast to no one!
$LoggedInUser = Get-Process -IncludeUserName -Name explorer | Select-Object -ExpandProperty UserName -Unique
if ($LoggedInUser) {
    "$LoggedInUser is logged in.  Sending toast"
}
else {
    "No one is logged in.  Exiting..."
    Exit 1
}   

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Check for NuGet on the device and install if not present
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
if (Get-PackageProvider -Name NuGet) {
    Write-Host "NuGet Package already exists"
}
else {
    Write-host "Installing NuGet"
    Install-PackageProvider -Name NuGet -force
}   

#Check for dependent modules and install if not present
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
$ModuleList = "BurntToast", "RunAsUser"
foreach ($Module in $ModuleList) {
    if (Get-Module -ListAvailable -Name $Module) {
        Write-Host "$Module module already exists"
    } 
    else {
        Write-Host "$Module does not exist. Installing"
        Install-Module -Name $Module -Force
    }
}

invoke-ascurrentuser -scriptblock {
    $Text1 = New-BTText -Content  "Attention:"
    #Put your message here
    $Text2 = New-BTText -Content "Message goes here"
    $Button = New-BTButton -Content "Snooze" -snooze -id 'SnoozeTime'
    $Button2 = New-BTButton -Content "Dismiss" -dismiss
    $5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
    $10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
    $1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
    $4Hour = New-BTSelectionBoxItem -Id 240 -Content '4 hours'
    $1Day = New-BTSelectionBoxItem -Id 1440 -Content '1 day'
    $Items = $5Min, $10Min, $1Hour, $4Hour, $1Day
    $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
    $action = New-BTAction -Buttons $Button, $Button2 -inputs $SelectionBox
    $heroimage = New-BTImage -Source 'https://raw.githubusercontent.com/levelsoftware/scripts/main/Level_Logo_Animation.gif' -HeroImage
    $Binding = New-BTBinding -Children $text1, $text2 -HeroImage $heroimage
    $Visual = New-BTVisual -BindingGeneric $Binding
    $Content = New-BTContent -Visual $Visual -Actions $action
    Submit-BTNotification -Content $Content
}