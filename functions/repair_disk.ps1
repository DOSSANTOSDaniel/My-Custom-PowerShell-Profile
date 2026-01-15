# CHKDSK au prochain redémarrage
function Repair-Disk {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Drive
    )
    # Si SSH quitter
    if ($IsSSH) {
        Write-Host "Élévation impossible dans une session SSH." -ForegroundColor Red
        return
    }
    
    # Si non admin lancer en admin
    if (-not $IsAdmin) { 
        Write-Host "Cette fonction nécessite PowerShell en administrateur." -ForegroundColor Yellow
        Write-Host "Relance en shell admin..." -ForegroundColor Green
        Start-Sleep -Seconds 2
		
        $commands = @(
            '. $PROFILE'
            'Clear-Host'
            'rdisk'
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

        [System.Environment]::Exit(0)
    }
    else {
        if ($Drive) {
            # Récupérer le type de disk
            $selected_disk = "$Drive"

            $disk_num = (get-partition -DriveLetter $selected_disk).DiskNumber
            $disk_type = Get-PhysicalDisk | Where-Object DeviceId -eq $disk_num
        }
        else {
            # Récupérer le type de disk
            # trouve le numéro du disk boot 
            $boot_disk = Get-Disk | Where-Object { $_.BootFromDisk -eq $true } | Select-Object Number

            # trouver le type de ce disque
            $nb_disk = Get-PhysicalDisk | Where-Object DeviceId -eq $boot_disk.Number
            $disk_type = $nb_disk.MediaType

            # Récupérer la lettre du volume système sur ce disque
            $system_volume = Get-Partition -DiskNumber $boot_disk.Number | 
            Where-Object { $_.DriveLetter } | 
            Select-Object -First 1 | 
            ForEach-Object { (Get-Volume -DriveLetter $_.DriveLetter).DriveLetter }

            $selected_disk = "${system_volume}:"
        }

        # Sécurité : lettre propre
        # if ($selected_disk -notmatch '^[A-Za-z]:$') {
        if ($selected_disk.Length -ne 2 -or $selected_disk[1] -ne ":") {
            Write-Host "Lecteur invalide (ex: C:)" -ForegroundColor Red
            return
        }

        Write-Host "`n🛠️ Scan disque approfondi (CHKDSK)" -ForegroundColor Cyan
        Write-Host "Disque : $selected_disk" -ForegroundColor Gray
        Write-Host "⚠️ Le scan aura lieu AU PROCHAIN REDÉMARRAGE." -ForegroundColor Yellow

        if (-not $disk_type) {
            Write-Host "Impossible de déterminer le type de disque." -ForegroundColor Yellow
            $chkdskArgs = "/f"
        }
        elseif ($disk_type -eq 'SSD') {
            Write-Host "Disque SSD détecté : scan logique uniquement (/f)" -ForegroundColor Cyan
            $chkdskArgs = "/f"
        }
        else {
            Write-Host "Disque HDD détecté : scan approfondi (/f /r)" -ForegroundColor Cyan
            $chkdskArgs = "/f /r"
        }

        $confirm = Read-Host "Planifier la vérification au redémarrage ? (O/N)"
        if ($confirm -notmatch '^[oOyY]') {
            Write-Host "Annulé par l'utilisateur." -ForegroundColor Yellow
            return
        }

        Write-Host "`n 📅 Planification de CHKDSK..." -ForegroundColor Cyan

        cmd /c "echo Y | chkdsk $selected_disk $chkdskArgs"

        Write-Host "✅ Vérification planifiée." -ForegroundColor Green
        Write-Host "🔄 Redémarre la machine pour lancer le scan !" -ForegroundColor Cyan
    }
}