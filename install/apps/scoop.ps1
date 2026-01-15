function Install-scoop {
    [CmdletBinding()]
    param ()

    $ScoopRoot = "$env:USERPROFILE\scoop"
    $ScoopShim = "$ScoopRoot\shims\scoop.cmd"

    Write-Host "Installation de Scoop (mode utilisateur)..." -ForegroundColor Cyan

    try {
        # Politique d'exécution temporaire
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

        # Forcer TLS 1.2 (sécurité / compatibilité)
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Installation officielle Scoop
        Invoke-WebRequest -UseBasicParsing -Uri "https://get.scoop.sh" |
            Invoke-Expression

        # Attente réelle (max 30s)
        $timeout = 30
        while ($timeout-- -gt 0) {
            if (Test-Path $ScoopShim) {
                Write-Host "Scoop installé avec succès." -ForegroundColor Green

                scoop update
                scoop bucket add extras
                
                return $true
            }
            Start-Sleep -Seconds 1
        }

        Write-Error "Installation terminée mais Scoop introuvable."
        return $false
    }
    catch {
        Write-Error "Erreur lors de l'installation de Scoop : $_"
        return $false
    }
}