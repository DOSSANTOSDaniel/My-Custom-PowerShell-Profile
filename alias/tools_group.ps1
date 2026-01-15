function My_Alias_Tools {
    $AliasTools = @{
        maj       = "Mise à jour du système (Windows, Chocolatey, Winget, Scoop)"
        ports     = "Vérifie les ports en écoute"
        task      = "Gestionnaire des tâches"
        pcon      = "Panneau de configuration classique"
        disk      = "Gestion des disques"
        prop      = "Nettoyage et effacement des fichiers temporaires"
        qclean    = "Nettoyage rapide du système"
        chris     = "Utilitaire Chris Titus"
        godm      = "God Mode"
        meteo     = "Météo des trois derniers jours"
        encrf     = "Protection de fichiers par mot de passe aléatoire"
        installps = "Installation des dépendances du profil"
        majps     = "Mise à jour du profil PowerShell"
        rwin      = "Réparation automatisée de l’intégrité Windows (DISM + SFC)"
        rdisk     = "CHKDSK au prochain redémarrage"
        scanip    = "Scan des hôtes du réseau LAN"
        expose    = "Exposer un port sur internet, WAN, (serveo.net, tunnl.gg, localhost.run)"
    }

    Get-Alias |
    Where-Object { $AliasTools.ContainsKey($_.Name) } |
    Select-Object Name,
    @{ Name = 'Description'; Expression = { $AliasTools[$_.Name] } } |
    Format-Table -AutoSize

    # Aide-mémoire des commandes utiles autres que des alias
    $CommandMemo = @{
        gdu     = "Analyser l’utilisation de l’espace disque"
        mrt     = "Microsoft Malicious Software Removal Tool"
        control = "Panneau de configuration classique"
        msinfo  = "Informations système"
        appwiz  = "Désinstaller ou modifier un programme"

        choco   = "Gestionnaire de paquets Chocolatey (search/install/update/uninstall)"
        winget  = "Gestionnaire de paquets Microsoft Winget"
        scoop   = "Gestionnaire de paquets Scoop (sans admin)"
    }


    Write-Host "`n Aide-mémoire des commandes`n" -ForegroundColor Cyan
    # hashtable
    $CommandMemo.GetEnumerator() |
    Sort-Object Name |
    ForEach-Object {
        "{0,-10} {1}" -f $_.Key, $_.Value
    }
}

function My_Alias_Tools_Group {
    # Alias Group
    New-Alias -Name gtools -Value "My_Alias_Tools" -Scope Global -Force

    ## Alias Update
    New-Alias -Name maj -Value "update_sys_apps" -Scope Global -Force
    ## Check open ports
    New-Alias -Name ports -Value "Get-OpenPorts" -Scope Global -Force
    # Gestionnaire des tâches
    New-Alias -Name task -Value "taskmgr.exe" -Scope Global -Force
    # Gestion des disques
    New-Alias -Name disk -Value "diskmgmt.msc" -Scope Global -Force
    # Clean sys
    New-Alias -Name qclean -Value "quick_clean" -Scope Global -Force
    # god_mode
    New-Alias -Name godm -Value "god_mode" -Scope Global -Force
    # chris_titus_win_util
    New-Alias -Name chris -Value "chris_titus_win_util" -Scope Global -Force
    # Météo
    New-Alias -Name meteo -Value "get_meteo" -Scope Global -Force
    # Chiffrement de fichiers
    New-Alias -Name encrf -Value "Protect-File7Zip" -Scope Global -Force
    # Installation des dépendances pour ce profil
    New-Alias -Name installps -Value "install_dep" -Scope Global -Force
    # Mise à jour du profil PowerShell depuis le dépôt Git
    New-Alias -Name majps -Value "update_profile" -Scope Global -Force
    # Analyse et répare l’image Windows et les fichiers système (DISM + SFC).
    New-Alias -Name rwin -Value "Repair-SystemFiles" -Scope Global -Force
    # Diagnostiquer et réparer un disque en planifiant un CHKDSK au prochain redémarrage.
    New-Alias -Name rdisk -Value "Repair-Disk" -Scope Global -Force
    # Scan des hôtes d'un réseau LAN.
    New-Alias -Name scanip -Value "Get-LANInventory" -Scope Global -Force
    # Exposer un port sur internet, WAN, (serveo.net, tunnl.gg, localhost.run)
    New-Alias -Name expose -Value Open-Port -Scope Global -Force
}