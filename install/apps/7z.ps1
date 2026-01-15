function Install-7z {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de 7-Zip..."

    winget install --id 7zip.7zip --silent `
        --accept-source-agreements `
        --accept-package-agreements
}
