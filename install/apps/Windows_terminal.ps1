function Install-wt {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de Windows Terminal..." -ForegroundColor Yellow

    winget install --id Microsoft.WindowsTerminal `
        --silent `
        --accept-source-agreements `
        --accept-package-agreements
}

