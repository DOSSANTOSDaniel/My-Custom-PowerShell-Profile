# Teste la disponibilité des machines avant d'initier une connexion SSH
function CheckHostAvailability {
    [CmdletBinding()]    
    param(
        [string]$CheckHostName,
        [int]$CheckPort,
        [int]$TimeoutMs = 2000
    )

    if (-not (Assert-AppInstalled -Apps "ssh")) {
        return
    }

    Write-Host "Test de disponibilité de $CheckHostName : $CheckPort !" -ForegroundColor Yellow

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $async = $client.BeginConnect($CheckHostName, $CheckPort, $null, $null)
        $wait = $async.AsyncWaitHandle.WaitOne($TimeoutMs)

        if (-not $wait) {
            Write-Host "✖ $CheckHostName est injoignable (timeout $TimeoutMs ms)." -ForegroundColor Red
            return $false
        }

        $client.EndConnect($async)
        $client.Close()

        Write-Host "✔ $CheckHostName est joignable sur le port $CheckPort." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✖ $CheckHostName est injoignable (erreur de connexion)." -ForegroundColor Red
        return $false
    }
}

## Connexions SSH
function Connect-MySSH {
    [CmdletBinding()]
    param($User, $IP, $Port = 22)

    if (CheckHostAvailability -CheckHostName $IP -CheckPort $Port) {
        Write-Host "Connexion à $User@$IP sur le port $Port !" -ForegroundColor Cyan
        ssh -t `
            -p $Port `
            -o ConnectTimeout=5 `
            -o ServerAliveInterval=60 `
            -o ServerAliveCountMax=3 `
            "$User@$IP"
    }
}

# Mes différentes connexions
function ssh_proxmox { Connect-MySSH -User "daniel" -IP "192.168.1.21" }
function ssh_nextcloud { Connect-MySSH -User "daniel" -IP "192.168.1.112" }
function ssh_tortue { Connect-MySSH -User "daniel" -IP "192.168.1.85" -Port "$env:TORTUE_SSH_PORT" }
function ssh_pcduino { Connect-MySSH -User "daniel" -IP "192.168.1.31" }
function ssh_win_laptop { Connect-MySSH -User "daniel" -IP "192.168.1.37" }
function ssh_win_desktop { Connect-MySSH -User "daniel" -IP "192.168.1.22" }
function ssh_fedora { Connect-MySSH -User "daniel" -IP "192.168.1.67" }
function ssh_mint { Connect-MySSH -User "daniel" -IP "192.168.1.37" }