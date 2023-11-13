$ErrorActionPreference = "STOP"
$Error.Clear()

$Folder = 'C:\FGUScripts'
$File = 'UpdateAppwriter.ps1'
$FileFullPath = "$($Folder)\$($File)"
$logFileLocation = "C:\FGUscripts\Logs\UpdateAppwriter-uninstall"


if ((Test-Path -Path $logFileLocation) -ne $true) {
    [void](New-Item -Path $logFileLocation -ItemType "directory")
}

function Add-Log($msg)
{
    $currentDate = Get-Date -Format "dd-MM-yyyy"
    $currentTime = Get-Date -Format "dddd dd-MM-yyyy HH:mm:ss:fff K"
    $msgTime = "[$($currentTime)]"
    $formattedMsg = "$($msgTime) - $($msg)"
    
    Write-Host $formattedMsg

    Add-Content "$($logFileLocation)\Log-$($currentDate).log" "$($formattedMsg)"
}

Add-Log -msg "------Starting script-------"

if ((Test-Path -Path $Folder) -ne $true) {
    Add-Log -msg "Creating folder"
    mkdir -p $Folder
}

if ((Test-Path -Path $FileFullPath) -eq $true) {
    Add-Log -msg "Removing script"
    Remove-Item $FileFullPath
}


if([bool](Get-ScheduledTask | Where-Object { $_.TaskName -like 'Update Appwriter' }))
{
    Add-Log -msg "Removing Scheduled task"
    Unregister-ScheduledTask -TaskName "Update Appwriter" -Confirm:$false
}

$AppGUID = (get-wmiobject Win32_Product | Sort-Object -Property Name | where-object {$_.Name -like "*Appwriter*"}).IdentifyingNumber

if([bool]$AppGUID)
{
    Add-Log -msg "Uninstalling..."
    msiexec.exe /quiet /x $AppGUID
    Add-Log -msg "Done"
}


if($_)
{
    Add-Log("Error - Start")
    Add-Log($_)
    Add-Log("Error - End")
}