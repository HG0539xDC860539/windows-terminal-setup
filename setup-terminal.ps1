<#
.SYNOPSIS
    Windows 终端现代化一键配置脚本（无需管理员权限）
.DESCRIPTION
    基于 draft.md 优化方案，自动安装 Nerd Font、17 个 CLI 工具、
    配置 Starship 主题和 PowerShell Profile。
    支持 Scoop 或 winget，全程普通用户权限。
    字体通过 per-user 方式安装，不需要管理员。
    使用 -Restore 可恢复为脚本配置前的默认状态。
.EXAMPLE
    .\setup-terminal.ps1
    .\setup-terminal.ps1 -Force
    .\setup-terminal.ps1 -Restore            # 交互式恢复（可选择卸载范围）
    .\setup-terminal.ps1 -Restore -Force     # 全部恢复（不逐项确认）
#>

param(
    [switch]$Force,    # 跳过确认，全部使用推荐默认值
    [switch]$Restore   # 恢复到脚本配置前的默认状态
)

$ErrorActionPreference = "Stop"

# ── 辅助函数 ──────────────────────────────────────────
function Write-Title($t) { Write-Host "`n-- $t --" -ForegroundColor Cyan }
function Write-Step($t)  { Write-Host "`n  >> $t" -ForegroundColor Yellow }
function Write-Ok($t)    { Write-Host "  [OK] $t" -ForegroundColor Green }
function Write-Warn($t)  { Write-Host "  [!!] $t" -ForegroundColor DarkYellow }
function Write-Fail($t)  { Write-Host "  [X]  $t" -ForegroundColor Red }

function Update-SessionPath {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
}

function Test-Command($name) {
    [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

# 检测 per-user 字体是否已安装
function Test-FontInstalled($name) {
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (Test-Path $regPath) {
        $props = Get-ItemProperty $regPath
        $found = $props.PSObject.Properties | Where-Object {
            $_.Name -like "*$name*" -or $_.Value -like "*$name*"
        }
        return [bool]$found
    }
    return $false
}

# Per-user 字体安装（不需要管理员）
# Windows 10 1809+ 支持用户级字体
function Install-FontPerUser($fontDir) {
    $dest = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    if (-not (Test-Path $dest)) {
        New-Item -Path $dest -ItemType Directory -Force | Out-Null
    }

    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    $ttfFiles = Get-ChildItem $fontDir -Filter "*.ttf"
    $otfFiles = Get-ChildItem $fontDir -Filter "*.otf"
    $fontFiles = $ttfFiles + $otfFiles

    foreach ($font in $fontFiles) {
        $destFile = Join-Path $dest $font.Name
        Copy-Item $font.FullName $destFile -Force

        # 注册表条目：字体名 → 文件路径
        $fontNameBase = [System.IO.Path]::GetFileNameWithoutExtension($font.Name)
        $regName = "$fontNameBase (TrueType)"
        Set-ItemProperty -Path $regPath -Name $regName -Value $destFile
    }
}

# 安全追加 Profile 配置（按行检测，不重复）
function Add-ProfileConfig($configLines) {
    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath -Parent

    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }

    # 备份
    if (Test-Path $profilePath) {
        $backup = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $profilePath $backup
        Write-Ok "Profile 备份 → $(Split-Path $backup -Leaf)"
    } else {
        New-Item -Path $profilePath -ItemType File -Force | Out-Null
    }

    $existing = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $existing) { $existing = "" }

    $added = @()
    foreach ($line in $configLines) {
        $trimmed = $line.Trim()
        # 跳过空行和注释的重复检测
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
            $added += $line
            continue
        }
        # 核心配置行：检测是否已存在
        if ($existing -notmatch [regex]::Escape($trimmed)) {
            $added += $line
        }
    }

    if ($added.Count -gt 0) {
        $block = "`n" + ($added -join "`n") + "`n"
        Add-Content -Path $profilePath -Value $block -Encoding UTF8
        Write-Ok "Profile 已更新"
    } else {
        Write-Ok "Profile 无需更新（配置已存在）"
    }
}

