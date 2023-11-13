$ErrorActionPreference = "STOP"
$Error.Clear()

$Folder = 'C:\FGUScripts'
$File = 'UpdateAppwriter.ps1'
$FileFullPath = "$($Folder)\$($File)"
$logFileLocation = "C:\FGUscripts\Logs\UpdateAppwriter-install"
$currentDate = Get-Date -Format "dd-MM-yyyy"
$Version = "1.0.0.3"

if ((Test-Path -Path $logFileLocation) -ne $true) {
    [void](New-Item -Path $logFileLocation -ItemType "directory")
}

function Add-Log($msg)
{
    $currentTime = Get-Date -Format "dddd dd-MM-yyyy HH:mm:ss:fff K"
    $msgTime = "[$($currentTime)]"
    $formattedMsg = "$($msgTime) - $($msg)"
    
    Write-Host $formattedMsg

    Add-Content "$($logFileLocation)\Log-$($currentDate).log" "$($formattedMsg)"
}

Add-Log -msg "------Starting script-------"

Add-Log -msg "Testing version-folder location existence - $((Test-Path -Path "$($Folder)\version"))"
if ((Test-Path -Path "$($Folder)\version") -ne $true) 
{
    Add-Log -msg "Creating folder"
    [void](New-Item -Path "$($Folder)\version" -ItemType "directory")
}

Add-Log -msg "Adding new version number .txt file"
Set-Content "$($Folder)\version\$($File)-$($Version).txt" "added on - $($currentDate)"


# Make folder if it dont exist
if ((Test-Path -Path $Folder) -ne $true) {
    Add-Log -msg "Creating FGUScripts folder"
    mkdir -p $Folder
}

# Test if file exists
if ((Test-Path -Path $FileFullPath) -ne $true) {
    Add-Log -msg "Copying file to FGUScripts"
    Copy-Item $File $FileFullPath
}
else {
    Add-Log -msg "Removing old script"
    Remove-Item $FileFullPath

    Add-Log -msg "Copying file to FGUScripts"
    Copy-Item $File $FileFullPath
}

if([bool](Get-ScheduledTask | Where-Object { $_.TaskName -like 'Update Appwriter' }))
{
    Add-Log -msg "Removing old Scheduled task"
    Unregister-ScheduledTask -TaskName "Update Appwriter" -Confirm:$false

    Add-Log -msg "Creating Scheduled Task"
    $Trigger=New-ScheduledTaskTrigger -AtLogOn
    $Action=New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory C:\FGUScripts -Argument "-executionpolicy Bypass -File .\UpdateAppwriter.ps1"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries

    Add-Log -msg "Registering the new task"
    Register-ScheduledTask -TaskName "Update Appwriter" -Trigger $Trigger -Action $Action -RunLevel Highest -User "System" -Settings $Settings

    Add-Log -msg "Running new task"
    Start-ScheduledTask -TaskName "Update Appwriter"
}
else {
    Add-Log -msg "Creating Scheduled Task"
    $Trigger=New-ScheduledTaskTrigger -AtLogOn
    $Action=New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory C:\FGUScripts -Argument "-executionpolicy Bypass -File .\UpdateAppwriter.ps1"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries

    Add-Log -msg "Registering the new task"
    Register-ScheduledTask -TaskName "Update Appwriter" -Trigger $Trigger -Action $Action -RunLevel Highest -User "System" -Settings $Settings

    Add-Log -msg "Running new task"
    Start-ScheduledTask -TaskName "Update Appwriter"
}

if($_)
{
    Add-Log("Error - Start")
    Add-Log($_)
    Add-Log("Error - End")
}

