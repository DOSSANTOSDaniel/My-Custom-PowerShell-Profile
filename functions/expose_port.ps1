function Open-Port {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$LocalPort,

        [string[]]$Servers = @(
            "ssh.localhost.run",
            "serveo.net",
            "proxy.tunnl.gg"
        )
    )

    $serverOK = $null

    Write-Host "`n🔍 Vérification du port local $LocalPort ..." -ForegroundColor Cyan

    if (-not (Get-NetTCPConnection -LocalPort $LocalPort -State Listen -ErrorAction SilentlyContinue)) {
        Write-Error "Aucun service n'écoute sur le port local $LocalPort."
        return
    }

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

    Write-Host "`n📡 Tunnel actif sur $serverOK !"
    Write-Host " - Port local  : $LocalPort"
    Write-Host " - Port remote : 80"
    Write-Host "`n ⏹️ CTRL+C pour fermer le tunnel`n" -ForegroundColor Yellow

    try {
        ssh -t -R 80:127.0.0.1:$LocalPort $serverOK
    }
    catch {
        Write-Error "Erreur lors de l'établissement du tunnel : $_"
    }
}