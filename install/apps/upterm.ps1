function Install-upterm {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de Upterm..." -ForegroundColor Yellow

    scoop bucket add upterm https://github.com/owenthereal/scoop-upterm
    scoop update
    
    scoop install upterm

    Write-Host "Installation de Upterm terminée." -ForegroundColor Green
}

