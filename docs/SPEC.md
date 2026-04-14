# gmdiagram — 产品规格说明书

> 最后更新：2026-04-12

## 一、产品定位

`gmdiagram` 是一个 Claude Code 插件市场，包含两个独立插件：

- **gm-architecture**: 生成架构图、流程图、思维导图、ER 图、时序图等
- **gm-data-chart**: 生成数据可视化图表（柱状图、饼图、折线图、散点图等）

将自然语言描述转化为专业级图表。输出单文件 HTML（inline SVG + embedded CSS），无需 JavaScript，可直接在浏览器打开、用于文章嵌入或截图。

### 目标用户

- 技术自媒体作者（文章配图）
- 技术讲师 / 培训师（PPT 配图）
- AI 创客（项目展示）
- Claude Code Skill 生态用户

### 核心价值

**有设计感的图表表达** — 不是普通流程图工具，而是通过结构化 Schema + 设计系统，确保每次输出视觉一致、结构清晰。

---

## 二、功能范围

### 当前版本

| 维度 | 内容 |
|------|------|
| **图表类型** | Architecture、Flowchart、Mind Map、ER Diagram、Sequence Diagram（5 种） |
| **视觉风格** | Dark Professional、Hand-Drawn Sketch、Light Corporate、Cyberpunk Neon、Blueprint、Warm Cozy、Minimalist、Terminal Retro、Pastel Dream（9 种） |
| **输出格式** | HTML（默认）、SVG、Mermaid、PNG/PDF（via export script）（4 种） |
| **图标系统** | 150+ 图标，来自 Tabler Icons 和 Simple Icons |
| **生成方式** | 两步走：JSON Schema → 输出文件 |

### 输入

用户用自然语言描述系统。支持中英文：

- "Draw an architecture diagram of Chrome's multi-process system"
- "画一个微服务架构图，包含 API Gateway、用户服务、订单服务"

### 输出

- **HTML**：单文件，inline SVG + embedded CSS，零 JS 依赖，默认格式
- **SVG**：独立 SVG 文件，可用于矢量编辑器
- **Mermaid**：文本语法，可直接粘贴到 GitHub、Notion 等
- **PNG/PDF**：通过 `scripts/export.sh` 脚本导出

### 工作流程

```
自然语言描述 → [LLM 提取] → JSON Schema → [布局规则] → SVG 渲染 → 输出文件
```

1. **Schema 优先**：用户描述 → 中间 JSON Schema（结构化，每种图类型有独立 schema）
2. **渲染其次**：JSON Schema + 布局规则 + 风格模板 → 最终输出
3. **迭代修改**：修改 JSON 后重新渲染，可切换风格或输出格式

---

## 三、图表类型

| 类型 | 触发词 | 适用场景 |
|------|--------|----------|
| **Architecture** | system, layered, infrastructure, 架构图 | 系统分层、服务架构、平台能力 |
| **Flowchart** | flow, decision, process, algorithm, 流程图 | 决策树、流程步骤、算法 |
| **Mind Map** | brainstorm, hierarchy, feature tree, 思维导图 | 知识梳理、产品规划、学习路线 |
| **ER Diagram** | database, entity, table, schema, ER图 | 数据模型、数据库设计 |
| **Sequence** | API flow, message, interaction, 时序图 | 协议流程、API 调用链、服务交互 |

每种类型有独立的 Schema 文件和参考文档，详见 `references/` 目录。

---

## 四、设计系统

### 视觉风格

| 风格 | 背景 | 适用场景 |
|------|------|----------|
| **Dark Professional** | 深色 #020617 | 技术文章、文档 |
| **Hand-Drawn Sketch** | 浅米色 #faf8f5 | 教学、头脑风暴 |
| **Light Corporate** | 白色 #f8fafc | 商务演示 |
| **Cyberpunk Neon** | Catppuccin #11111b | 开发者工具、科技内容 |
| **Blueprint** | Nord #2e3440 | 工程规格、基础设施文档 |
| **Warm Cozy** | 暖米色 #f9f5eb | 教程、非技术受众 |
| **Minimalist** | 纯白 #ffffff | 技术文档、打印 |
| **Terminal Retro** | CRT 黑底 #0a0a0a | 开发者博客、趣味 |
| **Pastel Dream** | 薰衣草 #fef7ff | 教育、演示 |

### 颜色语义

| 类别 | 用途 | Dark 风格 fill | Dark 风格 stroke |
|------|------|---------------|-----------------|
| process | 进程/服务 | rgba(8,51,68,0.4) | #22d3ee (cyan) |
| module | 模块/组件 | rgba(6,78,59,0.4) | #34d399 (emerald) |
| data | 数据/存储 | rgba(76,29,149,0.4) | #a78bfa (violet) |
| infra | 基础设施 | rgba(120,53,15,0.3) | #fbbf24 (amber) |
| security | 安全边界 | rgba(136,19,55,0.4) | #fb7185 (rose) |
| channel | 通信通道 | rgba(251,146,60,0.3) | #fb923c (orange) |
| external | 外部系统 | rgba(30,41,59,0.5) | #94a3b8 (slate) |

