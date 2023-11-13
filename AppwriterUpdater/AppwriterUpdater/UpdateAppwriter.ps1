$ErrorActionPreference = "Stop"

$source = 'http://static.lingapps.dk/applications/appwriter/windows/AppWriterInstaller_DA.Latest.msi'
$destination = 'C:\Windows\Temp\fvest\AppWriterInstallFolder'
$logFileLocation = "C:\FGUScripts\Logs\AppWriterUpdater"


if ((Test-Path -Path $destination) -ne $true) {
    [void](New-Item -Path $destination -ItemType "directory")
}

if ((Test-Path -Path $logFileLocation) -ne $true) {
    [void](New-Item -Path $logFileLocation -ItemType "directory")
}


function Add-Log($msg)
{
    $currentDate = Get-Date -Format "dd/MM/yyyy"
    $currentTime = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss:fff K"
    $msgTime = "[$($currentTime)]"
    $formattedMsg = "$($msgTime) - $($msg)"
    
    Write-Host $formattedMsg

    Add-Content "$($logFileLocation)\Log-$($currentDate).log" "$($formattedMsg)"
}


function GetVersion
{
    Add-Log -msg "Checking Appwriter remote version..."

    $download = Invoke-WebRequest $source -Method Head -UseBasicParsing
    $content = [System.Net.Mime.ContentDisposition]::new($download.Headers["Content-Disposition"])
    $fileName = $content.FileName
    Add-Log -msg "Got a response, remote file is $($fileName)"


    $version = [regex]::Matches($fileName, "(?'version'\d+.\d+.\d+)").value
    return $version
}


function GetVersionInstalled
{
    Add-Log -msg "Looking for Appwriter on the machine..."
    $AppExists = (Get-CimInstance -ClassName Win32_product | where-object {$_.Name -like "*AppWriter*"} | Select-Object name,Version)
    
    return $AppExists.version
}


function Download
{
    Add-Log -msg "Downloading current version"

    $success = $true
    try { 
        $download = Invoke-WebRequest $source -UseBasicParsing
        $content = [System.Net.Mime.ContentDisposition]::new($download.Headers["Content-Disposition"])
        $fileName = $content.FileName
    
    
        $file = [System.IO.FileStream]::new("$($destination)\$($fileName)", [System.IO.FileMode]::Create)
        $file.Write($download.Content, 0, $download.RawContentLength)
        $file.Close()

        Add-Log -msg "Done - $($fileName)"
    }
    catch {
        $success = $false
        Add-Log -msg "Error happend while downloading Appwriter"
        Add-Log -msg "$($Error[0])"
    }

    $returnValue = @{}
    $returnValue.add("success", $success)
    $returnValue.add("fileName", $fileName)

    return $returnValue
}

function Install($file)
{
    $success = $true
    try {
        Add-Log -msg "Trying to install..."
        $arguments = "/I $($destination)\$($file) /qn"
        Start-Process msiexec.exe -ArgumentList $arguments -Wait
    }
    catch {
        $success = $false
        Add-Log -msg "Error happend while installing Appwriter"
        Add-Log -msg "$($Error[0])"
    }
    Add-Log -msg "Done installing"


    $returnValue = @{}
    $returnValue.add("success", $success)

    return $returnValue

}

function RemoveStartup
{
    Add-Log -msg "Removeing registry key so it wont startup automagicly"
    Get-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" | Remove-ItemProperty -Name "AppWriter"
}


Add-Log -msg "------Starting script-------"
$remoteVersion = $(GetVersion)
$installedVersion = $(GetVersionInstalled)

Add-Log -msg "Comparing installed version against remote versions"
if($remoteVersion -ne $installedVersion)
{
    Add-Log -msg "Should download and install"
    $downloadReturn = $(Download)

    if($downloadReturn["success"] -eq $true)
    {
        Add-Log -msg "Download worked, can install now"
        $installReturn = $(Install -file $downloadReturn["fileName"])

        if($installReturn["success"] -eq $true)
        {
            $(RemoveStartup)
        }
    }
}
else
{
    Add-Log -msg "latest version is already installed"
}