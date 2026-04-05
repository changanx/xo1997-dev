---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans for PySide6

## Overview

将设计文档转化为可执行的实现计划。计划应该足够详细，让执行者（可能是你自己或另一个开发者）能够按步骤完成，无需额外上下文。

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `docs/plans/{YYYY-MM-DD}-{topic}-plan.md`

## Worktree Setup

**REQUIRED:** Before writing the plan, ensure you are working in an isolated workspace.

1. Check if already in a worktree: `git worktree list`
2. If NOT in a worktree:
   - Create one: `git worktree add .claude/worktrees/{branch-name} -b {branch-name}`
   - Or use `/new-feature` command if available
3. If already in a worktree: proceed with plan creation

**Why this matters:** Plans should be written in isolation to prevent accidental commits to main branch.

## Plan Document Structure

```markdown
# {Feature Name} Implementation Plan

## Overview
- **Goal**: 一句话描述目标
- **Design Doc**: 链接到设计文档（如有）
- **Branch**: 分支名称

## Context
- 相关的现有代码
- 需要了解的背景知识
- 依赖的外部组件

## Tasks

### Task 1: {Task Name}
**Files:** 需要创建或修改的文件
**Test First:** 测试先行描述

Steps:
1. 具体步骤
2. ...

**Verification:** 如何验证完成

### Task 2: {Task Name}
...

## Testing Strategy
- 单元测试计划
- 集成测试计划
- 手动测试清单

## Risks
- 潜在风险
- 缓解措施
```

## PySide6 Project Structure

### Standard Directory Layout

```
project/
├── app/                           # Application package
│   ├── __init__.py
│   ├── main.py                    # Entry point
│   │
│   ├── common/                    # Shared utilities
│   │   ├── __init__.py
│   │   ├── config.py              # QConfig configuration
│   │   ├── signal_bus.py          # Global signal bus
│   │   └── style_sheet.py         # StyleSheet manager
│   │
│   ├── components/                # Reusable widgets
│   │   ├── __init__.py
│   │   ├── cards/
│   │   └── dialogs/
│   │
│   ├── view/                      # UI pages
│   │   ├── __init__.py
│   │   └── main_window.py
│   │
│   └── resource/                  # Static files
│       ├── qss/
│       └── images/
│
├── tests/                         # Tests
│   ├── conftest.py
│   ├── test_components/
│   └── test_views/
│
├── docs/                          # Documentation
│   └── plans/
│
├── requirements.txt
├── pytest.ini
└── README.md
```

## Task Breakdown Guidelines

### Granularity

每个任务应该在 **30分钟-2小时** 内完成。

```
❌ 太大: "实现用户管理模块"
✅ 合适: "创建 UserCard 组件"
✅ 合适: "添加用户列表接口"
✅ 合适: "实现用户搜索功能"
```

### Dependencies

明确任务间的依赖关系：

```
Task 1: 创建 UserCard 组件 (无依赖)
Task 2: 创建 UserList 组件 (依赖 Task 1)
Task 3: 创建用户管理页面 (依赖 Task 2)
```

### Test-First

每个实现任务都应包含测试步骤：

```markdown
### Task 1: 创建 UserCard 组件

**Files:**
- `app/components/user_card_widget.py` (create)
- `tests/test_components/test_user_card.py` (create)

**Test First:**
1. Write test for UserCard creation
2. Write test for setUser() method
3. Write test for clicked signal

Steps:
1. 创建测试文件，编写失败测试
2. 创建 UserCard 类，继承 CardWidget
3. 实现 _initUI, _initLayout, _connectSignals
4. 实现 setUser, clear 方法
5. 运行测试，确保通过

**Verification:**
- `pytest tests/test_components/test_user_card.py -v`
- 所有测试通过
```

## Common Task Types

### 1. New Component

```markdown
### Task: 创建 {Name}Widget 组件

**Files:**
- `app/components/{name}_widget.py`
- `tests/test_components/test_{name}.py`

**Test First:**
- 测试组件创建
- 测试属性设置
- 测试信号发射

Steps:
1. 创建测试文件
2. 创建组件类，继承 CardWidget/ QWidget
3. 实现 _initUI, _initLayout, _connectSignals
4. 添加属性和信号
5. 应用 StyleSheet

**Verification:**
- `pytest tests/test_components/test_{name}.py -v`
```

### 2. New Interface

```markdown
### Task: 创建 {Name}Interface 页面

**Files:**
- `app/view/{name}_interface.py`
- `app/view/main_window.py` (modify)
- `app/common/style_sheet.py` (modify)
- `tests/test_views/test_{name}_interface.py`

**Test First:**
- 测试页面创建
- 测试导航集成

Steps:
1. 创建测试文件
2. 创建 Interface 类，继承 ScrollArea
3. 实现 _initLayout, _connectSignals
4. 添加到 StyleSheet 枚举
5. 在 MainWindow 中注册导航
6. 创建 QSS 文件 (light/dark)

**Verification:**
- `pytest tests/test_views/test_{name}_interface.py -v`
- 手动启动应用，验证导航
```

### 3. Signal Integration

```markdown
### Task: 集成 SignalBus 信号

**Files:**
- `app/common/signal_bus.py` (modify)
- `app/view/main_window.py` (modify)

Steps:
1. 在 SignalBus 中定义新信号
2. 在 MainWindow 中连接信号
3. 在相关组件中发射信号
4. 编写信号测试

**Verification:**
- `pytest tests/ -v -k signal`
```

### 4. API Integration

```markdown
### Task: 集成 {API Name} API

**Files:**
- `app/services/{name}_service.py` (create)
- `app/components/{name}_widget.py` (modify)
- `tests/test_services/test_{name}.py` (create)

Steps:
1. 创建 Service 类
2. 实现异步请求方法
3. 添加错误处理
4. 在组件中调用 Service
5. 处理加载/错误状态

**Verification:**
- `pytest tests/test_services/test_{name}.py -v`
- 手动测试网络异常场景
```

## Document Verification

创建计划后，验证文件存在：

```bash
# 检查计划文件
ls docs/plans/{YYYY-MM-DD}-{topic}-plan.md
```

## Checklist

Before finalizing the plan:

- [ ] 每个任务有明确的文件列表
- [ ] 每个任务有测试先行步骤
- [ ] 每个任务有验证命令
- [ ] 任务依赖关系明确
- [ ] 估计总时间合理（通常 2-8 小时）
- [ ] 风险已识别

## Integration

**Called after:**
- **brainstorming** - 设计文档完成后

**Calls:**
- **executing-plans** - 执行计划