# ── 恢复模式 ──────────────────────────────────────────
if ($Restore) {
    Write-Title "恢复默认配置（卸载终端优化）"

    $markerStart = "# >>> setup-terminal.ps1 >>>"
    $markerEnd   = "# <<< setup-terminal.ps1 <<<"

    # --- 1. 清理 PowerShell Profile ---
    Write-Step "清理 PowerShell Profile..."
    $profilePath = $PROFILE
    $restoredProfile = $false

    if (Test-Path $profilePath) {
        $content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
        if ($null -ne $content -and $content.Contains($markerStart)) {
            # 备份当前 profile
            $backup = "$profilePath.pre-restore.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $profilePath $backup
            Write-Ok "当前 Profile 备份 → $(Split-Path $backup -Leaf)"

            # 移除标记块之间的内容
            $pattern = "(?ms)\r?\n?" + [regex]::Escape($markerStart) + ".*?" + [regex]::Escape($markerEnd) + "\r?\n?"
            $newContent = $content -replace $pattern, "`n"
            # 清理多余空行（连续 3 个以上换行压缩为 2 个）
            $newContent = $newContent -replace "(\r?\n){3,}", "`n`n"
            $newContent = $newContent.TrimEnd() + "`n"

            if ($newContent.Trim() -eq "") {
                # Profile 变空了，直接删除
                Remove-Item $profilePath -Force
                Write-Ok "Profile 已清空并移除（原本只有脚本配置）"
            } else {
                Set-Content -Path $profilePath -Value $newContent -Encoding UTF8 -NoNewline
                Write-Ok "Profile 中脚本配置块已移除"
            }
            $restoredProfile = $true
        } else {
            Write-Warn "Profile 中未找到脚本配置标记，跳过"
        }
    } else {
        Write-Warn "Profile 文件不存在，跳过"
    }

    # --- 2. 移除 Starship 配置 ---
    Write-Step "移除 Starship 配置..."
    $starshipConfig = "$env:USERPROFILE\.config\starship.toml"
    if (Test-Path $starshipConfig) {
        Remove-Item $starshipConfig -Force
        Write-Ok "starship.toml 已删除"
    } else {
        Write-Warn "starship.toml 不存在，跳过"
    }

    # --- 3. 移除 per-user 字体 ---
    Write-Step "移除 0xProto Nerd Font (per-user)..."
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontRemoved = 0

    if (Test-Path $fontDir) {
        $fontFiles = Get-ChildItem $fontDir -Filter "0xProto*"
        foreach ($f in $fontFiles) {
            Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue
            # 移除对应注册表条目
            $regName = "$($f.BaseName) (TrueType)"
            if (Test-Path $regPath) {
                $props = Get-ItemProperty $regPath
                $prop = $props.PSObject.Properties | Where-Object {
                    $_.Name -eq $regName -or $_.Value -eq $f.FullName
                }
                if ($prop) {
                    Remove-ItemProperty -Path $regPath -Name $prop.Name -Force -ErrorAction SilentlyContinue
                }
            }
            $fontRemoved++
        }
    }
    if ($fontRemoved -gt 0) {
        Write-Ok "已移除 $fontRemoved 个 0xProto 字体文件"
    } else {
        Write-Warn "未找到 0xProto per-user 字体，跳过"
    }

    # --- 4. 卸载 CLI 工具 ---
    Write-Host ""
    Write-Host "  是否卸载 CLI 工具？" -ForegroundColor Yellow
    Write-Host "    [1] 全部卸载（Scoop/winget 安装的工具）"
    Write-Host "    [2] 仅卸载通过 Scoop 安装的工具"
    Write-Host "    [3] 保留工具，不卸载"
    Write-Host ""
    $uninstallChoice = if ($Force) { "1" } else { (Read-Host "  请输入 1-3 [默认 3]") }
    if (-not $uninstallChoice) { $uninstallChoice = "3" }

    $allScoopTools = @(
        "starship", "lsd", "zoxide", "fzf", "fd",
        "bat", "ripgrep", "jq", "jd", "tldr", "yazi",
        "ffmpeg", "imagemagick", "poppler", "resvg", "7zip",
        "coreutils", "lazygit"
    )
    $allWingetTools = @(
        @{ Id = "Starship.Starship";            Name = "starship" }
        @{ Id = "sxyazi.yazi";                  Name = "yazi" }
        @{ Id = "Gyan.FFmpeg";                  Name = "ffmpeg" }
        @{ Id = "7zip.7zip";                    Name = "7zip" }
        @{ Id = "jqlang.jq";                    Name = "jq" }
        @{ Id = "oschwartz10612.Poppler";       Name = "poppler" }
        @{ Id = "sharkdp.fd";                   Name = "fd" }
        @{ Id = "BurntSushi.ripgrep.MSVC";      Name = "ripgrep" }
        @{ Id = "junegunn.fzf";                 Name = "fzf" }
        @{ Id = "ajeetdsouza.zoxide";           Name = "zoxide" }
        @{ Id = "ImageMagick.ImageMagick";      Name = "imagemagick" }
        @{ Id = "sharkdp.bat";                  Name = "bat" }
        @{ Id = "tldr-pages.tlrc";              Name = "tldr" }
        @{ Id = "uutils.coreutils";             Name = "coreutils" }
    )
    if ($uninstallChoice -eq "1" -or $uninstallChoice -eq "2") {
        # Scoop 卸载
        if (Test-Command scoop) {
            Write-Step "通过 Scoop 卸载工具..."
            $uninstalled = 0
            foreach ($tool in $allScoopTools) {
                $out = scoop uninstall $tool 2>&1
                $text = ($out | Out-String)
                if ($text -notmatch "ERROR" -and $text -notmatch "not installed") {
                    Write-Ok "$tool (scoop)"
                    $uninstalled++
                }
            }
            if ($uninstalled -eq 0) { Write-Warn "没有通过 Scoop 安装的工具" }
        }

        # winget 卸载
        if ($uninstallChoice -eq "1" -and (Test-Command winget)) {
            Write-Step "通过 winget 卸载工具..."
            $uninstalled = 0
            foreach ($tool in $allWingetTools) {
                try {
                    winget uninstall $tool.Id --exact --accept-source-agreements --silent 2>$null
                    Write-Ok "$($tool.Name) (winget)"
                    $uninstalled++
                } catch {
                    # 工具可能不是通过 winget 安装的，忽略
                }
            }
            if ($uninstalled -eq 0) { Write-Warn "没有通过 winget 安装的工具" }
        }

        # 清理 zoxide 数据
        $zoxideDataDir = Join-Path $env:APPDATA "zoxide"
        if (Test-Path $zoxideDataDir) {
            Remove-Item $zoxideDataDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Ok "zoxide 历史数据已清除"
        }
    }

    # --- 5. 列出备份文件 ---
    Write-Step "Profile 备份文件："
    $profileDir = Split-Path $PROFILE -Parent
    if (Test-Path $profileDir) {
        $backups = Get-ChildItem $profileDir -Filter "*.backup.*"
        $preRestores = Get-ChildItem $profileDir -Filter "*.pre-restore.*"
        $allBackups = @($backups) + @($preRestores) | Sort-Object LastWriteTime -Descending
        if ($allBackups.Count -gt 0) {
            foreach ($b in $allBackups) {
                Write-Host "    $($b.Name)" -ForegroundColor Gray
            }
            Write-Host ""
            Write-Host "  如需恢复某个备份，手动执行：" -ForegroundColor DarkYellow
            Write-Host "    Copy-Item `"$profileDir\$($allBackups[0].Name)`" `"$PROFILE`" -Force" -ForegroundColor Gray
        } else {
            Write-Warn "无备份文件"
        }
    }

    # --- 完成 ---
    Write-Title "恢复完成"
    Write-Host @"

  已恢复：
    [1] PowerShell Profile   $(if ($restoredProfile) { "已清理" } else { "无需清理" })
    [2] Starship 配置         已移除
    [3] 0xProto Nerd Font     已移除 (per-user)
    [4] CLI 工具              $(if ($uninstallChoice -eq "3") { "保留" } else { "已卸载" })

  还需手动：
    - Windows Terminal → 设置 → 配置文件 → 默认值 → 外观 → 字体
      改回你之前使用的字体
    - 重启终端

"@ -ForegroundColor White

    Write-Host "  终端已恢复为默认状态。`n" -ForegroundColor Cyan
    exit 0
}

