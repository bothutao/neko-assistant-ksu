# neko-assistant-ksu
住在KernelSU里的猫娘。接入 DeepSeek，支持 Root 命令执行、多模态识图、原生联网、文件解析与长期记忆。

---

# 猫娘助手 (Neko Assistant KSU)

本项目是一个专为 Android KernelSU 及其分支 设计的 WebUI AI 模块。通过接入 DeepSeek API，实现与本地设备的深度交互。它将大模型能力与 Android 底层 Root 权限结合，提供了一个具备视觉识别、文档阅读、长期记忆以及执行系统命令的智能终端。

## 核心特性

### 1. 多模型智能路由与思考控制
- 支持 `deepseek-flash` 与 `deepseek-v4-pro` 两个核心模型。
- **Auto 模式**：系统会根据输入内容和附件情况，自动判断并路由到最合适的模型，平衡速度与深度。
- **思考等级调节**：在 Flash 和 Pro 按钮上支持切换思考深度（N: None, L: Low, H: High, M: Max），以控制模型推理时的 Token 消耗和响应速度。

### 2. 原生工具调用 (Tool Calls)
模型具备自主调用外部工具的能力，执行结果将自动回传至上下文供模型分析：
- **`search`**：使用 DeepSeek 独立搜索接口获取实时互联网信息。
- **`fetch_url`**：抓取指定 URL 的网页纯文本内容进行深度阅读。
- **`execute_command`**：申请执行 Android Shell 命令。出于安全考虑，所有命令执行前必须经过用户弹窗二次确认。

### 3. 长期记忆系统 (Memory)
为模型提供跨越会话的长期记忆能力，数据存储于本地纯文本文件：
- **`write_memory`**：记录用户偏好和重要信息，强制采用“关键词/标签”格式以节省 Token。
- **`search_memory`**：基于关键词匹配或读取最近记录，检索长期记忆。
- **`delete_memory`**：基于精确的时间戳抹除指定记忆，防止误删。

### 4. 多模态与文档解析
- **图像识别**：支持发送多张图片（自动进行压缩处理），自动路由至视觉模型（`deepseek-flash`）进行分析。
- **文档提取**：支持上传 `.txt`, `.md`, `.json`, `.csv`, `.py` 等代码/纯文本文件。
- **Office 解析**：集成 `officeparser` 库，支持读取 `.docx`, `.pptx`, `.xlsx`, `.pdf` 等格式的文本内容供模型阅读。

### 5. 高级渲染与排版
- 采用 `markdown-it` 引擎替换原生渲染，完美支持复杂表格（支持横向滑动）。
- 集成 `KaTeX` 与 `mhchem`，完美渲染数学公式与化学方程式。
- 集成 `Mermaid`，支持将代码块渲染为流程图、时序图等图表。
- 提供 HTML 代码块的沙盒隔离预览功能。

### 6. 底层架构与持久化
- **数据隔离**：配置文件与聊天历史记录不存放在易失的 WebView `localStorage` 中，而是存放于 `/data/adb/neko/` 目录下，不受模块更新或刷机影响。
- **绕过截断限制**：针对 `ksu.exec` 的长文本截断问题，采用 `sed` 逐行读取拼接的方案，确保大体积历史记录与命令输出完整无损。
- **上下文缓存优化**：对系统提示词与历史记录进行前缀缓存对齐，极大降低 API 请求的 Token 费用。

## 安装方法

1. 在 Releases 页面下载最新的 `.zip` 模块包。
2. 打开 KSU 管理器，进入模块页面，选择下载的 zip 包并刷入。
3. 重启设备。

## 配置说明

首次开机后，系统会自动在 `/data/adb/neko/` 目录下生成 `config.conf` 配置文件。请使用具有 Root 权限的文件管理器（如 MT 管理器）编辑该文件：

```ini
# 猫娘助手配置。修改后回 WebUI 点「重载配置」。
API_KEY=你的DeepSeek_API_Key
API_URL=https://api.deepseek.com/chat/completions
SEARCH_URL=https://api.deepseek.com/v1/tools/search
FETCH_URL=https://api.deepseek.com/v1/tools/fetch
MODEL_FLASH=deepseek-flash
MODEL_PRO=deepseek-v4-pro
```

填写 `API_KEY` 后保存文件，回到模块的 WebUI 界面，点击右上角菜单中的“重载配置”即可生效。

## 界面操作指南

- **输入区**：支持多行文本输入，回车换行，点击“发送”进行提交。包含发送冷却机制，防止连点。
- **附件按钮**：点击回形针图标可同时选择多张图片或多个文档（单次上限 10 个）。
- **菜单栏**：点击左上角汉堡菜单图标展开。
  - `Auto` / `Flash` / `Pro`：切换模型调度模式。
  - `刷新模块简介`：调用轻量 API 随机生成一句状态并写入 KSU 模块描述。
  - `重载配置`：修改 `config.conf` 后需点击此按钮重新读取配置。
  - `关于作者`：展示项目信息、赞助渠道与开源协议。

## 数据存储

所有核心数据均位于 `/data/adb/neko/` 目录下：
- `config.conf`：模型密钥及接口配置。
- `history.b64`：经过 Base64 分片处理的完整聊天记录。
- `memory.txt`：长期记忆存储文件。

如需彻底清空猫娘的记忆或配置，只需使用 Root 文件管理器删除该目录下的对应文件即可。

## 开源协议

本项目基于 CC BY-NC-SA 4.0 协议开源。
允许个人自由修改与分发，但严禁任何形式的商业倒卖。基于此项目的二次开发必须保留原作者署名（bot_hutao），且必须以相同协议共享。
