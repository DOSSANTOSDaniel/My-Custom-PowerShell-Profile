# Vérification si un service est opérationnel
function Test-ServiceInstall {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName
    )

    # Vérifier si le service existe
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if (-not $service) {
        return [PSCustomObject]@{
            Exists     = $false
            Running    = $false
            StartType  = $null
        }
    }

    return [PSCustomObject]@{
        Exists     = $true
        Running    = $service.Status -eq 'Running'
        StartType  = $service.StartType
    }
}