# ── 第 0 步：选择包管理器 ─────────────────────────────
Write-Title "Windows 终端现代化一键配置"

if ($Force) {
    $pm = "scoop"
    $themeChoice = "1"
    Write-Ok "Force 模式：Scoop + Catppuccin Powerline"
} else {
    Write-Host "`n  选择包管理器："
    Write-Host "    [1] Scoop  (推荐 - 包更全、批量安装快)"
    Write-Host "    [2] winget (Windows 11 自带)"
    Write-Host ""
    $choice = Read-Host "  请输入 1 或 2 [默认 1]"
    if ($choice -eq "2") { $pm = "winget" } else { $pm = "scoop" }
}
Write-Ok "包管理器：$pm"

# ── Scoop 初始化 ──────────────────────────────────────
if ($pm -eq "scoop") {
    if (-not (Test-Command scoop)) {
        Write-Step "安装 Scoop（普通用户权限）..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Update-SessionPath
        if (-not (Test-Command scoop)) {
            Write-Fail "Scoop 安装失败"
            Write-Warn "请确认：1) 以普通用户运行  2) 网络 OK"
            exit 1
        }
        Write-Ok "Scoop 安装成功"
    } else {
        Write-Ok "Scoop 已安装"
    }

    Write-Step "配置 Scoop buckets..."
    $bucketList = (scoop bucket list 2>$null) -join " "
    foreach ($b in @("nerd-fonts", "extras")) {
        if ($bucketList -notmatch [regex]::Escape($b)) {
            scoop bucket add $b 2>$null
            Write-Ok "bucket: $b"
        }
    }
}

