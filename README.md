# Windows 终端现代化一键配置脚本

一个 PowerShell 脚本，帮你把 Windows 终端从默认的朴素外观，一键升级为信息密度拉满、赏心悦目的现代终端。

## 功能概览

- **Nerd Font 安装** — 自动下载安装 0xProto Nerd Font（per-user 方式，无需管理员权限）
- **17 个 CLI 工具批量安装** — 支持 Scoop（推荐）和 winget 两种包管理器
- **Starship 主题配置** — 内置 Catppuccin Powerline / Gruvbox Rainbow / Tokyo Night 三款主题
- **PowerShell Profile 自动配置** — 自动注册 Starship、zoxide、别名，带标记块方便清理
- **一键恢复** — 支持 `-Restore` 参数恢复到配置前的默认状态

## 安装的工具清单

| 分类 | 工具 | 用途 |
|------|------|------|
| 外观与交互 | starship | 命令行提示符 |
| 外观与交互 | lsd | 彩色文件列表 |
| 导航与搜索 | zoxide | 智能目录跳转（`z` 命令） |
| 导航与搜索 | fzf | 模糊搜索神器 |
| 导航与搜索 | fd | 快速文件查找 |
| 查看与阅读 | bat | 语法高亮的 cat |
| 查看与阅读 | ripgrep | 超高速文本搜索 |
| 查看与阅读 | jq | JSON 处理器 |
| 查看与阅读 | jd | JSON Diff |
| 查看与阅读 | tldr | 简化版命令手册 |
| 查看与阅读 | yazi | 终端文件管理器 |
| 处理与转换 | ffmpeg | 音视频处理 |
| 处理与转换 | imagemagick | 图片处理 |
| 处理与转换 | poppler | PDF 工具集 |
| 处理与转换 | resvg | SVG 渲染 |
| 处理与转换 | 7zip | 压缩解压 |
| 基础设施 | coreutils | GNU 核心工具 |
| 基础设施 | lazygit | Git 可视化界面 |

## 快速开始

### 前置条件

- Windows 10 1809+ 或 Windows 11
- PowerShell 5.1+（Windows 自带）
- 无需管理员权限

### 第一步：解除脚本执行限制

Windows 默认禁止运行 PowerShell 脚本。打开 PowerShell，先执行（仅影响当前用户，无需管理员）：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

输入 `Y` 确认。只需执行一次，永久生效。

> **`RemoteSigned` 不会让远端脚本随意执行。** 它的含义是：
> - 本地脚本（你自己写的、U 盘拷过来的）→ 直接运行，不拦截
> - 从网络下载的脚本（浏览器下载的、带 Windows 安全标记的）→ 必须有受信任的数字签名才能运行
>
> 这是微软推荐的安全策略，比 `Unrestricted` 安全得多，不会降低系统安全性。

### 第二步：运行脚本

从 GitHub 下载或 U 盘拷贝 `setup-terminal.ps1`，然后执行：

```powershell
# 交互式安装（可选择包管理器和主题）
.\setup-terminal.ps1

# 跳过所有确认，使用推荐默认值（Scoop + Catppuccin Powerline）
.\setup-terminal.ps1 -Force
```

### 安装后

1. 打开 Windows Terminal → 设置 → 配置文件 → 默认值 → 外观 → 字体
2. 选择 **0xProto Nerd Font**
3. 重启终端

## 恢复默认配置

```powershell
# 交互式恢复（可选择卸载范围）
.\setup-terminal.ps1 -Restore

# 全部恢复（不逐项确认）
.\setup-terminal.ps1 -Restore -Force
```

恢复操作会：
- 清理 PowerShell Profile 中的脚本配置块
- 移除 Starship 配置文件
- 移除 per-user 安装的 0xProto 字体
- 可选卸载通过 Scoop/winget 安装的 CLI 工具
- 列出所有 Profile 备份文件供手动恢复

## 参数说明

| 参数 | 说明 |
|------|------|
| `-Force` | 跳过所有确认，使用推荐默认值（Scoop + Catppuccin Powerline） |
| `-Restore` | 恢复到脚本配置前的默认状态 |

## 工作原理

1. **字体** — 从 GitHub Releases 下载 0xProto Nerd Font，通过 per-user 方式安装到 `$env:LOCALAPPDATA\Microsoft\Windows\Fonts` 并注册到注册表，无需管理员权限
2. **工具** — 根据 Scoop 或 winget 逐个安装，失败的工具有明确提示
3. **主题** — 使用 `starship preset` 命令直接生成主题配置到 `~/.config/starship.toml`
4. **Profile** — 使用标记块 `# >>> setup-terminal.ps1 >>>` 包裹配置内容，方便恢复时精确移除
5. **备份** — 修改 Profile 前自动备份，文件名带时间戳

## 文件说明

```
.
├── setup-terminal.ps1   # 一键配置脚本
├── draft.md             # 配套文章草稿（详细的工具介绍和使用教程）
└── README.md            # 本文件
```

## 相关资源

- [Nerd Fonts 官网](https://www.nerdfonts.com/)
- [Starship 官方文档](https://starship.rs/)
- [yazi 官方文档](https://yazi-rs.github.io/)
- [lazygit 官方仓库](https://github.com/jesseduffield/lazygit)
- [Scoop 官网](https://scoop.sh/)

## 许可证

MIT License
