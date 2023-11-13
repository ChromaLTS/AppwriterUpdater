# AppwriterUpdater

Kort forklaring af hvordan scriptet fungere

install.ps1 installere scriptet.
Den copiere filen UpdateAppwriter.ps1 til en mappe C:\FGUScripts
Derefter opretter den en Opgave i OpgaverStyring også kendst som TaskScheduler som kører scriptet ved hver opstart som system.
Både install.ps1 og UpdateAppwriter.ps1 gemmer logs i C:\FGUScripts\logs


Hvis man skal pakke scriptet til en Intunewin fil så skal man vælge hele mappen AppwriterUpdater og vælge start script til install.ps1

Når man skal oprette pakken i intune har jeg fundet at det vigtigt at sikre at intune sender pakken rigtigt og stabilt.
Den måde jeg har gjort det på er:
    Først at lave en .txt fil med install.ps1 scriptet når den bliver installeret med versionsnr i navnet, ud fra dette variable - $Version = "1.0.0.3"

og derefter at oprette 2 detection rules når man opretter pakken. Se billede (1).
    Den første der tjekker om UpdateAppwriter.ps1 er kopieret rigtigt over.
    Den anden om den har fået den nyeste version.

    Textfilen kommer til at se sådan her ud - UpdateAppwriter.ps1-1.0.0.3.txt


Detection rules:

Nr.1 
Path -------------- C:\FGUScripts
File or folder ---- UpdateAppwriter.ps1
Detection method -- File or folder exists
Se billede (2)

Nr.2
Path -------------- C:\FGUScripts\version
File or folder ---- UpdateAppwriter.ps1-1.0.0.3.txt
Detection method -- File or folder exists
Se billede (3)
