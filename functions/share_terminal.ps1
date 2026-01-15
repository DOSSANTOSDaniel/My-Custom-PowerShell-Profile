# Partage de terminal WAN, (Upterm)
function Share_terminal_upterm {
    [CmdletBinding()]
    param()
	
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $socketDir = "$env:LOCALAPPDATA\upterm"
	
    if (-not (Assert-AppInstalled -Apps @("pwsh", "wt.exe", "upterm"))) {
        return
    }

    if (-not $IsAdmin) {
        $confirm = Read-Host "Voulez-vous lancer Upterm en Administrateur ? (o/n)"
        $wantAdmin = $confirm.Trim() -match '^(o|oui)$'
        $canElevate = -not $IsSSH

        if ($wantAdmin -and $canElevate) {
            Write-Host "Cette fonction nécessite PowerShell en administrateur." -ForegroundColor Yellow
            Write-Host "Démarrage d'un nouveau shell admin..." -ForegroundColor Green
            Start-Sleep -Seconds 2

            $commands = @(
                '. $PROFILE'
                'Clear-Host'
                'Share_terminal_upterm'
            )

            $fullCommand = $commands -join "`n"

            Start-Process wt.exe `
                -Verb RunAs `
                -PassThru `
                -ErrorAction Stop `
                -ArgumentList @(
                'new-tab'
                '--focus'
                '--tabColor', '#ec5587ff'
                'pwsh'
                '-NoLogo'
                '-NoExit'
                '-Interactive'
                '-ExecutionPolicy', 'Bypass'
                '-Command', $fullCommand
            )

            Start-Sleep -Seconds 2
            [System.Environment]::Exit(0)
        }
    }
    elseif ($IsSSH) {

        Write-Host "Élévation impossible dans une session SSH." -ForegroundColor Red
        Write-Host "Démarrage en mode utilisateur." -ForegroundColor Yellow
    }
    else {

        Write-Host "Démarrage en mode utilisateur." -ForegroundColor Yellow
    }
    
    if (-not (Test-Path $socketDir)) { 
        New-Item -Path $socketDir -ItemType Directory | Out-Null 
    }
    
    # Capturer le temps T1 avant le lancement
    $startTime = [DateTime]::Now.Ticks
    
    # Lancement de l'hôte
    $proc = Start-Process `
        -FilePath "upterm.exe" `
        -ArgumentList "host --accept --skip-host-key-check -- pwsh -Interactive -NoLogo -NoExit -ExecutionPolicy Bypass" `
        -PassThru `
        -WindowStyle Hidden

    $UptermPID = $proc.Id
    if (-not (Get-Process -Id $UptermPID -ErrorAction SilentlyContinue)) {
        Write-Host " ❌ Erreur : Le processus Upterm n'a pas pu démarrer." -ForegroundColor Red
        return
    }

    Clear-Host
    Write-Host "`n 🚀 Upterm lancé (PID: $UptermPID), détection du socket en cours..." -ForegroundColor Cyan
    
    # Phase de surveillance
    $capturedSockets = @()
    $timeout = 100 
    
    while ($timeout -gt 0 -and $capturedSockets.Count -eq 0) {
        Start-Sleep -Milliseconds 100
        
        $capturedSockets = Get-ChildItem $socketDir -Filter "*.sock" -Recurse | Where-Object {
            $_.CreationTime.Ticks -ge $startTime
        }
        
        $timeout--
    }

    # Capture de T2 après la détection
    $stopTime = [DateTime]::Now.Ticks

    # Filtrage final
    $finalSocket = $capturedSockets | Where-Object {
        $_.CreationTime.Ticks -ge $startTime -and $_.CreationTime.Ticks -le $stopTime
    } | Select-Object -First 1

    if ($finalSocket) {
        $env:UPTERM_ADMIN_SOCKET = $finalSocket.FullName
        Write-Host "✅ Socket validé : $($finalSocket.Name)" -ForegroundColor Green

        # Attendre que la session soit prête
        Start-Sleep -Milliseconds 1500
        
        # Récupérer les infos de session
        $sessionInfo = upterm session current 2>&1 | Out-String

        if ($sessionInfo -match "ssh\s+(?<ssh>\S+@uptermd\.upterm\.dev)") {
            $sshTarget = $Matches.ssh
            if (-not $sshTarget) {
                Write-Error "❌ Impossible d'extraire le token SSH."
                return
            }   
            $sshTargetCmd = "ssh -t $sshTarget"
            $sshTargetCmd | Set-Clipboard
            
            Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor DarkCyan
            Write-Host "☢  SERVEUR UPTERM PRÊT !" -ForegroundColor Green
            Write-Host "═══════════════════════════════════════════════" -ForegroundColor DarkCyan
            
            Write-Host "`n📋 Commande SSH (copiée) :" -ForegroundColor Yellow
            Write-Host "   $sshTargetCmd" -ForegroundColor White
            
            Write-Host "`n📍 Pour vous connecter :" -ForegroundColor Cyan
            Write-Host "   1. Ouvrez un NOUVEAU terminal" -ForegroundColor Gray
            Write-Host "   2. Collez la commande : $sshTargetCmd" -ForegroundColor Gray

            Write-Host "   ! Tapez 'exit' dans une session pour arrêter le serveur !" -ForegroundColor Gray
            Write-Host "═══════════════════════════════════════════════" -ForegroundColor DarkCyan
            
            # Demander si on veut ouvrir un nouveau terminal
            $choice = Read-Host "`nOuvrir un nouveau terminal pour se connecter ? (o/n)"
            if ($choice -match '^[oO]') {

                $commands = @(
                    'Clear-Host'
                    'Write-Host "`n`n   ------------------------" -ForegroundColor Yellow'                     
                    'Write-Host "   -----------------------------------------------" -ForegroundColor Cyan'
                    'Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor DarkCyan'
                    'Write-Host "🚀 Connexion à la session Upterm..." -ForegroundColor Green'
                    'Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor DarkCyan'
                    'Write-Host "   -----------------------------------------------" -ForegroundColor Cyan'
                    'Write-Host "   ------------------------" -ForegroundColor Yellow'
                    'Write-Host "   ..." -ForegroundColor Gray'                    
                    'Start-Sleep -Seconds 5'
                    $sshTargetCmd
                )

                $fullCommand = $commands -join "`n"

                Start-Process wt.exe -ArgumentList @(
                    'new-tab'
                    '--focus'
                    '--tabColor', '#00FFAA'
                    'pwsh'
                    '-NoExit'
                    '-Interactive'
                    '-ExecutionPolicy', 'Bypass'
                    '-Command', $fullCommand
                )

                # Gestion de la fermeture
                Register-EngineEvent PowerShell.Exiting -Action {
                    if ($UptermPID) {
                        Stop-Process -Id $UptermPID -Force -ErrorAction SilentlyContinue
                        Remove-Item "$env:UPTERM_ADMIN_SOCKET" -ErrorAction SilentlyContinue
                    }
                } | Out-Null
            }
            else {
                Write-Host "`n 🕹  Vous pouvez maintenant ouvrir un nouveau terminal et coller la commande SSH." -ForegroundColor Gray
                pause
            }
        }
        else {
            Write-Host "❌ Erreur : Aucun socket de session détecté" -ForegroundColor Red
            Stop-Process -Id $UptermPID -Force
            Remove-Item "$env:UPTERM_ADMIN_SOCKET" -ErrorAction SilentlyContinue
        }
    }   
    else {
        Write-Host "❌ Erreur : Aucun socket n'est apparu dans la fenêtre de tir ($startTime -> $stopTime)." -ForegroundColor Red
        Stop-Process -Id $UptermPID -Force
    }
}