# Installation des dépendances du projet
if ($IsAdmin) {
    Write-Host "Ce script doit être exécuté en tant que simple utilisateur. Veuillez relancer PowerShell en tant qu'utilisateur et pas administrateur et réessayer." -ForegroundColor Red
    exit 1
}

# Application a installer
$AllApps = @(
    "winget",
    "choco",
    "scoop",
    "git",
    "pwsh",
    "wt",
    "7z",
    "ssh",
    "upterm",
    "miniserve",
    "rustdesk",
    "gdu",
    "nmap"
)

foreach ($AppName in $AllApps) {
    $result = Test-AppInstalled -AppName "$AppName"

    if ($result.Installed) {
        Write-Host "Application '$AppName' trouvée" -ForegroundColor Green
        Write-Host "Chemin : $($result.Path)"
        Write-Host "Nom    : $($result.Name)"
        Start-Sleep -Seconds 1
    } else {
        Write-Host "Application '$AppName' non installée" -ForegroundColor Red
        Write-Host "Installation requise"
        # Appeler la fonction d'installation spécifique à l'application
        $installFunction = "Install-$AppName"
        if (Get-Command -Name $installFunction -ErrorAction SilentlyContinue) {
            & $installFunction
        } else {
            Write-Host "Fonction d'installation '$installFunction' non trouvée." -ForegroundColor Yellow
        }
    }

}

# Serveur a installer
$AllServices = @(
    "sshd"
)

foreach ($ServiceName in $AllServices) {

    $service = Test-ServiceInstall -ServiceName "$ServiceName"

    if ($service.Exists) {
        if ($service.Running) {
            if ($service.StartType -ne 'Automatic') {
                Set-Service -Name $ServiceName -StartupType Automatic
                Write-Host "Service '$ServiceName' configuré pour démarrer automatiquement." -ForegroundColor Green
            }
            Write-Host "Service '$ServiceName' est en cours d'exécution." -ForegroundColor Green
        } else {
            Write-Host "Service '$ServiceName' n'est pas en cours d'exécution. Démarrage du service..." -ForegroundColor Yellow
            Start-Service -Name $ServiceName
            Set-Service -Name $ServiceName -StartupType Automatic
            Write-Host "Service '$ServiceName' démarré." -ForegroundColor Green
        }
    } else {
        Write-Host "Service '$ServiceName' non trouvé." -ForegroundColor Red
        Install-$ServiceName
        # Re-vérifier l'état du service après l'installation
        $service = Test-ServiceInstall -ServiceName "$ServiceName"
        if ($service.Exists) {
            if ($service.Running) {
                if ($service.StartType -ne 'Automatic') {
                    Set-Service -Name $ServiceName -StartupType Automatic
                    Write-Host "Service '$ServiceName' configuré pour démarrer automatiquement." -ForegroundColor Green
                }
                Write-Host "Service '$ServiceName' est en cours d'exécution." -ForegroundColor Green
            } else {
                Write-Host "Service '$ServiceName' n'est pas en cours d'exécution. Démarrage du service..." -ForegroundColor Yellow
                Start-Service -Name $ServiceName
                Set-Service -Name $ServiceName -StartupType Automatic
                Write-Host "Service '$ServiceName' démarré." -ForegroundColor Green
            }
        } else {
            Write-Host "Échec de l'installation du service '$ServiceName'." -ForegroundColor Red
        }
    }
}


Write-Host "Fin du script d'installation et configuration des dépendances !" -ForegroundColor Green
