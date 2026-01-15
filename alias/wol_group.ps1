function My_Alias_WOL {
    # Description des alias Wake On Lan
    $MyAliasWOLDescriptions = @{
        pveon  = "WOL Proxmox."
        nexton = "WOL Nextcloud."
    }
    
    Get-Alias |
    Where-Object { $MyAliasWOLDescriptions.ContainsKey($_.Name) } |
    Select-Object `
        Name,
    @{ Name = 'Description'; Expression = { $MyAliasWOLDescriptions[$_.Name] } }
}

function My_Alias_Wol_Group {
    # Alias Groups
    New-Alias -Name gwol -Value My_Alias_WOL -Scope Global -Force

    ## Wake On Lan
    New-Alias -Name pveon -Value wol_proxmox -Scope Global -Force
    New-Alias -Name nexton -Value wol_nextcloud -Scope Global -Force
}