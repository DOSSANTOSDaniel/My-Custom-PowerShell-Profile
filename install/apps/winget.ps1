function Install-winget {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de winget..." -ForegroundColor Yellow

    $url = "https://aka.ms/getwinget"
    $file = "$env:TEMP\AppInstaller.msixbundle"

    Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing

    Add-AppxPackage -Path $file
    Remove-Item -Path $file
    
    Write-Host "Mise à jour de winget et des applications installées..." -ForegroundColor Yellow
    winget source update
    winget upgrade --all --include-unknown
    Write-Host "Installation de winget terminée." -ForegroundColor Green
}