# ── winget 检查 ───────────────────────────────────────
if ($pm -eq "winget") {
    if (-not (Test-Command winget)) {
        Write-Fail "未找到 winget，请安装 App Installer（Microsoft Store）"
        exit 1
    }
    Write-Ok "winget 可用"
}

# ── 第一步：Nerd Font ─────────────────────────────────
Write-Title "第一步：安装 Nerd Font (0xProto)"

if (Test-FontInstalled "0xProto") {
    Write-Ok "0xProto Nerd Font 已安装"
} else {
    Write-Step "下载并安装 0xProto Nerd Font (per-user)..."

    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/0xProto.zip"
    $fontZip = "$env:TEMP\0xProto-NF.zip"
    $fontDir = "$env:TEMP\0xProto-NF"

    try {
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -UseBasicParsing
        if (Test-Path $fontDir) { Remove-Item $fontDir -Recurse -Force }
        Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
        Install-FontPerUser $fontDir
        Remove-Item $fontZip -Force -ErrorAction SilentlyContinue
        Remove-Item $fontDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Ok "0xProto Nerd Font 安装完成（per-user）"
    } catch {
        Write-Fail "字体安装失败：$_"
        Write-Warn "手动下载：https://www.nerdfonts.com/ → 搜索 0xProto"
    }
}

# ── 第二步：安装 CLI 工具 ──────────────────────────────
Write-Title "第二步：安装 CLI 工具全家桶（17 个）"

$successCount = 0
$failCount = 0
$failedTools = [System.Collections.Generic.List[string]]::new()

if ($pm -eq "scoop") {
    # 按类别批量安装（scoop 支持一条命令装多个包）
    $groups = [ordered]@{
        "外观与交互" = @("starship", "lsd")
        "导航与搜索" = @("zoxide", "fzf", "fd")
        "查看与阅读" = @("bat", "ripgrep", "jq", "jd", "tldr", "yazi")
        "处理与转换" = @("ffmpeg", "imagemagick", "poppler", "resvg", "7zip")
        "基础设施"   = @("coreutils", "lazygit")
    }

    foreach ($entry in $groups.GetEnumerator()) {
        Write-Step "[$($entry.Key)] $($entry.Value -join ', ')"
        # 逐个安装，收集结果（scoop 批量安装时错误信息混在一起不好解析）
        foreach ($tool in $entry.Value) {
            $out = scoop install $tool 2>&1
            $text = ($out | Out-String)
            if ($text -match "ERROR") {
                Write-Fail "$tool"
                $failCount++
                $failedTools.Add($tool)
            } else {
                Write-Ok "$tool"
                $successCount++
            }
        }
    }
} else {
    # winget：逐个安装
    $wingetTools = @(
        @{ Id = "Starship.Starship";            Name = "starship" }
        @{ Id = "sxyazi.yazi";                  Name = "yazi" }
        @{ Id = "Gyan.FFmpeg";                  Name = "ffmpeg" }
        @{ Id = "7zip.7zip";                    Name = "7zip" }
        @{ Id = "jqlang.jq";                    Name = "jq" }
        @{ Id = "oschwartz10612.Poppler";       Name = "poppler" }
        @{ Id = "sharkdp.fd";                   Name = "fd" }
        @{ Id = "BurntSushi.ripgrep.MSVC";      Name = "ripgrep" }
        @{ Id = "junegunn.fzf";                 Name = "fzf" }
        @{ Id = "ajeetdsouza.zoxide";           Name = "zoxide" }
        @{ Id = "ImageMagick.ImageMagick";      Name = "imagemagick" }
        @{ Id = "sharkdp.bat";                  Name = "bat" }
        @{ Id = "tldr-pages.tlrc";              Name = "tldr" }
        @{ Id = "uutils.coreutils";             Name = "coreutils" }
    )

    foreach ($tool in $wingetTools) {
        Write-Step "安装 $($tool.Name)..."
        try {
            winget install $tool.Id --exact --accept-source-agreements --accept-package-agreements --silent 2>$null
            Write-Ok "$($tool.Name)"
            $successCount++
        } catch {
            Write-Fail "$($tool.Name)"
            $failCount++
            $failedTools.Add($tool.Name)
        }
    }

    # winget 缺失的工具 → 用 scoop 补装
    $wingetMissing = @("lsd", "resvg", "lazygit", "jd")
    Write-Host ""
    Write-Warn "winget 缺少：$($wingetMissing -join ', ')"
    $answer = if ($Force) { "y" } else { (Read-Host "  用 Scoop 补装？[Y/n]").ToLower() }
    if ($answer -ne "n") {
        if (-not (Test-Command scoop)) {
            Write-Step "安装 Scoop 以补装缺失工具..."
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
            Update-SessionPath
        }
        foreach ($tool in $wingetMissing) {
            $out = scoop install $tool 2>&1
            $text = ($out | Out-String)
            if ($text -match "ERROR") {
                Write-Fail "$tool"
                $failCount++
                $failedTools.Add($tool)
            } else {
                Write-Ok "$tool (scoop)"
                $successCount++
            }
        }
    }
}

