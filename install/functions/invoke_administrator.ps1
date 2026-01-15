# Démarre script et commandes en mode administrateur
function Invoke-Elevated {
    param (
        [Parameter(Mandatory)]
        [ScriptBlock]$Script
    )

    Start-Process powershell `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & { $Script }"
}
