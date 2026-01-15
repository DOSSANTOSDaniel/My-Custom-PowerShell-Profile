

function Install-nmap {
    [CmdletBinding()]
    param ()

    if (-not $IsAdmin) {
        Write-Host "Relance dans Windows Terminal (admin)..." -ForegroundColor Cyan
        $command = "pwsh -NoExit -Interactive -NoLogo -Command `". $PROFILE && Clear-Host && Install-nmap`""

        Start-Process wt.exe -ArgumentList $command -Verb RunAs -ErrorAction Stop
        
        return
    }

    Write-Host "Installation de nmap..." -ForegroundColor Yellow

    choco install nmap -y --ignore-checksums

    # Refresh environment variables
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
    refreshenv

    Write-Host "✔ nmap prêt à l’emploi." -ForegroundColor Green
}