Update-SessionPath

$color = if ($failCount -gt 0) { "Yellow" } else { "Green" }
Write-Host "`n  安装完成：成功 $successCount 个，失败 $failCount 个" -ForegroundColor $color

# ── 第三步：Starship 主题 ─────────────────────────────
Write-Title "第三步：配置 Starship 主题"

if (-not $themeChoice) {
    Write-Host "`n  选择 Starship 主题："
    Write-Host "    [1] Catppuccin Powerline (推荐)"
    Write-Host "    [2] Gruvbox Rainbow"
    Write-Host "    [3] Tokyo Night"
    Write-Host "    [4] 跳过"
    Write-Host ""
    $themeChoice = Read-Host "  请输入 1-4 [默认 1]"
    if (-not $themeChoice) { $themeChoice = "1" }
}

$starshipDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $starshipDir)) {
    New-Item -Path $starshipDir -ItemType Directory -Force | Out-Null
}

$themes = @{
    "1" = @("catppuccin-powerline", "Catppuccin Powerline")
    "2" = @("gruvbox-rainbow",      "Gruvbox Rainbow")
    "3" = @("tokyo-night",           "Tokyo Night")
}

if ($themes[$themeChoice]) {
    $preset, $label = $themes[$themeChoice]
    if (Test-Command starship) {
        starship preset $preset -o "$starshipDir\starship.toml"
        Write-Ok "$label 主题已应用"
    } else {
        Write-Warn "starship 未找到，跳过主题配置"
    }
} else {
    Write-Warn "跳过主题设置"
}

# ── 第四步：配置 PowerShell Profile ───────────────────
Write-Title "第四步：配置 PowerShell Profile"

$markerStart = "# >>> setup-terminal.ps1 >>>"
$markerEnd   = "# <<< setup-terminal.ps1 <<<"

# 构建配置内容（按实际安装情况）
$configLines = @(
    $markerStart
    ""
    "# Starship Prompt"
    "Invoke-Expression (&starship init powershell)"
    ""
    "# zoxide 智能跳转"
    "Invoke-Expression (& { (zoxide init powershell | Out-String) })"
)

if (Test-Command lsd) {
    $configLines += @(
        "",
        "# lsd 替代 ls"
        "Set-Alias -Name ls -Value lsd -Option AllScope -Force"
    )
}
if (Test-Command bat) {
    $configLines += @(
        "",
        "# bat 替代 cat"
        "Set-Alias -Name cat -Value bat -Option AllScope -Force"
    )
}

$configLines += @(
    "",
    $markerEnd
)

Add-ProfileConfig $configLines

# ── 完成 ───────────────────────────────────────────────
Write-Title "全部完成"

Write-Host @"

  已完成：
    [1] Nerd Font (0xProto)     已安装 (per-user)
    [2] CLI 工具                成功 $successCount / 17
    [3] Starship 主题            已配置
    [4] PowerShell Profile       已配置

  还需手动：
    - Windows Terminal → 设置 → 配置文件 → 默认值 → 外观 → 字体
      选择「0xProto Nerd Font」
    - 重启终端

"@ -ForegroundColor White

if ($failedTools.Count -gt 0) {
    Write-Host "  失败的工具：$($failedTools -join ', ')" -ForegroundColor Red
    Write-Host "  可稍后手动重试`n" -ForegroundColor DarkYellow
}

Write-Host "  重启终端后运行 'z proj' 体验智能跳转！`n" -ForegroundColor Cyan
