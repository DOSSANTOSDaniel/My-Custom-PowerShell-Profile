# Affiche les ports en écoute
function Get-OpenPorts {
    Get-NetTCPConnection -State Listen |
    Sort-Object LocalPort |
    Select-Object LocalAddress, LocalPort, OwningProcess,
    @{Name = 'Process'; Expression = {
            try {
                $p = Get-Process -Id $_.OwningProcess -ErrorAction Stop
                "$($p.ProcessName) ($($p.Path))"
            }
            catch {
                'N/A'
            }
        }
    }
}