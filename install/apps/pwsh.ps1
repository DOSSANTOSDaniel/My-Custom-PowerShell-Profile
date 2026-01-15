function Install-pwsh {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de pwsh 7..."

    winget install --id Microsoft.PowerShell --silent `
        --accept-source-agreements `
        --accept-package-agreements
    
    if ( -not $(Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force
    }
}
