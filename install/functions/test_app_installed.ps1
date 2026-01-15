# Teste si une application est installé ou pas et récupère des informations sur celle-ci
function Test-AppInstalled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$AppName
    )

    # Vérifier si la commande existe dans le PATH
    $cmd = Get-Command -Name $AppName -ErrorAction SilentlyContinue
    if ($cmd) {
        return [PSCustomObject]@{
            Installed = $true
            Path      = $cmd.Source
            Name      = $cmd.Name
        }
    }

    # Dossiers standards des applications
    $paths = @(
        "$env:ProgramFiles",
        "$env:ProgramFiles(x86)",
        "$env:LOCALAPPDATA\Programs",
        "C:\Tools"
    )

    foreach ($path in $paths) {
        if (-not (Test-Path $path)) { continue }

        # Recherche limitée, pas récursive
        $exe = Get-ChildItem -Path $path -Filter "*$AppName*.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue |
               Select-Object -First 1

        if ($exe) {
            return [PSCustomObject]@{
                Installed = $true
                Path      = $exe.FullName
                Name      = $exe.Name
            }
        }
    }

    # Application non trouvé
    return [PSCustomObject]@{
        Installed = $false
        Path      = $null
        Name      = $null
    }
}