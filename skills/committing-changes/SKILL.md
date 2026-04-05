---
name: committing-changes
description: Use when creating git commits - provides conventional commit message format for PySide6 projects
---

# Committing Changes for PySide6

## Overview

编写规范的 commit message，保持清晰、可搜索的 git 历史。

**Announce at start:** "I'm using the committing-changes skill to write the commit message."

## Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Rules:**
- Type: lowercase, English
- Scope: lowercase, English, optional
- Description: **Chinese**, no period at end
- Body: **Chinese**, separated by blank line from description

## Types

| Type | 用途 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(user-card): 添加用户头像显示` |
| `fix` | Bug 修复 | `fix(signal): 修复信号连接顺序问题` |
| `docs` | 文档变更 | `docs: 更新 README 安装说明` |
| `style` | 代码格式（不影响逻辑） | `style: 修复代码缩进` |
| `refactor` | 重构（不是新功能也不是修复） | `refactor(card): 提取通用卡片组件` |
| `perf` | 性能优化 | `perf(list): 优化大列表渲染性能` |
| `test` | 测试相关 | `test(user-card): 添加点击信号测试` |
| `build` | 构建系统变更 | `build: 更新依赖版本` |
| `chore` | 其他杂项 | `chore: 清理无用导入` |

## Scopes for PySide6

| Scope | 模块 |
|-------|------|
| `main-window` | 主窗口 |
| `component` | 通用组件 |
| `card` | 卡片组件 |
| `dialog` | 对话框 |
| `interface` | 页面/界面 |
| `signal` | 信号/槽 |
| `theme` | 主题相关 |
| `style` | 样式表 |
| `config` | 配置 |
| `resource` | 资源文件 |
| `test` | 测试相关 |

**不需要 scope 的情况:**
- 根级别变更: `chore: 更新 .gitignore`
- 跨模块变更: `refactor: 统一信号命名规范`

## Description Rules

**必须:**
- 使用中文描述
- 不加句号结尾
- 具体明确，简洁有力
- 控制在 50 字以内

**示例:**
```
✅ feat(user-card): 添加用户头像显示
✅ fix(signal): 修复信号连接顺序问题
✅ refactor(card): 提取通用卡片组件

❌ feat(user-card): add user avatar
❌ feat(user-card): 添加用户头像显示。
❌ refactor: 一些修改
```

## Body (Optional)

**使用场景:**
- 变更原因不是显而易见
- 需要解释 WHY（而非 WHAT）

**示例:**
```
feat(user-card): 添加用户头像显示

使用 QPainter 实现圆形头像裁剪。
支持默认头像占位图。

- 添加 AvatarWidget 组件
- 集成到 UserCard
- 添加头像加载失败处理
```

## Complete Examples

### 新组件
```
feat(card): 创建 StatusCard 组件

用于显示状态统计信息的卡片组件。

- 支持图标、标题、数值显示
- 支持主题切换
- 添加单元测试
```

### Bug 修复
```
fix(theme): 修复深色主题下边框不可见

深色主题下 CardWidget 边框颜色与背景色太接近。
调整为更明显的灰色边框。
```

### 重构
```
refactor(signal): 统一信号命名规范

将所有信号重命名为过去时形式：
- clicked → clicked
- dataLoaded → data_loaded (内部信号)

无功能变更。
```

### 测试
```
test(user-card): 添加 UserCard 完整测试

添加测试覆盖:
- 组件创建
- 用户数据设置
- 点击信号
- 主题切换响应

覆盖率从 45% 提升至 90%。
```

## Pre-commit Checklist

提交前检查:

- [ ] 变更已暂存 (`git add`)
- [ ] 所有测试通过 (`pytest tests/ -v`)
- [ ] Type 正确
- [ ] Scope 合适（或不适用时省略）
- [ ] Description 使用中文，无句号结尾
- [ ] 变更原因不明确时添加了 Body

## Commit Frequency

**频繁提交，每次提交要小:**

```
✅ 推荐：多个小提交
feat(card): 创建 StatusCard 组件骨架
test(card): 添加 StatusCard 基础测试
feat(card): 实现 StatusCard 数值动画
test(card): 添加数值动画测试

❌ 避免：一个大提交
feat(card): 创建 StatusCard 组件包含所有功能和测试
```

## Integration

**Called by:**
- **test-driven-development** - GREEN 阶段后
- **executing-plans** - 每个任务完成后

**Workflow:**
```
完成变更 → 暂存文件 → 使用此技能 → 编写消息 → 提交
```
