# Ajouter de nouvelles règle de firewall via port ou application
function Add-FirewallRulePort {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$Port,

        [ValidateSet("TCP", "UDP")]
        [string]$Protocol = "TCP",

        [ValidateSet("Inbound", "Outbound")]
        [string]$Direction = "Inbound"
    )

    Write-Host "Ajout règle firewall $Direction : $Name (Port $Port/$Protocol)" -ForegroundColor Yellow

    if (-not (Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue)) {
        Start-Process powershell -Verb RunAs -ArgumentList @(
            '-NoProfile',
            '-Command',
            "New-NetFirewallRule -DisplayName '$Name' -Direction $Direction -Action Allow -Protocol $Protocol -LocalPort $Port -Profile Any"
        )
    }
    else {
        Write-Host "Règle firewall déjà existante : $Name" -ForegroundColor DarkGray
    }
}

function Add-FirewallRuleApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DisplayName,

        [ValidateSet("Inbound", "Outbound")]
        [string]$Direction = "Inbound",

        [Parameter(Mandatory)]
        [string]$AppPath
    )

    if (-not (Test-Path $AppPath)) {
        Write-Host "❌ App introuvable : $AppPath" -ForegroundColor Red
        return
    }

    if (Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue) {
        Write-Host "ℹ Règle firewall déjà existante : $DisplayName" -ForegroundColor DarkGray
        return
    }

    Write-Host "Ajout règle firewall $Direction → $DisplayName" -ForegroundColor Yellow


    Start-Process powershell -Verb RunAs -ArgumentList @(
        '-NoProfile',
        '-Command',
        "New-NetFirewallRule -DisplayName '$DisplayName' -Direction '$Direction' -Action Allow -Program '$AppPath' -Profile Any"
    )
}