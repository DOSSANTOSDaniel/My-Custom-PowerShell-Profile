# Vérifie si une application est installée sur le système.
function Assert-AppInstalled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Apps,

        [string]$Hint = "Lance l'alias installps pour installer les dépendances manquantes."
    )

    foreach ($app in $Apps) {
        $result = Test-AppInstalled -AppName $app

        if (-not $result.Installed) {
            Write-Host "❌ L'application '$app' n'est pas installée." -ForegroundColor Red
            Write-Host $Hint -ForegroundColor Yellow
            return $false
        }
    }

    return $true
}