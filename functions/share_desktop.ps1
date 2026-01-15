# Bureau à distance avec RustDesk
function share_desktop {
    [CmdletBinding()]
    param() 

    if (-not (Assert-AppInstalled -Apps "rustdesk")) {
        return
    }

    try {
        rustdesk --install-service
        Write-Host "RustDesk service OK !." -ForegroundColor Green
    }
    catch {
        Write-Error "Erreur RustDesk service: $_"
        return
    }
}