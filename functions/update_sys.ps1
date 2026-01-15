# Mise à jour du système (Windows, Chocolatey, Winget, Scoop)
function update_sys_apps {
    [CmdletBinding()]
    param()

    if (-not (Assert-AppInstalled -Apps @("winget", "pwsh", "choco", "scoop")) ) {
        return
    }

    if (-not $IsAdmin) {
        Write-Host "Cette fonction nécessite d'exécuter PowerShell en tant qu'administrateur." -ForegroundColor Red
        Write-Host "Démarrage d'un nouveau shell admin..." -ForegroundColor Green
        Start-Sleep -Seconds 5
        Start-Process wt.exe -ArgumentList 'pwsh -NoExit -Interactive -NoLogo -Command ". $PROFILE && Clear-Host && maj"' -Verb RunAs
        exit
        return
    }

    Write-Host "=== Mise à jour du système ===" -ForegroundColor Cyan

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installation du module PSWindowsUpdate..." -ForegroundColor Yellow
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    }

    Import-Module PSWindowsUpdate

    Write-Host "Mise à jour via Windows Update..." -ForegroundColor Green
    Install-WindowsUpdate -AcceptAll -Install -AutoReboot

    Write-Host "Mise à jour avec winget..." -ForegroundColor Green
    winget source update
    winget upgrade --all --include-unknown

    Write-Host "Mise à jour avec Chocolatey..." -ForegroundColor Green
    choco upgrade all -y --ignore-checksums --yes

    Write-Host "Mise à jour avec Scoop..." -ForegroundColor Green
    scoop update
    scoop update *
    scoop cleanup *

    Write-Host "=== Mise à jour terminée ===" -ForegroundColor Cyan
}
