# Définit le prompt personnalisé pour PowerShell
function prompt {
    # Capture de l'état de la commande avant que le prompt ne fasse quoi que ce soit
    $lastCommandFailed = -not $global:?
    $lastCode = $global:LASTEXITCODE

    # Récupération de l'ID de l'historique
    $lastHistory = Get-History -Count 1 -ErrorAction SilentlyContinue
    $currentId = if ($null -ne $lastHistory) { $lastHistory.Id } else { 0 }

    # Récupération du chemin courant
    $currentPath = $PWD.Path

    # Date et heure actuelles
    $timeStamp = Get-Date -Format "HH:mm:ss"
    
    # ANSI codes pour le formatage simple
    $esc = [char]27
    $bold = "$esc[1m"
    $reset = "$esc[0m"

    # Support ANSI 
    $ansiSupported = $Host.UI.SupportsVirtualTerminal -and $env:TERM -ne 'dumb'
    if (-not $ansiSupported) {
        $bold = ""
        $reset = ""
    }

    # Remplacement de C:\Users\<user> par "~" pour l'affichage du dossier courant, comme sur Linux
    $displayPath = $currentPath -replace ([regex]::Escape($HOME)), "~"

    # Raccourcissement du chemin courant si trop long 
    if ($displayPath.Length -gt 60) {
        $leaf = Split-Path $displayPath -Leaf
        $parent = Split-Path (Split-Path $displayPath -Parent) -Leaf

        if ($parent) {
            $displayPath = ".../$parent/$leaf"
        }
        else {
            $displayPath = ".../$leaf"
        }
    }

    # Titre de la fenêtre du terminal dynamique selon élévation et environnement 
    $titlePrefixAd = if ($IsAdmin) { "(ADMIN) " } else { "" }
    $titlePrefixSSH = if ($IsSSH) { "(SSH) " } else { "" }
    $titlePrefixUpterm = if ($IsUpterm) { "(Upterm) " } else { "" }

    $Host.UI.RawUI.WindowTitle = "PS>_ ${titlePrefixAd}${titlePrefixSSH}$titlePrefixUpterm $machineName"

    # Configuration dynamique selon les droits et la session
    switch ($true) {
        ($IsAdmin -and $IsSSH) { 
            $IconAdminStatus = "$IconPromptAdmin"
            $IconSSHStatus = "$IconPromptSSH"
            $uColor = "Red"
        }
        ($IsAdmin) { 
            $IconAdminStatus = "$IconPromptAdmin"
            $IconSSHStatus = ""
            $uColor = "Red"
        }
        ($IsSSH) { 
            $IconAdminStatus = ""
            $IconSSHStatus = "$IconPromptSSH"
            $uColor = "Green" 
        }
        default { 
            $IconAdminStatus = ""
            $IconSSHStatus = ""
            $uColor = "Green"
        }
    }

    # Logique de détermination du statut
    # Si l'ID est le même que la dernière fois, l'utilisateur a juste fait <Entrée>
    if ($currentId -eq $global:lastProcessedId) {
        $statusDisplay = "✨"
    }
    # Sinon, on vérifie si la nouvelle commande a échoué
    elseif ($lastCommandFailed) {
        # Si on a un code de sortie d'une commande externe, on l'affiche
        if ($lastCode -ne 0) {
            $statusDisplay = "💥$lastCode"
        }
        else {
            $statusDisplay = "💥"
        }

        # Son de notification
        Show-Music-Popup "$wav_noti"
    }
    else {
        $statusDisplay = "✨"
    }

    # On mémorise l'ID pour le prochain passage
    $global:lastProcessedId = $currentId
    
    # Couleur dynamique pour le nom de la machine
    $dColor = Get-Random -Min 1 -Max 16

    # Construction du prompt
    "`n" | Write-Host -NoNewLine
    Write-Host "╭──(" -NoNewLine -ForegroundColor Blue
    Write-Host "${bold}$userName${reset}" -NoNewLine -ForegroundColor $uColor 
    Write-Host "$IconPromptUser" -NoNewLine
    Write-Host "${bold}$machineName${reset}" -NoNewLine -ForegroundColor $dColor
    Write-Host ")-(" -NoNewLine -ForegroundColor Blue
    Write-Host "$IconSSHStatus$timeStamp" -NoNewline -ForegroundColor Gray
    Write-Host "$statusDisplay" -NoNewLine -ForegroundColor DarkYellow
    Write-Host ")-[" -NoNewLine -ForegroundColor Blue
    Write-Host "${bold}$displayPath${reset}" -NoNewLine -ForegroundColor White
    Write-Host "]" -ForegroundColor Blue
    Write-Host "╰─" -NoNewLine -ForegroundColor Blue
    Write-Host "${bold}PS${IconAdminStatus}${reset}" -NoNewLine -ForegroundColor DarkBlue
    Write-Host "${bold}▶${reset} " -NoNewLine -ForegroundColor Blue

    return " "  # Nécessaire pour que le prompt fonctionne correctement 
}