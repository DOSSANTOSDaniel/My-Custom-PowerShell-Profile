function Install-RustDesk {
    [CmdletBinding()]
    param ()

    if (-not $IsAdmin) {
        Write-Host "Relance dans Windows Terminal (admin)..." -ForegroundColor Cyan
        $command = "pwsh -NoExit -Interactive -NoLogo -Command `". $PROFILE && Clear-Host && Install-RustDesk`""

        Start-Process wt.exe -ArgumentList $command -Verb RunAs -ErrorAction Stop
        
        return
    }

    Write-Host "Installation de RustDesk..." -ForegroundColor Yellow

    choco install rustdesk -y --ignore-checksums

    $rustdeskPath = "C:\Program Files\RustDesk"

    if ($env:Path -notlike "*$rustdeskPath*") {
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$env:Path;$rustdeskPath",
            [EnvironmentVariableTarget]::User
        )
        Write-Host "✔ RustDesk ajouté au PATH utilisateur." -ForegroundColor Green
    }

    # Refresh environment variables
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
    refreshenv

    # Ajouter une règle de pare-feu pour RustDesk
    Add-FirewallRuleApp -DisplayName "RustDesk" -AppPath "$rustdeskPath\rustdesk.exe"

    Write-Host "✔ RustDesk prêt à l’emploi." -ForegroundColor Green
}
