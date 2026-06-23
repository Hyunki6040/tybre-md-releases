#Requires -Version 5.1
# Tybre.md Windows installer
#   irm https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.ps1 | iex

[Net.ServicePointManager]::SecurityProtocol = `
    [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

function Install-Tybre {
    $repo    = 'Hyunki6040/tybre-md-releases'
    $appName = 'Tybre.md'

    # ProgressPreference off -> Invoke-WebRequest downloads are ~10x faster on PS 5.1
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    try {
        Write-Host ''
        Write-Host 'Tybre.md Installer' -ForegroundColor White
        Write-Host '--------------------------------'

        # ── Windows check ───────────────────────────────────────────────────────
        if ($env:OS -ne 'Windows_NT') {
            Write-Host '[X] This installer is for Windows only.' -ForegroundColor Red
            return
        }
        Write-Host '==> Detected: Windows (x64)' -ForegroundColor Blue

        # ── Fetch latest release ────────────────────────────────────────────────
        Write-Host '==> Checking latest release...' -ForegroundColor Blue
        try {
            $release = Invoke-RestMethod `
                -Uri "https://api.github.com/repos/$repo/releases/latest" `
                -Headers @{ 'User-Agent' = 'tybre-installer' }
        } catch {
            Write-Host '[X] Failed to fetch release info. Check your internet connection.' -ForegroundColor Red
            return
        }

        $version = $release.tag_name
        if (-not $version) {
            Write-Host '[X] Could not determine version from GitHub API.' -ForegroundColor Red
            return
        }

        # Prefer the x64 NSIS installer (silent, per-user, no admin required)
        $asset = $release.assets | Where-Object { $_.name -like '*x64-setup.exe' } | Select-Object -First 1
        if (-not $asset) {
            $asset = $release.assets | Where-Object { $_.name -like '*-setup.exe' } | Select-Object -First 1
        }
        if (-not $asset) {
            Write-Host '[X] Could not find a Windows installer (-setup.exe) in the latest release.' -ForegroundColor Red
            return
        }

        # ── Download ────────────────────────────────────────────────────────────
        Write-Host "==> Downloading $appName $version..." -ForegroundColor Blue
        $tmp = Join-Path $env:TEMP $asset.name
        try {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing
        } catch {
            Write-Host '[X] Download failed.' -ForegroundColor Red
            return
        }

        # ── Install (silent) ────────────────────────────────────────────────────
        Write-Host '==> Installing...' -ForegroundColor Blue
        # NSIS silent flag: /S  (Tauri installs to %LOCALAPPDATA%\Programs by default)
        $proc = Start-Process -FilePath $tmp -ArgumentList '/S' -Wait -PassThru
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue

        if ($proc.ExitCode -ne 0) {
            Write-Host "[!] Installer exited with code $($proc.ExitCode)." -ForegroundColor Yellow
        }

        # ── Done ────────────────────────────────────────────────────────────────
        Write-Host ''
        Write-Host "[OK] $appName $version installed successfully!" -ForegroundColor Green
        Write-Host ''
        Write-Host '  Launch from the Start Menu -> search "Tybre"'
        Write-Host ''
    }
    finally {
        $ProgressPreference = $oldProgress
    }
}

Install-Tybre
