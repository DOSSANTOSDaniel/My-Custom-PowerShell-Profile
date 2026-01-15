# Partage d'arborescence de fichiers et dossiers LAN, (Miniserve) et WAN tunnel (serveo.net, tunnl.gg, localhost.run)
function files_srv_web_wan {
    [CmdletBinding()]
    param(
        [string[]]$Servers = @(
            "ssh.localhost.run",
            "serveo.net",
            "proxy.tunnl.gg"
        )
    )

    $serverOK = $null

    if (-not (Assert-AppInstalled -Apps @("ssh", "miniserve"))) {
        return
    }

    $port_host = 8088
    $dir_host = $PWD.Path
    $user_host = $env:USERNAME
    $pc_host = $env:COMPUTERNAME

    foreach ($srv in $Servers) {
        Write-Host "Test SSH : $srv..." -ForegroundColor DarkCyan

        try {
            if (Test-NetConnection -ComputerName $srv -Port 22 -InformationLevel Quiet) {
                $serverOK = $srv
                Write-Host "$srv accessible !" -ForegroundColor Green
                break
            }
            else {
                Write-Host "$srv non accessible" -ForegroundColor DarkRed
            }
        }
        catch {
            Write-Host "Erreur lors du test de $srv" -ForegroundColor DarkRed
        }
    }

    if (-not $serverOK) {
        Write-Error "Aucun serveur de tunnel SSH accessible. Abandon."
        return
    }

    Write-Host "`n▶ Démarrage de miniserve..." -ForegroundColor Cyan

    # Construction propre des arguments
    $arguments = @(
        "--verbose",
        "--port $port_host",
        "--qrcode",
        "--upload-files",
        "--mkdir",
        "--hidden",
        "--on-duplicate-files rename",
        "--enable-tar-gz",
        "--show-wget-footer",
        "--title `"$user_host@$pc_host ($PID)`"",
        "--show-symlink-info",
        "`"$dir_host`""
    ) -join " "

    $miniserveJob = Start-Process miniserve `
        -ArgumentList $arguments `
        -PassThru `
        -NoNewWindow

    Start-Sleep -Seconds 2

    Write-Host "▶ Tunnel $serverOK actif :" -ForegroundColor Cyan
    Write-Host "   Ctrl+C pour arrêter" -ForegroundColor DarkGray
    Write-Host ""

    try {
        ssh -R 80:127.0.0.1:$port_host $serverOK
    }
    catch {
        Write-Error "Erreur lors de l'établissement du tunnel : $_"
    }
    finally {
        Write-Host "`n Arrêt du serveur HTTP..." -ForegroundColor Yellow
        if ($miniserveJob -and !$miniserveJob.HasExited) {
            Stop-Process -Id $miniserveJob.Id -Force
        }
    }
}
