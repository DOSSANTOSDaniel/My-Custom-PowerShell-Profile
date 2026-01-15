# Partage de fichiers WAN avec Gofile
function upload_files_gofile {
    [CmdletBinding()]
    param()

    Add-Type -AssemblyName System.Windows.Forms

    Clear-Host

    # Sélection du fichier
    $configPath = "$env:USERPROFILE\.gofile_guest.json"
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Title = "Protocol: Select Payload for Transmission"
    $ofd.Filter = "All Files|*.*"
    
    if (-not ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)) {
        Write-Host "⚠ Opération annulée par l'utilisateur !" -ForegroundColor Red
        return
    }
    $FilePath = $ofd.FileName

    # Fonction Interne, récupération des infos de l'utilisateur temporaire (guest)
    function Invoke-GofileUpload($filePath, $guestToken, $parentFolder) {
        $fields = @{"file" = Get-Item $filePath }
        if ($guestToken -and $parentFolder) {
            $fields["token"] = $guestToken
            $fields["folderId"] = $parentFolder
        }

        return Invoke-RestMethod -Uri "https://upload.gofile.io/uploadfile" -Method Post -Form $fields 2>$null
    }

    Write-Host "📦 FICHIER : $(Split-Path $FilePath -Leaf)" -ForegroundColor Cyan

    $guestInfo = if (Test-Path $configPath) { Get-Content $configPath | ConvertFrom-Json } else { $null }

    # Tentative de connexion avec les données de l'ancien utilisateur temporaire
    $response = if ($guestInfo) {
        Invoke-GofileUpload $FilePath $guestInfo.guestToken $guestInfo.parentFolder
    }

    # Si les infos de l'ancien utilisateur temporaire ont expiré alors créer un nouveau compte temporaire
    if (-not $response -or $response.status -ne "ok") {
        Write-Host "🔄 Régénération d'un nouveau token temporaire..." -ForegroundColor Cyan
        $response = Invoke-GofileUpload $FilePath $null $null
        
        if ($response.status -eq "ok") {
            $newGuestInfo = @{
                guestToken   = $response.data.guestToken
                parentFolder = $response.data.parentFolder
            }
            $newGuestInfo | ConvertTo-Json | Set-Content $configPath
        }
        else {
            Write-Host "❌ Erreur protocole !" -ForegroundColor Red
            return
        }
    }

    Write-Host "`n ✅ Transmission OK ! `n" -ForegroundColor Green
    Write-Host " NOM    : $($response.data.name)" -ForegroundColor Yellow
    Write-Host " TAILLE : $($response.data.size) octets" -ForegroundColor Yellow
    Write-Host " LINK   : $($response.data.downloadPage)" -ForegroundColor Cyan

    # Copie automatique dans le presse-papier
    Set-Clipboard $response.data.downloadPage
    Write-Host "`n [ LIEN COPIÉ DANS LE PRESSE-PAPIER ]`n" -ForegroundColor DarkGray
}
