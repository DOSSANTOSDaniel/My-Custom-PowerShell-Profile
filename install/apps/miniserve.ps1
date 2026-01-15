function Install-miniserve {
    [CmdletBinding()]
    param ()

    Write-Host "Installation de Miniserve..." -ForegroundColor Yellow

    scoop update
    scoop install miniserve
    
    Write-Host "Installation de Miniserve terminée." -ForegroundColor Green

    Add-FirewallRulePort `
        -Name "MiniServe TCP 8080" `
        -Port 8080 `
        -Protocol TCP `
        -Direction Inbound
}