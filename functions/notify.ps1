# Notify.ps1
# Fonctions de notification sonore, vocal et popup texte

# Popup GUI text et son de notification
function Show-Text-Popup {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [string]$Title = "PowerShell",

        [ValidateSet("Info", "Warning", "Error", "Question")]
        [string]$Type = "Info",

        [ValidateSet("OK", "OKCancel", "YesNo", "YesNoCancel")]
        [string]$Buttons = "OK",

        [int]$TimeoutSeconds = 0
    )

    $iconMap = @{
        Info     = 0x40
        Warning  = 0x30
        Error    = 0x10
        Question = 0x20
    }

    $buttonMap = @{
        OK          = 0
        OKCancel    = 1
        YesNo       = 4
        YesNoCancel = 3
    }

    $wshell = New-Object -ComObject WScript.Shell

    $result = $wshell.Popup(
        $Message,
        $TimeoutSeconds,
        $Title,
        $iconMap[$Type] -bor $buttonMap[$Buttons]
    )

    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wshell) | Out-Null

    switch ($result) {
        1 { "OK" }
        2 { "Cancel" }
        6 { "Yes" }
        7 { "No" }
        -1 { "Timeout" }
    }
}

# Notification vocal
function Show-Voice-Popup {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [string]$Title = "PowerShell Notification",

        [ValidateSet("Info", "Warning", "Error", "Question")]
        [string]$Type = "Info"
    )

    # Voix (hors SSH)
    if (-not $IsSSH) {
        try {
            if (-not ([System.AppDomain]::CurrentDomain.GetAssemblies().FullName -match "System.Speech")) {
                Add-Type -AssemblyName System.Speech -ErrorAction Stop
            }

            $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $speak.SelectVoice("Microsoft Hortense Desktop")
            $speak.Volume = 80
            [void]$speak.SpeakAsync($Message)

            # Cleanup automatique après la parole
            Register-ObjectEvent $speak SpeakCompleted -Action {
                $Event.Sender.Dispose()
            } | Out-Null
        }
        catch {}
    }
}

# Notification musicale
# Fichiers WAV uniquement !
function Show-Music-Popup {
    param(
        [Parameter(Mandatory)]
        [string]$MusicFile
    )

    if (-not $IsSSH -and (Test-Path $MusicFile)) {
        try {
            $player = [System.Media.SoundPlayer]::new($MusicFile)
            $player.Load()   # évite les coupures
            $player.Play()   # non bloquant
        }
        catch {}
    }
}

# Notification Polyphonique (son système)
function Show-Audio-Popup {
    param(
        [ValidateSet("Info", "Warning", "Error", "Question")]
        [string]$Type = "Info"
    )

    if ($IsSSH) { return }

    switch ($Type) {
        "Info" { [System.Media.SystemSounds]::Asterisk.Play() }
        "Warning" { [System.Media.SystemSounds]::Exclamation.Play() }
        "Error" { [System.Media.SystemSounds]::Hand.Play() }
        "Question" { [System.Media.SystemSounds]::Beep.Play() }
    }
}