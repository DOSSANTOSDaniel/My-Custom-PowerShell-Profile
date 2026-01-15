# Partage d'arborescence de fichiers et dossiers LAN, (Miniserve)
function files_srv_web_lan {
    [CmdletBinding()]
    param(
        [int]$Port = 8088
    )

    if (-not (Assert-AppInstalled -Apps "miniserve")) {
        return
    }

    $dir_host = $PWD.Path
    $user_name = $env:USERNAME
    $host_name = $env:COMPUTERNAME

    Write-Host "`n▶ Serveur HTTP LAN (miniserve)" -ForegroundColor Cyan
    Write-Host "Dossier : $dir_host" -ForegroundColor DarkGray
    Write-Host "Arrêt   : Ctrl+C" -ForegroundColor DarkGray
    Write-Host ""

    miniserve `
        --verbose `
        --interfaces 0.0.0.0 `
        --port $Port `
        --qrcode `
        --upload-files `
        --mkdir `
        --hidden `
        --on-duplicate-files rename `
        --enable-tar-gz `
        --show-wget-footer `
        --title "$user_name@$host_name ($PID)" `
        --show-symlink-info `
        "$dir_host"
}
