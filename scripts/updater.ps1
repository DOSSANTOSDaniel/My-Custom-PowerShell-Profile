# PowerShell PROFILE Git Auto-Updater
# On déclare qu'on peut recevoir un "interrupteur" (switch) ForceUpdate permettant les mises à jours manuelles
param(
    [switch]$ForceUpdate
)

# Détermine le répertoire racine du profil
if ($PSScriptRoot) {
    $ProfileRoot = Split-Path -Parent $PSScriptRoot
}
else {
    $ProfileRoot = Split-Path -Parent $PROFILE
}

# Chargement des modules
$ModulePaths = @(
    "$ProfileRoot/functions",
    "$ProfileRoot/install/functions"
)

foreach ($path in $ModulePaths) {
    if (Test-Path $path) {
        Get-ChildItem $path -Filter '*.ps1' -File | ForEach-Object {
            . $_.FullName
        }
    }
}

$LockFile = Join-Path $ProfileRoot ".update.lock"
$StateFile = Join-Path $ProfileRoot ".last_update"
$Branch = "main"

$LogFile = Join-Path $ProfileRoot "updater.log"

function Log_msg {
    param ([string]$Message)

    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts | $Message" | Out-File $LogFile -Append -Encoding UTF8
}

# Vérifier si git est installé
if (-not (Assert-AppInstalled -Apps "git")) {
    Log_msg "Erreur Git non installé."
    return
}

# Limite : 1 update / jour
if (-not $ForceUpdate) {
    Log_msg "Vérification de la dernière mise à jour."
    if (Test-Path $StateFile) {
        if ((Get-Item $StateFile).LastWriteTime.Date -eq (Get-Date).Date) {
            Log_msg "Le profile est déjà à jour."
            return
        }
    }
    else {
        Log_msg "Démarrage de la mise à jour."
    }
}
else {
    Log_msg "Détection d'une mise à jour forcée."
}

# Création des fichiers lock (PID LOCK)
if (Test-Path $LockFile) {
    $lockPid = Get-Content $LockFile -ErrorAction SilentlyContinue

    if ($lockPid -and (Get-Process -Id $lockPid -ErrorAction SilentlyContinue)) {
        Log_msg "Impossible de continuer, une autre mise à jour est en cours (PID: $lockPid)"
        return
    }
    else {
        Log_msg "Pas de mise à jour en cours PID: $lockPid, démarrage de la mise à jour."
    }

    # Lock mort, nettoyage
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}
else {
    Log_msg "Aucun fichier lock trouvé"
}

# Création du lock
"$PID" | Set-Content $LockFile -Encoding ASCII
Log_msg "Création du fichier lock PID: $PID."

$local = $null
$remote = $null

try {
    Push-Location $ProfileRoot

    # Vérifie la branche active
    Log_msg "Vérification de la branche Git courrante"
    git checkout $Branch --quiet

    # Fetch silencieux
    Log_msg "Fetching latest changes from origin/$Branch."
    git fetch origin $Branch --quiet

    # Compare HEAD local / distant
    $local = git rev-parse HEAD
    $remote = git rev-parse "origin/$Branch"
    Log_msg "Local HEAD: $local"
    Log_msg "Remote HEAD: $remote" 

    if ($local -ne $remote) {
        Write-Host "🔄 Mise à jour du profile..."
        git reset --hard origin/main | Out-Null
    }
    else {
        Log_msg "Le profile est déjà à jour."
    }

    # Mise à jour du StateFile pour limiter 1 update/jour
    Log_msg "Mise à jour du StateFile pour limiter 1 update/jour."
    New-Item $StateFile -ItemType File -Force | Out-Null

}
catch {
    Log_msg "Erreur pendant la mise à jour : $_"
    # silence volontaire
}
finally {
    Log_msg "Suppression du fichier lock."
    Pop-Location
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}

# Résultat final
# Est-ce que, AVANT le pull, il y avait une différence ?
if ($local -and $remote -and $local -ne $remote) {
    Log_msg "Mise à jour réussie !"
    Log_msg "[$(Get-Date)] Profile updated"
    if (-not $IsSSH -and $ForceUpdate) {
        Write-Host "`n---- Dernières entrées du journal de mise à jour ----" -ForegroundColor Cyan
        Get-Content $LogFile -Tail 20
        Pause
        . $PROFILE
    }
    else {
        # Kill tous les Windows Terminal
        Get-Process "WindowsTerminal" -ErrorAction SilentlyContinue | Stop-Process -Force
        Log_msg "Tuer toutes les instances de Windows Terminal."
        Log_msg "[$(Get-Date)] Profile updated"

        # Petite pause pour s'assurer que tous les processus sont fermés
        Start-Sleep -Milliseconds 500

        # Ouvrir une nouvelle fenêtre WT et recharger le profil
        $commands = @(
            '. $PROFILE'
            'Write-Host " "'
            'Write-Host "-- Journal de mise à jour --"'
            'Write-Host " "'
            'Get-Content $LogFile -Tail 20'
        )

        $fullCommand = $commands -join "`n"

        Write-Host "Une mise à jour est nécessaire !"
        pause

        Start-Process wt.exe `
            -Verb RunAs `
            -PassThru `
            -ErrorAction Stop `
            -ArgumentList @(
            'new-tab'
            '--focus'
            'pwsh'
            '-NoLogo'
            '-NoExit'
            '-Interactive'
            '-ExecutionPolicy', 'Bypass'
            '-Command', $fullCommand
        )
    }
}
else {
    Write-Host "🔄 Pas de mise à jour !"
    Log_msg "Pas de mise à jour !."

}


