<#
.SYNOPSIS
  herbed-tiramisu for Windows: shows every notification received by tiramisu with herbe.

.DESCRIPTION
  Port of herbed-tiramisu.sh. Same pipeline: tiramisu prints one line per
  notification, each line becomes a herbe popup, killed after the
  notification's expire timeout.

  Differences with the bash version (all deliberate):
  * tiramisu runs with -j and every line goes through ConvertFrom-Json.
    The original ran `export timeout=... app=...` through word splitting and
    execution of the line ($tiramisu), so a summary like `x; rm -rf ~` was code.
  * expire_timeout is in milliseconds (spec). The original passed it to
    `timeout ${timeout}s` (seconds), and for the very common -1 ("server
    default") `timeout` refused to run at all, so herbe never showed.
  * herbe is started without waiting: herbe already queues itself (named
    mutex), and waiting here would stop reading tiramisu's stdout.
  * the timeout closes herbe with WM_CLOSE (taskkill without /F), which herbe
    treats as a dismiss, instead of SIGKILL.

.EXAMPLE
  .\herbed-tiramisu.ps1
  .\herbed-tiramisu.ps1 -Tiramisu C:\tools\tiramisu.exe -Herbe C:\tools\herbe.exe -ShowBody
#>
param(
    [string]$Tiramisu = 'tiramisu.exe',
    [string]$Herbe = 'herbe.exe',
    [switch]$ShowBody
)

# Quote one argument so CommandLineToArgvW / the MSVC CRT give it back intact
# (backslashes before a quote are doubled, quotes are escaped).
function ConvertTo-WinArg([string]$a) {
    if ($a -ne '' -and $a -notmatch '[\s"]') { return $a }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('"')
    $bs = 0
    foreach ($ch in $a.ToCharArray()) {
        if ($ch -eq '\') { $bs++; continue }
        if ($ch -eq '"') { [void]$sb.Append('\' * (2 * $bs + 1)); [void]$sb.Append('"') }
        else { [void]$sb.Append('\' * $bs); [void]$sb.Append($ch) }
        $bs = 0
    }
    [void]$sb.Append('\' * (2 * $bs))
    [void]$sb.Append('"')
    $sb.ToString()
}

$herbePath = (Get-Command $Herbe -ErrorAction Stop).Source

& $Tiramisu -j | ForEach-Object {
    $n = $_ | ConvertFrom-Json
    $lines = @("App: $($n.source)", '', "Message: $($n.summary)")
    if ($ShowBody -and $n.body) { $lines += $n.body }

    $psi = New-Object System.Diagnostics.ProcessStartInfo $herbePath
    $psi.Arguments = ($lines | ForEach-Object { ConvertTo-WinArg $_ }) -join ' '
    $psi.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($psi)

    if ($n.timeout -gt 0) {
        # timeout -s9 ${timeout}s herbe ...   (a detached sleeper, so the loop keeps reading)
        $cmd = "Start-Sleep -Milliseconds $($n.timeout); taskkill /PID $($p.Id) | Out-Null"
        Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile', '-Command', $cmd | Out-Null
    }
}
