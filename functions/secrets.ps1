# Charger les secrets du projet
function Import-Secrets {
    param(
        [string]$Path = "$ProfileRoot\.env"
    )

    if (-not (Test-Path $Path)) {
        Write-Warning ".env introuvable ($Path)"
        return
    }

    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*#' -or -not $_) { return }

        $name, $value = $_ -split '=', 2
        $name  = $name.Trim()
        $value = $value.Trim()

        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}
