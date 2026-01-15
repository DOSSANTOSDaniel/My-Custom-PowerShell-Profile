# Ultimate Windows Utility, utilitaire pour l'optimisation Windows
# https://christitus.com/windows-tool/
function chris_titus_win_util {
    [CmdletBinding()]
    param() 

    if (-not (Assert-AppInstalled -Apps @("wt", "pwsh"))) {
        return
    }

    if (-not $IsAdmin) {
        Write-Host "Cette fonction nécessite d'exécuter PowerShell en tant qu'administrateur." -ForegroundColor Red
        Write-Host "Démarrage d'un nouveau shell admin..." -ForegroundColor Green
        Start-Sleep -Seconds 5

        $command = "pwsh -NoExit -Interactive -NoLogo -Command `". $PROFILE && Clear-Host && chris`""
        Start-Process wt.exe -ArgumentList $command -Verb RunAs -ErrorAction Stop

        exit
    }  
    else {
        Invoke-WebRequest -useb https://christitus.com/win | Invoke-Expression
    }
}
