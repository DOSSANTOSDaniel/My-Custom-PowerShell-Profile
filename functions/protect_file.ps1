# Création d'un fichier zip protégé par mot de passe
function Protect-File7Zip {
    [CmdletBinding()]
    param()

    if (-not (Assert-AppInstalled -Apps "7z")) {
        return
    } 

    Add-Type -AssemblyName System.Windows.Forms

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Choisissez un fichier à chiffrer"

    if ($dialog.ShowDialog() -ne "OK") {
        Write-Verbose "Opération annulée."
        return
    }

    $file = $dialog.FileName
    Write-Verbose "Fichier sélectionné : $file"

    # Mot de passe automatique
    $password = [guid]::NewGuid().ToString("N")
    Write-Verbose "Mot de passe généré : $password"

    # Archive de sortie (remplace extension)
    $output = [System.IO.Path]::ChangeExtension($file, ".7z")

    # Commande 7-Zip
    $arguments = @(
        "a"
        "-t7z"
        "-mhe=on"
        "-p$password"
        $output
        $file
    )

    try {
        & 7z @arguments | Out-Null
        Write-Host "✔ Archive chiffrée créée : $output"
        Write-Host "✔ Mot de passe : $password"
    }
    catch {
        Write-Error "❌ Erreur lors de l'exécution de 7z : $_"
    }
}
