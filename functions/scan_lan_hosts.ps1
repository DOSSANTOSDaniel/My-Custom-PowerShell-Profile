# Scan des hôtes du réseau LAN
function Get-LANInventory {
    [CmdletBinding()]
    param([string]$Subnet)

    # Détection du sous-réseau
    if (-not $Subnet) {
        # Récupère la route par défaut (IPv4)
        $defaultRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -AddressFamily IPv4 |
        Sort-Object RouteMetric, InterfaceMetric |
        Select-Object -First 1

        # Récupère l'adresse IP associée à cette interface
        $ipInfo = Get-NetIPAddress -AddressFamily IPv4 `
            -InterfaceIndex $defaultRoute.InterfaceIndex `
        | Where-Object { 
            $_.IPAddress -notlike '169.*' -and
            $_.PrefixLength -lt 32 -and 
            $_.InterfaceAlias -notlike '*Loopback*'
        } | Select-Object -First 1

        # Conversion prefixLength en masque
        function ConvertTo-IPv4MaskString {
            param(
                [Parameter(Mandatory = $true)]
                [ValidateRange(0, 32)]
                [int]$MaskBits
            )
            $mask = ([math]::Pow(2, $MaskBits) - 1) * [math]::Pow(2, (32 - $MaskBits))
            $bytes = [BitConverter]::GetBytes([uint32]$mask)
            (($bytes.Count - 1)..0 | ForEach-Object { [string]$bytes[$_] }) -join '.'
        }

        $maskString = ConvertTo-IPv4MaskString -MaskBits $ipInfo.PrefixLength

        # Calcul de l’adresse réseau
        $networkIP = [IPAddress](
            ([IPAddress]$ipInfo.IPAddress).Address -band
            ([IPAddress]$maskString).Address
        )

        $Subnet = "$networkIP/$($ipInfo.PrefixLength)"
    }

    Write-Host "`n Scanne en cours, sur le réseau $Subnet ... `n" -ForegroundColor Green
    
    # Scan Nmap
    [xml]$scan = nmap -sV -O -p 22,80,443 -T4 $Subnet -oX -
    
    # Si aucun hôte détecté
    $hosts = $scan.nmaprun.host
    if (-not $hosts) { 
        Write-Host "`n Aucune machine détectée ! `n" -ForegroundColor Red
        return 
    }
    
    # Table ARP des machines encore valides
    $arpTable = Get-NetNeighbor -AddressFamily IPv4 -State Reachable

    foreach ($hostNode in $hosts) {
        if ($hostNode.status.state -ne 'up') { continue }

        $ip = ($hostNode.address | Where-Object addrtype -eq 'ipv4').addr
        
        # Récupération Hostname via DNS, NetBIOS
        $name = $null
        try { 
            $name = [System.Net.Dns]::GetHostEntry($ip).HostName.Split('.')[0] 
        }
        catch {
            # Secours NetBIOS si DNS échoue
            $nbt = nbtstat -A $ip 2>$null | Select-String '<00>' | Select-Object -First 1
            if ($nbt) { $name = $nbt.ToString().Trim().Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0] }
        }

        # Récupération de la MAC et OS
        $macNode = ($hostNode.address | Where-Object addrtype -eq 'mac')
        $macAddr = if ($macNode) { $macNode.addr } else { ($arpTable | Where-Object IPAddress -eq $ip).LinkLayerAddress }
        $os = ($hostNode.os.osmatch | Select-Object -First 1).name

        # Ports ouverts 22,80,443
        $openPorts = if ($hostNode.ports.port) {
            ($hostNode.ports.port | Where-Object { $_.state.state -eq 'open' } | ForEach-Object { "$($_.portid)/$($_.service.name)" }) -join ", "
        }

        # Affichage pour chaque machine
        [PSCustomObject]@{
            IP       = $ip
            Hostname = if ($name) { $name.ToUpper() } else { "Inconnu" }
            OS       = if ($os) { $os } else { "Inconnu" }
            Ports    = $openPorts
            MAC      = $macAddr
            Vendor   = $macNode.vendor
        }
        Write-Host "`n ==================================================== `n"
    }
}