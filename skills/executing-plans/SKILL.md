---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans for PySide6

## Overview

加载计划，按步骤执行，报告完成。

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## Immediate Action

**Upon invoking this skill, you MUST immediately:**

1. Create a TodoWrite with the following tasks:
```
1. [pending] 加载计划文件
2. [pending] 审阅计划并确认理解
3. [pending] 执行所有任务
4. [pending] 运行全部测试
5. [pending] 调用 verification-before-completion
6. [pending] 调用 finishing-a-development-branch
```

2. Mark the first task as in_progress and load the plan

## Document Paths

**计划文件路径**:
```
docs/specs/{YYYY-MM-DD}-{topic}/plan.md
```

## The Process

### Step 1: Load and Review Plan

1. 读取计划文件：`docs/specs/{YYYY-MM-DD}-{topic}/plan.md`
2. 理解每个任务的目标和步骤
3. 如有疑问：在开始前提出
4. 无疑问：创建 TodoWrite 并开始执行

### Step 2: Execute Tasks

对每个任务：

1. 标记为 in_progress
2. **严格按步骤执行**
3. 运行验证命令
4. 标记为 completed

### Step 3: Complete Development

所有任务完成后：

1. 运行全部测试：`pytest tests/ -v`
2. 使用 verification-before-completion 技能
3. 调用 finishing-a-development-branch 技能完成集成

## When to Stop and Ask

**立即停止并询问：**
- 遇到阻塞（依赖缺失、测试失败、指令不清）
- 计划有重大缺陷
- 不理解某个步骤
- 验证反复失败

**不要猜测，先询问。**

## Task Execution Flow

```
┌─────────────────────────────────────────────────────┐
│                    Load Plan                        │
└─────────────────────┬───────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────┐
│              Review & Create TodoWrite              │
└─────────────────────┬───────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────┐
│              For Each Task:                         │
│  ┌───────────────────────────────────────────────┐  │
│  │ 1. Mark in_progress                           │  │
│  │ 2. Execute steps exactly                      │  │
│  │ 3. Run verification                           │  │
│  │ 4. Mark completed                             │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────┐
│              Run All Tests                          │
└─────────────────────┬───────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────┐
│              Verification Before Completion         │
└─────────────────────┬───────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────┐
│              Report Complete                        │
└─────────────────────────────────────────────────────┘
```

## Verification Commands

### Per-Task Verification

```bash
# 单个测试文件
pytest tests/test_components/test_user_card.py -v

# 单个测试类
pytest tests/test_components/test_user_card.py::TestUserCard -v

# 单个测试方法
pytest tests/test_components/test_user_card.py::TestUserCard::test_set_user -v
```

### Full Verification

```bash
# 运行所有测试
pytest tests/ -v

# 带覆盖率
pytest tests/ --cov=app --cov-report=term

# 只运行组件测试
pytest tests/test_components/ -v

# 只运行视图测试
pytest tests/test_views/ -v
```

### Application Verification

```bash
# 启动应用（手动验证）
python app/main.py
```

## Common Task Patterns

### Creating a Component

```python
# 1. 创建测试文件
# tests/test_components/test_{name}.py

import pytest
from pytestqt.qtbot import QtBot

from app.components.{name}_widget import {Name}Widget


class Test{Name}Widget:
    
    @pytest.fixture
    def widget(self, qtbot: QtBot):
        w = {Name}Widget()
        qtbot.addWidget(w)
        return w
    
    def test_creation(self, widget):
        assert widget is not None


# 2. 运行测试（应该失败）
# pytest tests/test_components/test_{name}.py -v

# 3. 创建组件
# app/components/{name}_widget.py

from qfluentwidgets import CardWidget

class {Name}Widget(CardWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

# 4. 运行测试（应该通过）
# pytest tests/test_components/test_{name}.py -v
```

### Creating an Interface

```python
# 1. 创建测试文件
# tests/test_views/test_{name}_interface.py

# 2. 创建界面
# app/view/{name}_interface.py

from qfluentwidgets import ScrollArea

class {Name}Interface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        # ...

# 3. 更新 StyleSheet
# app/common/style_sheet.py

class StyleSheet(StyleSheetBase, Enum):
    {NAME}_INTERFACE = "{name}_interface"

# 4. 注册导航
# app/view/main_window.py

self.addSubInterface(
    self.{name}Interface,
    FIF.{ICON},
    self.tr('{Name}')
)

# 5. 创建 QSS 文件
# resource/qss/light/{name}_interface.qss
# resource/qss/dark/{name}_interface.qss
```

## Integration

**Required workflow skills:**
- **test-driven-development** - 每个实现任务的 RED-GREEN 循环
- **verification-before-completion** - 完成前验证（必须调用）
- **finishing-a-development-branch** - 完成后集成（必须调用）

**Called after:**
- **writing-plans** - 创建计划后

**Calls:**
- **test-driven-development** - 每个实现任务
- **committing-changes** - 提交代码
- **verification-before-completion** - 所有任务完成后
- **finishing-a-development-branch** - 验证通过后

## Remember

- 先审阅计划，再开始执行
- 严格按步骤执行
- 不要跳过验证
- 遇到阻塞立即停止，不要猜测
- 每个任务完成后提交（使用 conventional commits）
- **所有任务完成后必须调用 verification-before-completion**
- **验证通过后必须调用 finishing-a-development-branch**
