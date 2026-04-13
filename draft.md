---
# 30分钟整容手术：让Windows 终端秒变 macOS 现代终端
---

## 先看效果

图1

**你想不想要一个同样美观、高效、信息密度拉满的现代终端？**

不需要装 Linux，不需要买 Mac，不需要任何编程基础。
30 分钟，Scoop 或 winget 一键安装，全程抄作业。


> 💡 **Scoop 和 winget 都是 Windows 包管理器。** winget 是 Windows 11 自带的（Windows 10 也可手动安装），开箱即用；Scoop 需要手动安装，但包更全、更新更快。本文两种方式都提供，推荐 Scoop。

**安装 Scoop**（以普通用户身份打开 PowerShell）：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

安装完成后重启终端，`scoop` 命令即可使用。

---

## 第一步：Nerd Font——让终端认得图标

终端里那些文件夹图标 📁、Git 分支符号 🌿、对勾 ✅、箭头 ➜……
在你这里是方块或乱码？

因为你缺了一款「图标字体」。

**Nerd Font** 是为终端专门设计的字体族，内置数万个图标字形。几乎所有现代 CLI 工具（starship、lsd、lazygit……）的图标渲染都依赖它。不装，一切优化都是空中楼阁。

### 安装

**Scoop（推荐）：**

```powershell
scoop install nerd-fonts/0xProto-NF
```

**手动下载：**

