
function Install-ssh {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de OpenSSH Client..." -ForegroundColor Yellow

    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}