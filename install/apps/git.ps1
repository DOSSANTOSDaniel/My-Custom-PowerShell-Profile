function Install-git {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de Git via Winget..." -ForegroundColor Cyan

    try {
        winget install --id Git.Git -e --source winget `
            --accept-package-agreements `
            --accept-source-agreements

        # Recharger le PATH (user + machine)
        $env:PATH = `
            [Environment]::GetEnvironmentVariable("PATH","User") + ";" +
            [Environment]::GetEnvironmentVariable("PATH","Machine")

        if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host "Git installé avec succès." -ForegroundColor Green
            return $true
        }

        Write-Error "Git installé mais PATH non rechargé (redémarrage du shell requis)."
        return $false
    }
    catch {
        Write-Error "Erreur lors de l'installation de Git : $_"
        return $false
    }
}