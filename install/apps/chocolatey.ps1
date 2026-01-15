function Install-choco {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de Chocolatey..." -ForegroundColor Yellow

    Set-ExecutionPolicy Bypass -Scope Process -Force

    [System.Net.ServicePointManager]::SecurityProtocol =
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    Invoke-Expression (
        (New-Object System.Net.WebClient).DownloadString(
            'https://community.chocolatey.org/install.ps1'
        )
    )

    choco upgrade all -y --ignore-checksums --yes
    Write-Host "Installation de Chocolatey terminée." -ForegroundColor Green
}
