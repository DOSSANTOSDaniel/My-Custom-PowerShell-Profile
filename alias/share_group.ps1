function My_Alias_Share {
    # Description des alias de partage de fichiers et terminal...
    $MyAliasShareFileTermFunctionsDescriptions = @{
        gofile = "Partage de fichiers WAN, (Gofile.io)."
        lmsrv  = "Partage d'arborescence de fichiers et dossiers LAN, (Miniserve)."
        shterm = "Partage de terminal WAN, (Upterm)."
        shdesk = "Partage de Desktop WAN, (RustDesk)."
        lwmsrv = "Partage d'arborescence de fichiers et dossiers LAN, (Miniserve) et WAN tunnel (serveo.net, tunnl.gg, localhost.run)."
    }
    Get-Alias |
    Where-Object { $MyAliasShareFileTermFunctionsDescriptions.ContainsKey($_.Name) } |
    Select-Object `
        Name,
    @{ Name = 'Description'; Expression = { $MyAliasShareFileTermFunctionsDescriptions[$_.Name] } }
}

function My_Alias_Share_Group {
    # Alias group
    New-Alias -Name gshare -Value My_Alias_Share -Scope Global -Force

    # Alias
    # Partage de fichiers WAN
    New-Alias -Name gofile -Value upload_files_gofile -Scope Global -Force
    # Serveur web LAN
    New-Alias -Name lmsrv -Value files_srv_web_lan -Scope Global -Force
    # Bureau à distance
    New-Alias -Name shdesk -Value share_desktop -Scope Global -Force
    # Serveur web Wan
    New-Alias -Name lwmsrv -Value files_srv_web_wan -Scope Global -Force
    # Partage de terminal
    New-Alias -Name shterm -Value Share_terminal_upterm -Scope Global -Force
}