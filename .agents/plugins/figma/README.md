# LuminClash - Figma MCP 集成指南

本目录为 LuminClash 专用的 **Figma MCP (Model Context Protocol)** 插件配置，用于将 Figma 设计稿直接连接到 AI 开发工作流中，实现高保真度设计转 Flutter 代码（Design-to-Code）。

---

## 1. 配置文件索引

| 配置路径 | 适用环境 / 客户端 | 说明 |
| :--- | :--- | :--- |
| [`.agents/plugins/figma/mcp_config.json`](file:///d:/LuminClash/.agents/plugins/figma/mcp_config.json) | Antigravity 插件系统 | 标准插件级 MCP 服务定义 |
| [`.agents/mcp_config.json`](file:///d:/LuminClash/.agents/mcp_config.json) | Antigravity 项目全局 | 项目根级 MCP 服务自动发现 |
| [`.vscode/mcp.json`](file:///d:/LuminClash/.vscode/mcp.json) | Antigravity IDE / VS Code / Cursor | 编辑器工作区级 MCP 规范定义 |

---

## 2. 核心连接方式

### 方式一：官方 Remote MCP 服务（默认推荐）

使用 Figma 官方托管的远程 MCP 服务端点：`https://mcp.figma.com/mcp`。

- **优势**：官方维护，具备完整的代码生成和设计上下文解析能力，支持 Code Connect，无需在本地启动 Node/Python 进程。
- **认证方式**：基于 **OAuth**。首次在支持 MCP 的客户端唤起时，系统会自动弹出浏览器登录窗口，点击 **"Agree and Allow Access"** 即可完成授权。

配置内容如下：
```json
{
  "mcpServers": {
    "figma": {
      "serverUrl": "https://mcp.figma.com/mcp"
    }
  }
}
```

*(在 VS Code / Cursor 的 `.vscode/mcp.json` 中格式为 `"type": "http", "url": "https://mcp.figma.com/mcp"`)*

---

### 方式二：本地 Stdio 模式（使用 Figma Personal Access Token）

如果您需要在无图形界面的 CI/CD 环境、或者希望使用 Personal Access Token (PAT) 直接进行无缝调用，可将配置切换为本地 stdio 进程模式（例如使用社区维护的高性能 MCP 服务）：

1. 在 Figma 网页端生成 **Personal Access Token**：
   - 登录 Figma -> 点击左上角头像 -> **Settings** -> **Personal Access Tokens** -> **Generate new token**；
   - 勾选 `File content` 等读取权限并复制 Token。

2. 修改 `.agents/plugins/figma/mcp_config.json`（或 `.agents/mcp_config.json`）：
```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@sethdouglasford/mcp-figma"],
      "env": {
        "FIGMA_PERSONAL_ACCESS_TOKEN": "YOUR_FIGMA_TOKEN_HERE"
      }
    }
  }
}
```

---

## 3. 在 LuminClash 中的使用规范与提示词

在针对 LuminClash 开发 UI 组件时，必须严格遵守 [`GEMINI.md`](file:///d:/LuminClash/GEMINI.md) 架构与设计规范：

1. **提取设计**：在对话中粘贴 Figma 节点链接并调用设计上下文：
   > *"请根据这个设计稿实现出站模式卡片：`https://www.figma.com/design/:id/:name?node-id=10:24`"*

2. **设计映射规则**：
   - **颜色令牌**：严禁硬编码 Hex 色值，一律自动映射为 `Theme.of(context).colorScheme`（Monet 语义 Token）；
   - **组件选型**：优先使用 Material 3 原生组件（`FloatingActionButton`、`SegmentedButton`、`LinearProgressIndicator` 等）；
   - **双端适配**：根节点包裹 `SafeArea`，标题配置 `maxLines: 1` 与 `TextOverflow.ellipsis`。
