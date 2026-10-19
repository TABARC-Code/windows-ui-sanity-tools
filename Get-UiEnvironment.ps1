# TABARC-Code
# Report screen geometry and foreground-window details without changing anything.
[CmdletBinding()]
param([switch]$Json)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class DisplayWindowInfo {
  [StructLayout(LayoutKind.Sequential)]
  public struct RECT { public int Left, Top, Right, Bottom; }
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out int processId);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
  [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr hWnd);
}
"@

$monitors = @([System.Windows.Forms.Screen]::AllScreens | ForEach-Object {
  [pscustomobject]@{
    device = $_.DeviceName
    primary = $_.Primary
    x = $_.Bounds.X
    y = $_.Bounds.Y
    width = $_.Bounds.Width
    height = $_.Bounds.Height
    workX = $_.WorkingArea.X
    workY = $_.WorkingArea.Y
    workWidth = $_.WorkingArea.Width
    workHeight = $_.WorkingArea.Height
  }
})

$cursor = [System.Windows.Forms.Cursor]::Position
$handle = [DisplayWindowInfo]::GetForegroundWindow()
$activeWindow = $null
if ($handle -ne [IntPtr]::Zero) {
  $processId = 0
  [void][DisplayWindowInfo]::GetWindowThreadProcessId($handle,[ref]$processId)
  $bounds = New-Object DisplayWindowInfo+RECT
  [void][DisplayWindowInfo]::GetWindowRect($handle,[ref]$bounds)
  $processName = $null
  try { $processName = (Get-Process -Id $processId -ErrorAction Stop).ProcessName }
  catch { $processName = 'unknown' }
  $dpi = $null
  try { $dpi = [DisplayWindowInfo]::GetDpiForWindow($handle) } catch {}
  $activeWindow = [pscustomobject]@{
    processName = $processName
    processId = $processId
    x = $bounds.Left
    y = $bounds.Top
    width = $bounds.Right - $bounds.Left
    height = $bounds.Bottom - $bounds.Top
    windowDpi = $dpi
  }
}

$result = [pscustomobject]@{
  capturedAt = (Get-Date).ToUniversalTime().ToString('o')
  monitors = $monitors
  cursor = [pscustomobject]@{ x=$cursor.X; y=$cursor.Y }
  foreground = $activeWindow
}
if ($Json) { $result | ConvertTo-Json -Depth 7 } else { $result }
