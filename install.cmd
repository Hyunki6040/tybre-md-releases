@echo off
setlocal
REM Tybre.md Windows installer (CMD / Command Prompt)
REM
REM Usage (from cmd.exe):
REM   curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.cmd -o install.cmd && install.cmd && del install.cmd
REM
REM This is a thin bootstrap: it shells out to PowerShell and runs the canonical
REM install.ps1, so the actual install logic (latest-release lookup, download,
REM silent NSIS install) lives in exactly one place.

powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; irm https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.ps1 | iex"
if errorlevel 1 (
  echo.
  echo [X] Installation failed. See the message above.
  endlocal
  exit /b 1
)
endlocal
