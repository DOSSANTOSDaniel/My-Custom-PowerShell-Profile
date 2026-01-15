function Show-Banner { 
    Clear-Host

    Write-Host "`n  ◢◤ " -NoNewline -ForegroundColor $C_Title
    Write-Host "⌬ SYSTEM $machineName" -NoNewline -ForegroundColor $C_Border
    Write-Host " ◥◣" -ForegroundColor $C_Title

    Write-Host " ╭──────────────────────────────────────────────────────────╮" -ForegroundColor $C_Border

    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "VER: " -NoNewline -ForegroundColor $C_Dim
    Write-Host "PS $PSVersion " -NoNewline -ForegroundColor $C_Value
    Write-Host "│ STATUS: " -NoNewline -ForegroundColor $C_Dim
    Write-Host "$(if ($IsAdmin) {"Admin"} else {"User"}) " -NoNewline -ForegroundColor "Cyan"
    Write-Host "│ USER: " -NoNewline -ForegroundColor $C_Dim
    Write-Host "$userName" -ForegroundColor $C_Value
    Write-Host " ├──────────────────────────────────────────────────────────┤" -ForegroundColor $C_Border

    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "📡 NETWORK " -NoNewline -ForegroundColor $C_Title
    Write-Host "──────────────────────────────────────────────┤" -ForegroundColor $C_Border
    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "   IP Local  : " -NoNewline -ForegroundColor $C_Dim
    Write-Host "$ip_host".PadRight(15) -NoNewline -ForegroundColor $C_Value
    Write-Host " IP Public : " -NoNewline -ForegroundColor $C_Dim
    Write-Host "$ip_public" -ForegroundColor $C_Value
    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "   Physical  : " -NoNewline -ForegroundColor $C_Dim
    Write-Host "$mac_address" -ForegroundColor $C_Dim

    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "💾 STORAGE " -NoNewline -ForegroundColor $C_Title
    Write-Host "──────────────────────────────────────────────┤" -ForegroundColor $C_Border

    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "   Usage : $disk_used_gb GB / $total GB " -NoNewline -ForegroundColor $C_Label
    Write-Host " [$bar] " -NoNewline -ForegroundColor $C_Value
    Write-Host "$percent%" -ForegroundColor Cyan

    Write-Host " │ " -NoNewline -ForegroundColor $C_Border
    Write-Host "📂 MODULES " -NoNewline -ForegroundColor $C_Title
    Write-Host "──────────────────────────────────────────────┤" -ForegroundColor $C_Border

    $aliases = @(
        "gtools : Outils système et autre.",
        "gwol   : Wake-On-LAN",
        "gssh   : Connexions SSH.",
        "gshare : Partage de fichiers / desktop / terminal."
    )

    foreach ($alias in $aliases) {
        Write-Host " │ " -NoNewline -ForegroundColor $C_Border
        Write-Host "   > $alias" -ForegroundColor $C_Dim
    }

    Write-Host " ╰──────────────────────────────────────────────────────────╯" -ForegroundColor $C_Border
    # Barre de chargement ready
    FX-ScanBarLight
}