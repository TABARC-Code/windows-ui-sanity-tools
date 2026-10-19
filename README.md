# Windows UI Sanity Tools

Read-only screen and window diagnostics for pixel-based automation.

`Get-UiEnvironment.ps1` reports every connected display's absolute bounds and working area, the cursor position and the current foreground window's process, position, size and (where Windows supports it) DPI.


```powershell
.\Get-UiEnvironment.ps1
.\Get-UiEnvironment.ps1 -Json | Out-File -Encoding utf8 .\screen-layout.json
```

Supports Windows PowerShell 5.1 and PowerShell 7 on a Windows desktop. It never moves the mouse, brings windows to the foreground or changes display settings.

Use the output to identify negative secondary-monitor coordinates, scaling changes and window movement before running coordinate-based click scripts. Pixel dimensions and foreground-window DPI alone do not eliminate the need to test an automation against each application's UI and DPI-awareness mode.
