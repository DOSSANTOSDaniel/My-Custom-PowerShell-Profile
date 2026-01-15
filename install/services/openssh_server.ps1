# Mise en place du serveur OpenSSH
function Install-sshd {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de OpenSSH Server..." -ForegroundColor Yellow

    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    # Non officiel : winget install Microsoft.OpenSSH.Preview
    
    $service = Test-ServiceInstall -ServiceName sshd

    if ($service.Running -eq $false) {
        Start-Service sshd
        Set-Service -Name sshd -StartupType 'Automatic'
    }

    Add-FirewallInboundRule -Name "OpenSSH Server (sshd)" -Port 22 -Protocol "TCP"

    $keyPath = "$env:USERPROFILE\.ssh\id_ed25519"

    if (-not (Test-Path $keyPath)) {
        ssh-keygen -t ed25519 -f $keyPath -N "" -q
    } else {
        Write-Host "La clé SSH existe déjà à l'emplacement $keyPath" -ForegroundColor Green 
        Write-Host "Clé SSH générée avec succès." -ForegroundColor Green
    }
}