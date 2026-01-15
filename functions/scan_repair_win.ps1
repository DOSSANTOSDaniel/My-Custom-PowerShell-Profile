# Réparation automatisée de l’intégrité Windows (DISM + SFC)
function Repair-SystemFiles {
    [CmdletBinding()]
    param()

    if ($IsSSH) {
        Write-Host "Élévation impossible dans une session SSH." -ForegroundColor Red
        return
    }

    if (-not $IsAdmin) { 
        Write-Host "Cette fonction nécessite PowerShell en administrateur." -ForegroundColor Yellow
        Write-Host "Démarrage d'un nouveau shell admin..." -ForegroundColor Green
        Start-Sleep -Seconds 2

        $commands = @(
            '. $PROFILE'
            'Clear-Host'
            'Repair-SystemFiles'
        )

        $fullCommand = $commands -join "`n"

        Start-Process wt.exe `
            -Verb RunAs `
            -PassThru `
            -ErrorAction Stop `
            -ArgumentList @(
            'new-tab'
            '--focus'
            '--tabColor', '#ec5587ff'
            'pwsh'
            '-NoLogo'
            '-NoExit'
            '-Interactive'
            '-ExecutionPolicy', 'Bypass'
            '-Command', $fullCommand
        )
    }
    else {
        try {
            Write-Host "`n Analyse de la santé de l'image (DISM)..." -ForegroundColor Cyan
            dism /online /cleanup-image /scanhealth

            Write-Host "`n Réparation de l'image système..." -ForegroundColor Cyan
            dism /online /cleanup-image /restorehealth
        
            Write-Host "`n SFC scannow en cours..." -ForegroundColor Cyan
            sfc /scannow

            $exitCode = $LASTEXITCODE
            switch ($exitCode) {
                0 { Write-Host "Aucun fichier corrompu détecté." -ForegroundColor Green }
                1 { Write-Host "Fichiers corrompus réparés." -ForegroundColor Yellow }
                2 { Write-Host "❌ Fichiers corrompus NON réparables." -ForegroundColor Red }
                default { Write-Host "⚠️ Erreur SFC (code $code)" -ForegroundColor Red }
            }
        }
        catch {
            Write-Error "❌ Une erreur critique est survenue : $($_.Exception.Message)"
        }
    }
}