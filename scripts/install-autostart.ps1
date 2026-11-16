# 安装 / 移除「开机自动启动演示环境」
# 装：.\scripts\install-autostart.ps1
# 卸：.\scripts\install-autostart.ps1 -Remove
# 实现：在用户启动文件夹放一个 cmd，登录时静默启动守护进程
# （守护进程 = 先立即检查一遍，然后每天 08:00 / 12:00 / 18:00 各检查一遍）
param([switch]$Remove)

$startup = [Environment]::GetFolderPath('Startup')
$entry = Join-Path $startup 'MES演示自启.cmd'
$script = Join-Path $PSScriptRoot 'refresh-demo.ps1'

if ($Remove) {
    if (Test-Path $entry) { Remove-Item $entry -Force; Write-Host "已移除开机自启：$entry" -ForegroundColor Green }
    else { Write-Host "本来就没装" -ForegroundColor DarkGray }
    return
}

if (-not (Test-Path $script)) { Write-Host "找不到 $script" -ForegroundColor Red; exit 1 }

$lines = @(
    '@echo off',
    'title MES Demo Launcher',
    "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`" -Watch -NoOpen"
)
[IO.File]::WriteAllText($entry, ($lines -join "`r`n") + "`r`n", (New-Object Text.UTF8Encoding($false)))

# 桌面图标：用绝对路径，避免 %~dp0 指向桌面导致找不到 ps1
$desktop = Join-Path ([Environment]::GetFolderPath('Desktop')) 'MES-启动演示.cmd'
$deskLines = @(
    '@echo off',
    'title MES Demo Launcher',
    "set `"PS1=$script`"",
    'echo [1/2] Checking backend and tunnel ...',
    'powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -NoOpen',
    'echo.',
    'echo [2/2] Starting daily watcher (08:00 / 12:00 / 18:00 Beijing time) ...',
    'start "MES-Demo-Watch" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Watch -NoOpen',
    'echo.',
    'echo ============================================',
    'echo  Daily checks: 08:00, 12:00, 18:00.',
    'echo  Closing this window will NOT stop them.',
    'echo ============================================',
    'pause'
)
[IO.File]::WriteAllText($desktop, ($deskLines -join "`r`n") + "`r`n", (New-Object Text.UTF8Encoding($false)))

Write-Host "已启用开机自启：$entry" -ForegroundColor Green
Write-Host "已生成桌面图标：$desktop" -ForegroundColor Green
Write-Host "登录后静默启动守护进程：立即检查一遍，然后每天 08:00 / 12:00 / 18:00 各检查一遍" -ForegroundColor Cyan
Write-Host "取消：.\scripts\install-autostart.ps1 -Remove" -ForegroundColor DarkGray
