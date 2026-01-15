# Nettoyage rapide et sans danger du système
function quick_clean {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param()
    
    Write-Host "Vidage du cache DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    
    Write-Host "Nettoyage des fichiers temporaires..." -ForegroundColor Yellow
	
    $tempPaths = @(
        $env:TEMP,
        "$env:SystemRoot\Temp",
        "$env:LOCALAPPDATA\Temp",
        [System.IO.Path]::GetTempPath()
    ) | Where-Object { Test-Path $_ }
    
    foreach ($path in $tempPaths) {
        if ($PSCmdlet.ShouldProcess($path, "Nettoyer les fichiers temporaires")) {
            Write-Host "  Nettoyage de $path" -ForegroundColor Gray
            try {
                Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue | 
                Where-Object { -not $_.PSIsContainer -or $_.LastWriteTime -lt (Get-Date).AddDays(-2) } |
                Remove-Item -Force -ErrorAction SilentlyContinue
            }
            catch {
                Write-Host "  Certains fichiers ne peuvent être supprimés: $_" -ForegroundColor DarkYellow
            }
        }
    }
	
    # Nettoyage de la corbeille
    Write-Host "Vidage de la corbeille..." -ForegroundColor Yellow
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    #Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue
	
    # Purge des caches Windows Update
    Write-Host "Nettoyage cache Windows Update..." -ForegroundColor Yellow
    try {
        $service = Get-Service wuauserv -ErrorAction SilentlyContinue
        if ($service.Status -eq 'Running') {
            #Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
            Write-Warning "Nettoyage Impossible : le service Windows Update est en cours d'exécution."
            return
        }
        
        $downloadPath = "C:\Windows\SoftwareDistribution\Download"
        if (Test-Path $downloadPath) {
            Get-ChildItem $downloadPath -Force -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
        
        Start-Service wuauserv -ErrorAction SilentlyContinue
        Write-Host "✓ Cache Windows Update nettoyé" -ForegroundColor Green
    }
    catch {
        Write-Warning "Échec du nettoyage Windows Update: $_"
    }
    
    # Suppression des anciens fichiers de verrouillage
    Write-Host "Suppression des anciens fichiers de verrouillage..." -ForegroundColor Yellow
    
    foreach ($pattern in "pwsh_voice_*.lock", "pwsh_music_*.lock", "updater.log") {
        Get-ChildItem "$ProfileRoot\$pattern" -ErrorAction SilentlyContinue |
        Where-Object LastWriteTime -lt (Get-Date).AddDays(-1) |
        Remove-Item -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Nettoyage terminé !" -ForegroundColor Green
}
