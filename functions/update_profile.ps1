# Lance le script de mise à jour du projet via git en mode manuel
function update_profile {
    Write-Host "🚀 Mise à jour forcée du profil..." -ForegroundColor Cyan
    # On ajoute -ForceUpdate à la fin de la commande
    & "$ProfileRoot\scripts\updater.ps1" -ForceUpdate
}