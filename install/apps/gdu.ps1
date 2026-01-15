function Install-gdu {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de GDU..." -ForegroundColor Yellow
    
    scoop update
    scoop install gdu
}