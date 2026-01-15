function My_Alias_SSH {
    # Description des alias SSH
    $MyAliasSSHDescriptions = @{
        wlapt = "SSH Windows laptop."
        wdesk = "SSH Windows desktop."
        dtort = "SSH Server tortue."
        dprox = "SSH Server Proxmox."
        unext = "SSH Server Nextcloud."
        flapt = "SSH Laptop Fedora."
        lmint = "SSH Laptop mint."
        dpcdu = "SSH pcDuino v1."
    }
    Get-Alias |
    Where-Object { $MyAliasSSHDescriptions.ContainsKey($_.Name) } |
    Select-Object `
        Name,
    @{ Name = 'Description'; Expression = { $MyAliasSSHDescriptions[$_.Name] } }
}

function My_Alias_SSH_Group {
    # Alias Group
    New-Alias -Name gssh -Value My_Alias_SSH -Scope Global -Force

    ## Alias SSH
    New-Alias -Name wlapt -Value ssh_win_laptop -Scope Global -Force
    New-Alias -Name wdesk -Value ssh_win_desktop -Scope Global -Force
    New-Alias -Name dtort -Value ssh_tortue -Scope Global -Force
    New-Alias -Name dprox -Value ssh_proxmox -Scope Global -Force
    New-Alias -Name unext -Value ssh_nextcloud -Scope Global -Force
    New-Alias -Name flapt -Value ssh_fedora -Scope Global -Force
    New-Alias -Name lmint -Value ssh_mint -Scope Global -Force
    New-Alias -Name dpcdu -Value ssh_pcduino -Scope Global -Force
}
