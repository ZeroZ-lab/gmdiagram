# Skills 优化报告

**审计日期**: 2026-04-14
**针对**: architecture-diagram & data-chart SKILL.md

---

## 🔴 Critical Issues（需在 SKILL.md 中修复）

### 1. 缺少 Metadata 版本规范

**问题**: 示例中的 metadata.version 不一致（1.0, 1.0.0, 0.6.0）

**SKILL.md 现状**: 未定义 metadata 中 version 字段的取值规范

**修复建议** - 在 SKILL.md 的 "Two-Step Generation Process" 部分添加：

```markdown
### Metadata Version Field

生成 JSON 时，metadata.version 必须遵循以下规则：
- 使用与插件版本一致的值（当前为 "0.6.1"）
- 格式: `major.minor.patch` (语义化版本)
- 禁止使用的值: "1.0", "1.0.0"（这些是占位符版本）

示例:
```json
"metadata": {
  "author": "gmdiagram",
  "date": "2026-04-14",
  "version": "0.6.1"
}
```
```

---

### 2. 缺少输出路径规范

**问题**: HTML 文件被错误地生成到 images/ 目录

**SKILL.md 现状**: 未明确指定 HTML/JSON 文件的输出目录

**修复建议** - 在 SKILL.md 开头添加：

```markdown
## Output Directory Structure

所有示例文件必须输出到正确的目录：

```
assets/examples/
├── {example-name}.json      # JSON schema 文件
├── {example-name}.html      # HTML 渲染输出（与 JSON 同名）
└── images/                  # 仅用于存放预览截图（*.png, *.jpg）
    └── {example-name}-preview.png
```

**禁止行为**:
- ❌ 不要将 HTML 文件放入 images/ 目录
- ❌ 不要在 images/ 目录生成任何非图片文件
- ✅ HTML/JSON 必须放在 examples/ 根目录
```

---

## 🟡 Important Issues（建议添加的规范）

### 3. 缺少 HTML lang 属性规范

**问题**: 示例中 lang 属性不一致（en/zh-CN）

**修复建议** - 在 "Step 2: Generate Output" 部分添加：

```markdown
### HTML Language Attribute

根据内容语言设置正确的 lang 属性：
- 英文内容 → `<html lang="en">`
- 中文内容 → `<html lang="zh-CN">`
- 日文内容 → `<html lang="ja">`

检测方法: 如果 title/subtitle/labels 中包含中文字符，使用 zh-CN
```

---

### 4. 缺少文件命名规范

**修复建议** - 添加命名规范章节：

```markdown
## File Naming Convention

示例文件名必须使用 kebab-case（短横线连接的小写字母）：

✅ 正确的命名:
- `chrome-architecture.json`
- `quarterly-revenue.json`
- `team-skills-radar.json`

❌ 错误的命名:
- `chromeArchitecture.json` (camelCase)
- `QuarterlyRevenue.json` (PascalCase)
- `team_skills.json` (snake_case)
- `chrome architecture.json` (包含空格)

文件名结构: `{context}-{type}[-{variant}].{ext}`
- context: 场景描述（chrome, saas, ecommerce）
- type: 图表类型（architecture, flowchart, gantt）
- variant: 可选变体（cyberpunk, minimalist, dark）
```

---

## 🟢 Suggestions（可选增强）

### 5. 缺少示例覆盖度检查清单

**修复建议** - 在 Quality Checklist 中添加：

```markdown
### Example Completeness (for example generation)

- [ ] 每种 diagramType 至少有一个示例
- [ ] 每种 visual style 至少有一个示例
- [ ] 示例包含 JSON + HTML 成对出现
- [ ] 示例文件名符合命名规范
- [ ] metadata 字段完整且版本正确
```

---

### 6. 缺少 schema 变更同步机制

**问题**: 当 schema 更新时，示例可能过时

**修复建议** - 添加维护指南：

```markdown
## Schema-Example Synchronization

当 schema 发生变更时：

1. **版本 bump**: 更新 SCHEMA_VERSION 常量
2. **示例验证**: 运行测试验证所有示例 JSON 仍符合新 schema
3. **必要更新**: 如果 schema 破坏性变更，同步更新示例文件
4. **metadata 更新**: 同步更新示例的 version 字段

测试命令:
```bash
./tasks/test.sh  # 验证所有示例
```
```

---

### 7. 增加自动化检查工具

**修复建议** - 在 scripts/ 目录添加验证脚本：

```markdown
## Validation Scripts

使用提供的脚本验证示例质量：

```bash
# 验证 JSON schema 合规性
./scripts/validate-examples.sh

# 检查 metadata 版本一致性
./scripts/check-metadata.sh

# 检查文件命名规范
./scripts/check-naming.sh
```
```

---

## 修复优先级

| 优先级 | 问题 | 工作量 | 影响 |
|--------|------|--------|------|
| P0 | Metadata 版本规范 | 5 分钟 | 高 |
| P0 | 输出路径规范 | 5 分钟 | 高 |
| P1 | HTML lang 规范 | 10 分钟 | 中 |
| P1 | 文件命名规范 | 10 分钟 | 中 |
| P2 | 示例覆盖度检查 | 20 分钟 | 低 |
| P2 | Schema 同步机制 | 30 分钟 | 低 |
| P3 | 自动化检查工具 | 1 小时 | 低 |

---

## 具体修复位置

### architecture-diagram/SKILL.md

1. **Line 18**（front matter 后）: 添加 "Output Directory Structure" 章节
2. **Line 220**（Two-Step Generation Process 前）: 添加 "Metadata Version Field" 章节
3. **Line 274**（Step 2 中）: 添加 "HTML Language Attribute" 小节
4. **Line 316**（Quality Checklist 前）: 添加 "File Naming Convention" 章节
5. **Line 333**（Quality Checklist 中）: 添加示例完整性检查项

### data-chart/SKILL.md

1. **Line 15**（front matter 后）: 添加 "Output Directory Structure" 章节
2. **Line 85**（Two-Step Generation Process 前）: 添加 "Metadata Version Field" 章节
3. **Line 155**（Step 2 中）: 添加 "HTML Language Attribute" 小节
4. **Line 200**（Quality Checklist 前）: 添加 "File Naming Convention" 章节

---

## 验证清单

修复后验证:
- [ ] 重新生成示例，检查 metadata.version 是否为 "0.6.1"
- [ ] 检查 HTML 输出路径是否正确（不在 images/ 目录）
- [ ] 运行 test.sh 验证所有示例通过
- [ ] 检查所有文件名符合 kebab-case