---

## 五、技术架构

### 布局方案

采用 **SVG + foreignObject + CSS Flexbox** 混合布局：

- **SVG**：负责箭头、连接线、背景图形等矢量元素
- **foreignObject + CSS**：负责大多数文字、卡片、模块等需要精确对齐的组件
- **SVG 原生几何例外**：不适合矩形盒模型的节点继续使用纯 SVG 形状与文字，例如 flowchart 的 decision diamond 和 `io` parallelogram
- 避免让 LLM 手动计算绝对坐标（容易算错），改用 CSS 布局引擎

具体原则：

- **矩形类节点** 优先使用 `foreignObject + CSS`
- **特殊几何节点** 使用 SVG `<polygon>` / `<path>` + SVG `<text>`
- 不允许把矩形遮罩和裁剪后的特殊形状混用，否则会出现遮罩泄漏和视觉错位

### 目录结构

```
gmdiagram/
├── .claude-plugin/marketplace.json        # 市场定义
├── README.md                              # 项目总览
├── docs/
│   └── SPEC.md                            # 本文件 — 产品规格
├── tasks/
│   └── migration.md                       # 迁移任务跟踪
└── gm-architecture/
    ├── .claude-plugin/plugin.json     # Claude 插件清单
    ├── .codex-plugin/plugin.json      # Codex 插件清单
    ├── README.md                      # 插件概述（链接到 skill README）
    └── skills/
        └── gm-architecture/
            ├── SKILL.md               # 核心指令（Claude 读取）
            ├── README.md              # 完整用户文档
            ├── references/            # 技术参考文档
            │   ├── design-system.md
            │   ├── diagram-type-registry.md
            │   ├── icons-catalog.md
            │   ├── schema-architecture.md
            │   ├── diagram-architecture.md
            │   ├── layout-rules.md
            │   ├── component-templates.md
            │   ├── diagram-flowchart.md / layout-flowchart.md / components-flowchart.md
            │   ├── diagram-mindmap.md / layout-mindmap.md / components-mindmap.md
            │   ├── diagram-er.md / layout-er.md / components-er.md
            │   ├── diagram-sequence.md / layout-sequence.md / components-sequence.md
            │   ├── output-svg.md / output-mermaid.md / output-png-pdf.md
            │   ├── style-dark-professional.md
            │   ├── style-hand-drawn.md
            │   ├── style-light-corporate.md
            │   ├── style-cyberpunk-neon.md
            │   ├── style-blueprint.md
            │   ├── style-warm-cozy.md
            │   ├── style-minimalist.md
            │   ├── style-terminal-retro.md
            │   └── style-pastel-dream.md
            ├── assets/
            │   ├── schema-*.json      # 各类型的 JSON Schema
            │   ├── template-*.html    # 各风格的 HTML 模板
            │   └── examples/          # 示例 HTML + 截图
            └── scripts/
                └── export.sh          # PNG/PDF 导出脚本
```

---

## 六、质量标准

### 视觉质量

- 文字无重叠、无溢出
- 连接线不穿过无关模块
- 布局对称、居中
- ViewBox 适配内容，无大面积空白或裁切
- Legend 与实际使用的组件类型匹配

### 技术质量

- 每个 `foreignObject` 内的根 HTML 元素必须有 `xmlns="http://www.w3.org/1999/xhtml"`
- 组件使用模板中定义的 CSS 类（`.module`, `.type-X`, `.module-label` 等）
- flowchart 的 `io` 节点必须使用匹配的 SVG parallelogram mask + visible polygon，不能在矩形 mask 上叠加裁剪形状
- 连接线标签使用 `text-anchor="middle" dominant-baseline="central"`
- 所有用户文本经过 HTML 实体转义（`<`, `>`, `&`, `"`, `'`）

---

## 七、边界

### 始终这样做

- 先生成 JSON Schema，再生成输出文件（两步走）
- 每种风格有独立的模板文件
- 输出必须是单文件，可直接打开
- 使用定义的颜色系统，不自创新颜色
- 转义所有用户输入的文本

### 先问用户再做

- 架构类型不在支持列表中时
- 用户要求自定义颜色/品牌时
- 用户要求输出格式不在支持列表中时

### 永远不做

- 不生成需要 JavaScript 才能查看的图
- 不做交互式编辑器
- 不在输出 HTML 中引入 React/D3 等框架依赖
- 不把布局完全交给 LLM 推理（必须用 CSS 布局）

---

## 八、版本

- 市场版本：`0.6.2`
- 插件版本：`0.6.2`
- 新增：data-chart skill（bar chart）
- 许可证：MIT
