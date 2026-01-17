# Si connexion SSH ou non interactif alors exit
if (-not $Host.UI -or -not $Host.UI.RawUI) {
    return
}

# Si interactif
$Host.UI.RawUI.WindowTitle = "PS>_ $env:COMPUTERNAME"

# Variables globales
$ProfileRoot = Split-Path -Parent $PROFILE

# Fichier de log pour la synchronisation avec git
$LogFile = Join-Path $ProfileRoot "updater.log"

# Si le profil n'existe pas, on arrête tout
if (-not (Test-Path $ProfileRoot)) { return }

# Besoin pour l'utilisation de get-history
if (-not (Get-Module PSReadLine) -and (Get-Module -ListAvailable PSReadLine)) {
    Import-Module PSReadLine
}

# Chargement des modules
$ModulePaths = @(
    "$ProfileRoot/functions",
    "$ProfileRoot/alias",
    "$ProfileRoot/core",
    "$ProfileRoot/install/functions",
    "$ProfileRoot/install/apps",
    "$ProfileRoot/install/services"
)

foreach ($path in $ModulePaths) {
    if (Test-Path $path) {
        Get-ChildItem $path -Filter '*.ps1' -File | ForEach-Object {
            . $_.FullName
        }
    }
}

# Charger les secrets
Import-Secrets

# Informations utilisateur et machine
$userName = [System.Environment]::UserName
$machineName = [System.Environment]::MachineName

$IsSSH = $env:SSH_CONNECTION -or $env:SSH_CLIENT -or $env:SSH_TTY

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

$IsUpterm = $env:UPTERM_ADMIN_SOCKET

# Sélection aléatoire parmi une liste d'icônes
$allIconsPrompts = @('💎'; '🥊'; '💾'; '🍄'; '🍌'; '🔥'; '🪐'; '🏴‍☠️'; '👽'; '👻'; '💩'; '🐧'; '🎃'; '💊'; '🍬'; '🍭'; '🥝'; '🍍'; '🍓'; '🥜'; '🌵'; '🍀'; '🍁'; '🚀'; '🎈')
$IconPromptUser = $allIconsPrompts[(Get-Random -min 0 -max ($allIconsPrompts.Length))]
# Icône SSH
$IconPromptSSH = "📡"
# Utilise des icônes et des couleurs dynamiques selon les droits et la session
# Icône administrateur
$IconPromptAdmin = "⚡"

# Version de PowerShell
$PSVersion = $PSVersionTable.PSVersion.ToString()

# Chemin vers le script de mise à jour de ce profile
$Updater = Join-Path $ProfileRoot "scripts\updater.ps1"

# Sons de notification
$wav_Music = "C:\Windows\Media\Ring05.wav"
$wav_noti = "C:\Windows\Media\Windows Proximity Notification.wav"
#$wav_pass = "C:\Windows\Media\tada.wav"

$Today = Get-Date -Format yyyyMMdd
$SessionId = (Get-Process -Id $PID).SessionId
$MusicLock = "$ProfileRoot\pwsh_music_$Today`_S$SessionId.lock"

# Si pas de fichier lock, jouer le son d'introduction (1 fois / jour)
if (-not (Test-Path $MusicLock) -and -not $IsSSH -and (Test-Path $wav_Music)) {
    try {
        $player = [System.Media.SoundPlayer]::new($wav_Music)
        $player.Play()
    }
    catch {}
    New-Item -Path $MusicLock -ItemType File -Force | Out-Null
}

# Synthèse vocale en français, (1 fois / jour)
$VoiceLock = "$ProfileRoot\pwsh_voice_$Today`_S$SessionId.lock"

if (-not (Test-Path $VoiceLock) -and -not $IsSSH) {
    try {
        Add-Type -AssemblyName System.Speech -ErrorAction Stop
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $speak.SelectVoice("Microsoft Hortense Desktop")
        [void]$speak.SpeakAsync("Salut $userName. Bienvenue sur la machine $machineName.")
    }
    catch {}
    New-Item -Path $VoiceLock -ItemType File -Force | Out-Null
}

# Configuration du prompt
# Initialisation par défaut
$global:lastProcessedId = 0  

# Auto-update PROFILE (async)
if (-not (Assert-AppInstalled -Apps "pwsh")) {
    installps
    return
}

# Lance la mise à jour auto si .git exist
$hasUpdater = Test-Path $Updater
$isGitRepo = Test-Path "$ProfileRoot\.git"

if ($hasUpdater -and $isGitRepo) {
    Start-Process "pwsh.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$Updater`"" `
        -WindowStyle Hidden `
        -ErrorAction SilentlyContinue
}

# Chargement des alias groupés
My_Alias_Share_Group
My_Alias_SSH_Group
My_Alias_Tools_Group
My_Alias_Wol_Group

# Début de la configuration de la bannière 
try {
    # Récupération de l'adresse IPv4
    $ip_host = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' } | 
    ForEach-Object { $_.GetIPProperties().UnicastAddresses } | 
    Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' } | 
    Select-Object -ExpandProperty Address | 
    Select-Object -ExpandProperty IPAddressToString -First 1

    # Récupération de l'adresse MAC
    $mac_address = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
    Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' } | 
    Select-Object -First 1 | 
    ForEach-Object { 
        $bytes = $_.GetPhysicalAddress().GetAddressBytes()
        ($bytes | ForEach-Object { $_.ToString("X2") }) -join ":"
    }
}
catch {
    $ip_host = "N/A"
    $mac_address = "N/A"
}

try {
    # Récupération de l'IP publique
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ip_public = (Invoke-RestMethod https://ipinfo.io/ip).Trim()
}
catch {
    $ip_public = "N/A"
}

try {
    # Récupération des informations sur le stockage disque
    $disk_free = (Get-PSDrive C).Free
    $disk_used = (Get-PSDrive C).Used

    $disk_free_gb = [math]::Round($disk_free / 1GB, 3)
    $disk_used_gb = [math]::Round($disk_used / 1GB, 3)
}
catch {
    $disk_free_gb = "N/A"
    $disk_used_gb = "N/A"
}	

# Configuration des couleurs
$C_Border = "Cyan"
$C_Title = "Magenta"
$C_Label = "White"
$C_Value = "Green"
$C_Dim = "DarkGray"

# Barres de progression
# Barre de progression stockage
if ($disk_free_gb.ToString() -match '^\d+,*\d*$' -and $disk_used_gb.ToString() -match '^\d+,*\d*$') {
   
    $total = [math]::Round($disk_used_gb + $disk_free_gb, 0)

    $percent = [math]::Round(($disk_used_gb / $total) * 100)
    $barSize = 20
    $filled = [math]::Round($percent / (100 / $barSize))
    
    $bar = ("▓" * $filled).PadRight($barSize, "░")
}
else {
    $bar = "░░▒▒▓▓████"
    $percent = "N/A"
}

# barre de progréssion ready
function FX-ScanBarLight {

    $bar = "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"

    for ($i = 0; $i -lt $bar.Length; $i++) {
        $tmp = $bar.ToCharArray()
        $tmp[$i] = "█"

        # Retour début de ligne
        Write-Host "`r  " -NoNewline

        # Icône magenta
        Write-Host "◣" -NoNewline -ForegroundColor $C_Title

        # Texte + barre en bleu
        Write-Host " READY_ $($tmp -join '')" -NoNewline -ForegroundColor $C_Border

        Start-Sleep -Milliseconds 10
    }
}
# Affichage de la bannière

Show-Banner




