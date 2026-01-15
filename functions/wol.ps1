# Réveille les machines via Wake On Lan
function Send-WoL {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MacAddress,
        [string]$Broadcast = "255.255.255.255",
        [int]$Port = 9
    )

    # Nettoyer l'adresse MAC
    $mac = $MacAddress -replace "[:\-]", ""
    if ($mac.Length -ne 12) {
        throw "Adresse MAC invalide : $MacAddress"
    }

    # Convertir en bytes
    $bytes = for ($i = 0; $i -lt 12; $i += 2) {
        [Convert]::ToByte($mac.Substring($i, 2), 16)
    }

    # Magic packet
    $packet = [byte[]](, 0xFF * 6 + ($bytes * 16))

    # Envoi en UDP
    $udp = New-Object System.Net.Sockets.UdpClient
    $udp.Connect($Broadcast, $Port)
    [void]$udp.Send($packet, $packet.Length)
    $udp.Close()

    Write-Host "Magic Packet envoyé à $MacAddress via $Broadcast"
}

# Les différentes machines a réveiller
function wol_proxmox {
    Send-WoL -MacAddress "$env:MAC_PROXMOX"
    Write-Host "Proxmox réveillé !" -ForegroundColor Cyan
}

function wol_nextcloud {
    Send-WoL -MacAddress "$env:MAC_NEXTCLOUD"
    Write-Host "Nextcloud réveillé !" -ForegroundColor Green
}