访问 [Nerd Fonts 官网](https://www.nerdfonts.com/)，搜索 `0xProto`，下载安装。

### 配置 Windows Terminal

打开 Windows Terminal → 设置 → 配置文件 → 默认值 → 外观 → 字体 → 选择 `0xProto Nerd Font` → 保存。

重启终端。图标显示正常，第一步完成。

> 💡 **0xProto** 是一款专为编程终端设计的等宽字体，字形清晰，图标兼容性好。如果你喜欢其他风格，也可以选 `CaskaydiaCove Nerd Font`（微软 Cascadia Code 的 Nerd Font 版）、`FiraCode Nerd Font` 或 `JetBrainsMono Nerd Font`。

---

## 第二步：Starship Prompt——换一套酷炫的命令行提示符

你每天盯着终端，看最多的就是那一行提示符。
默认的 `PS C:\Users\you>` 能告诉你什么？只有当前路径。
而 Starship 能让你一眼看到：当前目录、Git 分支和状态、语言运行时版本、命令耗时、错误码……

### 安装

```powershell
# Scoop
scoop install starship

# winget
winget install Starship.Starship
```

### 配置 PowerShell

打开 PowerShell 配置文件：

```powershell
notepad $PROFILE
```

如果提示文件不存在，先创建：

```powershell
New-Item -Path $PROFILE -ItemType File -Force
notepad $PROFILE
```

在文件中添加这一行：

```powershell
Invoke-Expression (&starship init powershell)
```

保存，重启终端。提示符已经变漂亮了。

### 三款推荐主题

Starship 内置几十款预设主题，一行命令切换。以下三款是我实测最适合暗色终端的：

**🍮 Catppuccin Powerline**

柔和暖色调，渐变 Powerline 箭头分段显示信息。色彩协调、信息层次清晰，长时间使用不疲劳。**最推荐的主题。**

```powershell
starship preset catppuccin-powerline -o ~/.config/starship.toml
```

**🌈 Gruvbox Rainbow**

复古暖色系，彩虹渐变效果，辨识度极高。适合喜欢张扬风格的终端玩家。

```powershell
starship preset gruvbox-rainbow -o ~/.config/starship.toml
```

**🌃 Tokyo Night**

紫蓝色调，高对比护眼。喜欢冷色系的话可以选这个。

```powershell
starship preset tokyo-night -o ~/.config/starship.toml
```

> 💡 **选不出？直接用 Catppuccin Powerline。** 不踩雷，不后悔。

切换主题后重启终端即可生效。配置文件在 `~/.config/starship.toml`，可以手动微调每个模块的颜色和显示逻辑。

<!-- 图片1：starship-catppuccin.png —— Catppuccin Powerline 主题效果 -->
<!-- 图片2：starship-tokyo-night.png —— Tokyo Night 主题效果 -->
<!-- 图片3：starship-gruvbox.png —— Gruvbox Rainbow 主题效果 -->

---

## 第三步：CLI 工具全家桶——先认识再装备

### 全家桶总览

这一步我们要装 17 个工具，按功能分成 5 大类。先看全局地图，再逐个深入。

```
🖥️ Windows 终端 CLI 工具全家桶
│
├── 🎨 外观与交互层（让你的终端好看、好用）
│   ├── starship  ── 命令行提示符
│   └── lsd      ── 彩色文件列表
│
├── 🚀 导航与搜索层（让你快速找到文件和目录）
│   ├── zoxide   ── 智能目录跳转
│   ├── fzf      ── 模糊搜索神器
│   └── fd       ── 快速文件查找
│
├── 📖 查看与阅读层（让终端内容一目了然）
│   ├── bat      ── 语法高亮的 cat
│   ├── ripgrep  ── 超高速文本搜索
│   ├── jq       ── JSON 处理器
│   ├── jd       ── JSON Diff
│   ├── tldr     ── 简化版命令手册
│   └── yazi     ── 终端文件管理器
│
├── 🛠️ 处理与转换层（让终端能处理多媒体和压缩包）
│   ├── ffmpeg   ── 音视频处理
│   ├── ImageMagick ── 图片处理
│   ├── poppler  ── PDF 工具集
│   ├── resvg    ── SVG 渲染
│   └── 7zip     ── 压缩解压
└── 🔧 基础设施层（补齐 Windows 终端缺失的核心能力）
    ├── coreutils ── GNU 核心工具
    └── lazygit  ── Git 可视化界面
```

**一句话总结**：外观层让你赏心悦目，导航层让你指哪打哪，查看层让你信息通透，处理层让你能打能扛，基础层让 Windows 终端不再缺胳膊少腿。

> 💡 这 17 个工具中，`yazi` 的 PDF 预览依赖 `poppler`，SVG 预览依赖 `resvg`，图片/视频预览依赖 `ffmpeg` + `ImageMagick`。所以它们不是独立的——装 yazi 的时候顺带把预览依赖一起装上，体验才完整。

### 一键安装

**Scoop（推荐，版本更新快）：**

```powershell
# 外观与交互
scoop install starship lsd

# 导航与搜索
scoop install zoxide fzf fd

# 查看与阅读
scoop install bat ripgrep jq jd tldr yazi

# 处理与转换
scoop install ffmpeg imagemagick poppler resvg 7zip

# 基础设施
scoop install coreutils lazygit
```

**winget：**

```powershell
winget install Starship.Starship sxyazi.yazi Gyan.FFmpeg 7zip.7zip jqlang.jq oschwartz10612.Poppler sharkdp.fd BurntSushi.ripgrep.MSVC junegunn.fzf ajeetdsouza.zoxide ImageMagick.ImageMagick sharkdp.bat tldr-pages.tlrc uutils.coreutils
```

> ⚠️ winget 缺少的包：`lsd`、`resvg`、`lazygit`、`jd`、`nerd-fonts`。这些工具建议用 Scoop 补装，或者去 GitHub Releases 手动下载。

---

下面按 5 大分类逐个详细拆解。每个工具讲清楚：**它是什么、替代了什么、为什么用它、怎么装、基本用法、实战场景。**

---

## 🎨 第一层：外观与交互

### 📁 lsd —— 彩色文件列表

**替代**：`ls` / `dir`

**它是什么**：Rust 写的现代 `ls` 替代品。彩色图标区分文件类型，Git 状态直接标注在文件名旁边（修改、新增、未追踪一目了然），支持树形视图。

**为什么用它**：Windows 的 `dir` 和 PowerShell 的 `Get-ChildItem` 输出是纯文本，没有颜色、没有图标、没有 Git 状态。`lsd` 让你一眼看出哪些文件被改过、哪些是目录、哪些是可执行文件。

**安装**：

```powershell
# Scoop
scoop install lsd
```

**基本用法**：

```powershell
lsd              # 彩色文件列表（带图标）
lsd -la          # 显示隐藏文件 + 详细信息
lsd --tree       # 树形目录结构
lsd --tree -L 2  # 树形结构，只展开 2 层
```

**效果对比**：

```
# PowerShell 默认
    Directory: C:\projects
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        2026/4/10    10:30                src
-a----        2026/4/10    09:15           2048 main.py
-a----        2026/4/9     18:00            512 README.md

# lsd
📁 src
📄 main.py
📄 README.md
```

**配置别名**（添加到 `$PROFILE`）：

```powershell
Set-Alias -Name ls -Value lsd -Option AllScope -Force
```

<!-- 图片4：lsd-tree.png —— lsd 树形输出效果 -->

---

## 🚀 第二层：导航与搜索

### ⚡ zoxide —— 智能目录跳转

**替代**：`cd`

**它是什么**：Rust 写的智能 `cd` 替代品。它会记住你访问过的目录和使用频率，用 `z` 命令 + 关键词模糊匹配，直接跳转。用得越久越精准。

**为什么用它**：不再需要一层层 `cd` 或者复制粘贴长路径。输入 `z proj` 直接跳到 `C:\Users\you\Documents\projects`。

**安装**：

```powershell
# Scoop
scoop install zoxide

# winget
winget install ajeetdsouza.zoxide
```

**配置 PowerShell**（添加到 `$PROFILE`）：

```powershell
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

保存后重启终端，`z` 命令就可用了。

**基本用法**：

```powershell
z proj        # 跳转到最近访问的、路径包含 "proj" 的目录
z doc down    # 跳转到路径同时包含 "doc" 和 "down" 的目录
z -l proj     # 列出所有匹配 "proj" 的目录（不跳转）
```

> 💡 **zoxide 需要积累数据。** 刚装好的时候它什么都不认识——你先用 `cd` 正常访问几次目录，zoxide 会在后台记录。访问越频繁的目录，`z` 命令的匹配优先级越高。一般用一两天后，体验就会非常流畅。

---

### 🔍 fzf —— 模糊搜索神器

**它是什么**：Go 写的通用模糊搜索器。可以从文件列表、命令历史、进程列表等任何文本流中进行交互式模糊搜索。

**为什么用它**：配合 `Ctrl+R` 模糊搜索命令历史，比 PowerShell 自带的历史搜索好用十倍。还可以配合 `fd` 搜索文件、配合 `ps` 搜索进程，几乎所有文本列表都能用 fzf 交互式筛选。

**安装**：

```powershell
# Scoop
scoop install fzf

# winget
winget install junegunn.fzf
```

**基本用法**：

```powershell
fzf               # 从当前目录所有文件中模糊搜索
history | fzf      # 从命令历史中搜索
fd . | fzf         # 从 fd 搜索结果中选择文件
```

**常用场景**：

```powershell
# 搜索文件并打开
fd | fzf | ForEach-Object { code $_ }

# 搜索进程并杀死
ps | fzf | ForEach-Object { Stop-Process -Id $_.Id }
```

> ⚠️ fzf 的 `Ctrl+R` 快捷键集成在 PowerShell 中需要 PSReadLine 配置，不同环境配置方式不同，建议根据实际环境查阅 fzf 官方文档配置。

---

### 📂 fd —— 简洁的文件搜索

**替代**：`find` / `Get-ChildItem -Recurse`

**它是什么**：Rust 写的文件查找工具。语法比 `find` 简洁得多，默认忽略 `.gitignore`，彩色输出，自动区分文件和目录。

**为什么用它**：找文件不再需要写复杂的 `find` 参数。正则表达式友好，速度快，输出美观。

**安装**：

```powershell
# Scoop
scoop install fd

# winget
winget install sharkdp.fd
```

**基本用法**：

```powershell
fd "\.py$"              # 查找所有 .py 文件
fd "config"             # 查找文件名包含 "config" 的文件
fd -e js -e ts          # 查找 .js 或 .ts 文件
fd -d 3                 # 只搜索 3 层深度
fd -t d "src"           # 只搜索目录（-t f 搜索文件）
fd -H "hidden"          # 包含隐藏文件搜索
fd --changed-within 1d  # 最近一天修改过的文件
```

**实战场景**：

```powershell
# 找项目中所有图片
fd -e png -e jpg -e svg

# 找最近 7 天修改过的配置文件
fd -e json -e yaml -e toml --changed-within 7d

# 找并删除所有 .log 文件
fd -e log -X rm
```

---

## 📖 第三层：查看与阅读

### 🦇 bat —— 语法高亮的 cat

**替代**：`cat` / `Get-Content`

**它是什么**：Rust 写的文件查看工具，自动检测语言类型并应用语法高亮，支持行号显示、Git 变更标注、非打印字符可视化。

**为什么用它**：看代码不再是纯白文本。配合语法高亮，代码结构、注释、字符串、关键字一目了然。比在编辑器里打开文件快得多。

**安装**：

```powershell
# Scoop
scoop install bat

# winget
winget install sharkdp.bat
```

**基本用法**：

```powershell
bat main.py              # 语法高亮显示，自动检测语言
bat -A script.sh         # 显示 Tab、换行等不可见字符
bat -n main.py           # 只显示行号（无其他 UI）
bat -l json data.json    # 指定语言为 JSON 高亮
bat --theme=GitHub main.py  # 切换高亮主题
```

**配合管道使用**：

```powershell
echo '{"name":"test"}' | bat -l json    # JSON 格式化 + 高亮
curl -s api.example.com | bat -l json   # API 响应直接高亮
kubectl logs pod-name | bat -l yaml     # K8s 日志高亮
```

**配置别名**（添加到 `$PROFILE`）：

```powershell
Set-Alias -Name cat -Value bat
```

<!-- 图片5：bat-highlight.png —— bat 语法高亮效果 -->

---

### 🔎 ripgrep（rg）—— 搜索界的闪电

**替代**：`grep` / `Select-String` / Windows 搜索

**它是什么**：Rust 写的递归正则搜索引擎。默认忽略 `.gitignore` 中的文件，不搜索二进制文件，支持按文件类型过滤。速度比传统 `grep` 快数十倍。

**为什么用它**：大项目中搜索字符串，ripgrep 秒出结果。Windows 自带搜索和 PowerShell 的 `Select-String` 在面对几十 GB 的代码库时，差距非常明显。

**安装**：

```powershell
# Scoop
scoop install ripgrep

# winget
winget install BurntSushi.ripgrep.MSVC
```

**基本用法**：

```powershell
rg "TODO"                    # 在当前目录递归搜索 "TODO"
rg -i "error"                # 忽略大小写搜索
rg "Error" src/              # 只在 src 目录下搜索
rg --type py "class"         # 只在 Python 文件中搜索
rg -A 3 -B 3 "pattern"       # 显示匹配行前后各 3 行
rg --stats "Error"           # 搜索完成后显示统计信息
rg -l "TODO"                 # 只列出包含匹配的文件名
```

**实战场景**：

```powershell
# 找项目中所有 TODO 注释
rg "TODO|FIXME|HACK" --type-add 'web:*.{js,ts,jsx,tsx,vue}' -t web

# 找某个端口号在哪些文件中出现
rg ":8080"

# 搜索并统计匹配数
rg "import.*React" --count
```

<!-- 图片6：rg-search.png —— ripgrep 搜索效果 -->

---

### 🔧 jq —— JSON 处理瑞士军刀

**它是什么**：命令行 JSON 处理器。格式化、过滤、提取字段、聚合计算，一句话搞定。

**为什么用它**：AI 工具的输出大量是 JSON（API 响应、配置文件、日志）。`jq` 能让你在终端里直接解析和查询 JSON，不用复制到浏览器或编辑器里。

**安装**：

```powershell
# Scoop
scoop install jq

# winget
winget install jqlang.jq
```

**基本用法**：

```powershell
# 格式化（美化输出）
echo '{"name":"test","version":"1.0"}' | jq .

# 提取字段
curl -s api.github.com/users/octocat | jq '.name'

# 过滤数据
cat data.json | jq '.users[] | select(.age > 30)'

# 提取所有 key
cat config.json | jq 'keys'

# 统计数组长度
cat package.json | jq '.dependencies | keys | length'

# 数组排序
cat data.json | jq '.items | sort_by(.price) | reverse | .[0:5]'
```

**实战场景**：

```powershell
# 从 API 响应中提取所有 URL
curl -s api.example.com/endpoints | jq '.[].url'

# 对比两个 JSON 文件的某个字段
jd diff a.json b.json    # 需要 jd 工具（见下文）
```

---

### 📊 jd —— JSON Diff

**它是什么**：Rust 写的 JSON 对比工具。两个 JSON 文件之间的差异高亮显示，比 `diff` 对 JSON 更友好。

**安装**：

```powershell
# Scoop
scoop install jd
```

**基本用法**：

```powershell
jd a.json b.json              # 对比两个文件
echo '{"a":1}' | jd -         # 从 stdin 读取对比
jd -set a.json b.json         # 按集合模式对比（忽略顺序）
jd -color b.json a.json       # 指定颜色方案
```

**实战场景**：

```powershell
# 对比 API 修改前后的响应
jd response_before.json response_after.json

# 对比两个配置文件
jd config_dev.json config_prod.json
```

---

### 📖 tldr —— 简化版命令帮助

**替代**：`man` / `--help`

**它是什么**：社区维护的简化版命令手册。不给你看几页长的完整文档，只列最常用的几个用法示例。遇到忘了怎么用的命令，`tldr tar` 比 `tar --help` 有效一百倍。

**安装**：

```powershell
# Scoop
scoop install tldr

# winget
winget install tldr-pages.tlrc
```

**基本用法**：

```powershell
tldr tar           # tar 的常用用法
tldr ffmpeg        # ffmpeg 的常用用法
tldr git rebase    # git rebase 的常用用法
tldr --update      # 更新本地缓存
```

**效果示例**：

```
tldr tar

  tar - 归档工具

  - 创建归档：
    tar cf target.tar file1 file2 file3

  - 创建 gzip 压缩归档：
    tar czf target.tar.gz file1 file2 file3

  - 解压归档：
    tar xf source.tar[.gz|.bz2|.xz]

  - 列出归档内容：
    tar tf source.tar
```

---

### 🐿️ yazi —— 终端文件管理器

**替代**：Windows 资源管理器（在终端内使用）

**它是什么**：Rust 写的终端文件管理器，支持图片、视频、PDF、SVG、压缩包的即时预览。Vim 风格键位，鼠标也可操作。

**为什么用它**：不用离开终端就能浏览文件、预览内容、批量操作。配合 Claude Code 等 AI 工具时，AI 让你"看一下某个文件"，直接在 yazi 里打开预览，不用切换窗口。

**安装**：

```powershell
# Scoop
scoop install yazi
```

**预览依赖**（让 yazi 能预览各种文件格式）：

```powershell
scoop install ffmpeg poppler resvg imagemagick 7zip
```

- `ffmpeg` → 视频/音频缩略图
- `poppler` → PDF 预览
- `resvg` → SVG 渲染
- `ImageMagick` → 图片格式转换
- `7zip` → 压缩包预览

**基本用法**：

```powershell
yazi    # 在当前目录启动
yazi .  # 同上
yazi C:\projects  # 打开指定目录
```

**常用快捷键**（Vim 风格）：

| 按键 | 功能 |
|------|------|
| `h/j/k/l` | 上/下/左/右 |
| `Enter` | 进入目录/打开文件 |
| `q` | 退出 yazi |
| `y` | 复制（yank） |
| `x` | 剪切 |
| `p` | 粘贴 |
| `d` | 删除 |
| `a` | 新建文件/目录 |
| `r` | 重命名 |
| `/` | 搜索 |
| `z` | 跳跃（使用 zoxide 记录） |

> ⚠️ yazi 在 Windows 上需要 Windows Terminal 才能正常显示图片预览。CMD 和旧版 PowerShell 不支持。

<!-- 图片7：yazi-preview.png —— yazi 文件预览效果 -->

---

## 🛠️ 第四层：处理与转换

### 🗜️ ffmpeg —— 多媒体处理瑞士军刀

**它是什么**：命令行音视频处理工具。格式转换、裁剪、合并、提取音频、生成 GIF……几乎你能想到的音视频操作它都能做。

**安装**：

```powershell
# Scoop
scoop install ffmpeg

# winget
winget install Gyan.FFmpeg
```

**基本用法**：

```powershell
# 视频转 GIF
ffmpeg -i input.mp4 -vf "fps=15,scale=640:-1" output.gif

# 提取音频
ffmpeg -i input.mp4 -vn -acodec copy output.mp3

# 视频裁剪（从第 10 秒开始，持续 30 秒）
ffmpeg -i input.mp4 -ss 00:00:10 -t 00:00:30 -c copy output.mp4

# 压缩视频
ffmpeg -i input.mp4 -crf 28 output.mp4

# 合并视频
ffmpeg -f concat -i list.txt -c copy output.mp4
```

---

### 🎨 ImageMagick —— 图片处理

**它是什么**：最强大的命令行图片处理工具。格式转换、缩放、裁剪、加水印、批量处理。

**安装**：

```powershell
# Scoop
scoop install imagemagick

# winget
winget install ImageMagick.ImageMagick
```

**基本用法**：

```powershell
magick input.png output.webp          # 格式转换
magick input.png -resize 800x600 output.png  # 缩放
magick input.png -quality 85 output.jpg     # 压缩
magick *.png -resize 50% thumbnail_%d.png    # 批量缩放
```

---

### 📄 poppler —— PDF 处理

**它是什么**：PDF 渲染库的命令行工具集。提供 `pdftotext`（PDF 转文本）、`pdfinfo`（PDF 信息查看）等工具。yazi 的 PDF 预览依赖它。

**安装**：

```powershell
# Scoop
scoop install poppler

# winget
winget install oschwartz10612.Poppler
```

**基本用法**：

```powershell
pdftotext input.pdf output.txt    # PDF 转文本
pdfinfo input.pdf                 # 查看 PDF 信息（页数、大小等）
pdftoppm input.pdf output -png    # PDF 转图片
```

---

### 🖼️ resvg —— SVG 渲染

**它是什么**：Rust 写的高性能 SVG 渲染器。yazi 的 SVG 预览依赖它。

**安装**：

```powershell
# Scoop
scoop install resvg
```

---

### 📦 7zip —— 压缩解压

**它是什么**：支持几乎所有压缩格式的命令行压缩工具。zip、7z、rar、tar.gz……

**安装**：

```powershell
# Scoop
scoop install 7zip

# winget
winget install 7zip.7zip
```

**基本用法**：

```powershell
7z a archive.7z folder/          # 压缩
7z x archive.7z                  # 解压（保持目录结构）
7z l archive.7z                  # 列出压缩包内容
7z a -mx=9 archive.7z folder/    # 最高压缩率
```

---

## 🔧 第五层：基础设施

### 📦 coreutils —— GNU 核心工具集

**它是什么**：将 Linux 的核心命令（`cp`、`mv`、`ls`、`head`、`tail`、`wc`、`sort`、`uniq`、`du` 等）移植到 Windows。PowerShell 有自己的命令，但参数语法不同；装了 coreutils 就能用标准的 GNU 语法。

**安装**：

```powershell
# Scoop
scoop install coreutils

# winget
winget install uutils.coreutils
```

**基本用法**：

```powershell
wc -l file.txt          # 统计行数
head -n 20 file.txt     # 查看前 20 行
tail -f log.txt         # 实时追踪日志
sort file.txt | uniq    # 排序去重
du -sh *                # 查看目录大小
```

---

### 🎋 lazygit —— Git 可视化界面

**它是什么**：Go 写的终端 Git UI。暂存、提交、推送、变基、解决冲突，全部用键盘操作，界面实时显示仓库状态。

**为什么用它**：`git rebase -i` 的交互式编辑器、`git stash` 的管理、复杂分支切换……这些操作命令行参数容易记混，lazygit 按 `?` 就能看所有快捷键。

**安装**：

```powershell
# Scoop
scoop install lazygit
```

> ⚠️ lazygit 目前 winget 上没有官方包，需用 Scoop 安装。

**基本用法**：

```powershell
lazygit    # 在 Git 仓库目录下启动
```

**核心快捷键**：

| 按键 | 功能 |
|------|------|
| `Space` | 暂存/取消暂存文件 |
| `c` | 提交（commit） |
| `P` | 推送（push） |
| `p` | 拉取（pull） |
| `?` | 显示帮助 |
| `3` | 切换到 stash 面板 |
| `4` | 切换到最近提交（reflog） |
| `b` | 分支管理 |
| `r` | 变基（rebase） |

<!-- 图片8：lazygit-ui.png —— lazygit 界面 -->

---

## 第四步：PowerShell 配置——让所有工具联动

以上工具装完后，需要统一配置 PowerShell 才能发挥作用。
以下配置写入 `$PROFILE` 文件（`notepad $PROFILE`）：

```powershell
# ============================================
# Starship Prompt
# ============================================
Invoke-Expression (&starship init powershell)

# ============================================
# zoxide 智能跳转
# ============================================
# 安装后添加此行，z 命令才可用
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# ============================================
# 别名配置
# ============================================
# lsd 替代 ls —— 彩色文件列表
Set-Alias -Name ls -Value lsd -Option AllScope -Force

# bat 替代 cat —— 语法高亮
Set-Alias -Name cat -Value bat -Option AllScope -Force
```

### 配置说明

**`zoxide` 的 `z` 命令**：

`Invoke-Expression (& { (zoxide init powershell | Out-String) })` 这行的作用是向 PowerShell 注册一个名为 `z` 的函数。每次你用 `cd` 切换目录时，zoxide 会在后台记录路径和使用频率。之后输入 `z 关键词` 就能模糊匹配跳转。

刚装好时没有历史数据，`z` 命令匹配不到任何目录。正常用 `cd` 访问几天后，zoxide 积累了足够的访问记录，`z` 命令就会非常精准。

**`lsd` 的别名**：

`Set-Alias -Name ls -Value lsd -Option AllScope -Force` 会把 PowerShell 内置的 `ls`（实际是 `Get-ChildItem` 的别名）覆盖为 `lsd`。如果你偶尔需要用回原版 `ls`，可以用 `Get-ChildItem` 直接调用。

**`bat` 的别名**：

同理，`Set-Alias -Name cat -Value bat -Option AllScope -Force` 覆盖了 PowerShell 的 `cat`（`Get-Content` 的别名）。需要原版时用 `Get-Content`。

> 💡 **配置文件用 Git 管理**：`$PROFILE` 的路径一般是 `C:\Users\你的用户名\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`。建议用 Git 仓库管理起来，换电脑时直接克隆恢复。

---

## 实战场景：当现代终端遇到命令行 AI

环境搭好后，日常和 Claude Code、GitHub Copilot CLI 等 AI 工具协作时，体验会有质的飞跃：

**AI 让你跳到某个目录改文件**

```powershell
# 以前
cd C:\Users\you\Documents\projects\myapp\src\components

# 现在
z myapp
```

**AI 输出了一段 JSON 配置**

```powershell
echo '{"name":"test","version":"1.0","deps":["react","vue"]}' | jq . | bat -l json
```

**AI 建议你搜索项目里的某个报错**

```powershell
rg "TypeError" --stats
```

**AI 让你看一下项目结构**

```powershell
lsd --tree -L 2
```

**AI 生成了 Git 操作指令，但你更想可视化操作**

```powershell
lazygit
```

**AI 让你找某个文件但忘了完整路径**

```powershell
fd | fzf
```

每个场景都比以前少敲几秒、少出错几次。积少成多，一天下来能省出不少时间。

---

## 参考资源

- 少数派《现代Unix命令行工具革命：30个必备替代品完整指南》——[原文链接](https://sspai.com/post/103469)
- [Nerd Fonts 官网](https://www.nerdfonts.com/)
- [Starship 官方文档](https://starship.rs/)
- [yazi 官方文档](https://yazi-rs.github.io/)
- [lazygit 官方文档](https://github.com/jesseduffield/lazygit)

---

## 写在最后

终端的复兴不是偶然。Claude Code、GitHub Copilot CLI、Cursor 的 Agent 模式……命令行正重新成为开发者与 AI 协作的最高效界面。

但一个丑陋、低效的终端，会成为你和 AI 之间的瓶颈——AI 生成的彩色输出你看到的是乱码，AI 建议的命令你找不到文件，AI 让你改的代码你看不出结构。

30 分钟，17 个工具，从零打造一个信息密度拉满、赏心悦目的现代 Windows 终端。
命令行 AI 时代，你的终端准备好了吗？

---

## 素材清单

| 类型 | 文件名 | 备注 |
|------|--------|------|
| 截图 | starship-tokyo-night.png | Tokyo Night 主题效果 |
| 截图 | starship-catppuccin.png | Catppuccin Powerline 主题效果 |
| 截图 | starship-gruvbox.png | Gruvbox Rainbow 主题效果 |
| 截图 | yazi-preview.png | yazi 文件预览效果 |
| 截图 | lazygit-ui.png | lazygit 界面 |
| 截图 | lsd-tree.png | lsd 树形输出 |
| 截图 | bat-highlight.png | bat 语法高亮效果 |
| 截图 | rg-search.png | ripgrep 搜索效果 |
