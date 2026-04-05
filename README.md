# PySide6-Dev Plugin

PySide6 桌面客户端开发工作流插件，基于 PyQt-Fluent-Widgets 最佳实践。

## 核心特性

| 特性 | 描述 |
|------|------|
| **设计优先** | 没有批准设计不编写代码 |
| **测试驱动** | 强制执行 RED-GREEN-REFACTOR 循环 |
| **证据驱动验证** | 没有验证证据不声称完成 |
| **组件化开发** | 可复用组件模式指南 |

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| PySide6 | 6.x | Qt 绑定 |
| PyQt-Fluent-Widgets | 1.11.x | Fluent Design UI 组件 |
| SQLite | 3.x | 本地数据存储 |
| pytest | 7.x | 测试框架 |
| pytest-qt | 4.x | Qt 测试工具 |

## 安装

```bash
/plugin pyside6-dev
```

## 工作流程

```
用户需求 → brainstorming (需求探索) → writing-plans (实现计划)
                                          │
                              ┌───────────┴───────────┐
                              │                       │
                              ▼                       ▼
                      TDD 实现 → 代码审查 → 验证 → 完成
```

## 技能库

### 流程技能

| 技能 | 用途 | 类型 |
|------|------|------|
| **brainstorming** | 需求探索与设计 | 刚性 |
| **writing-plans** | 将设计转化为实现计划 | 刚性 |
| **executing-plans** | 执行实现计划 | 刚性 |
| **test-driven-development** | 测试驱动开发 | 刚性 |
| **systematic-debugging** | 系统化调试 | 刚性 |
| **verification-before-completion** | 完成前验证 | 刚性 |

### 工程规范技能

| 技能 | 用途 |
|------|------|
| **using-git-worktrees** | 隔离开发环境 |
| **committing-changes** | 提交规范 |
| **finishing-a-development-branch** | 分支完成流程 |

### PySide6 专属技能

| 技能 | 用途 |
|------|------|
| **fluent-design** | Fluent Design 原则与组件选择 |
| **theming** | 主题管理、StyleSheet、Mica 效果 |
| **project-structure** | 项目结构规范 |
| **component-development** | 组件开发模式 |
| **testing-patterns** | pytest-qt 测试模式和最佳实践 |
| **local-storage** | SQLite 本地数据存储 |

### 命令

| 命令 | 用途 |
|------|------|
| `/new-component` | 创建新组件 |
| `/new-interface` | 创建新页面 |

## 项目结构

```
project/
├── app/
│   ├── common/          # 公共组件 (config, signal_bus, style_sheet)
│   ├── components/      # 可复用 UI 组件
│   ├── view/            # UI 页面
│   └── resource/        # 静态资源
├── tests/               # 测试
├── docs/                # 文档
└── requirements.txt
```

## 核心模式

### Signal Bus 模式

```python
# common/signal_bus.py
from PySide6.QtCore import QObject, Signal

class SignalBus(QObject):
    navigateTo = Signal(str)
    themeChanged = Signal(str)

signalBus = SignalBus()
```

### 主窗口模式

```python
# view/main_window.py
from qfluentwidgets import FluentWindow

class MainWindow(FluentWindow):
    def __init__(self):
        super().__init__()
        self.initWindow()
        self.initNavigation()
        self.connectSignals()
```

### 组件模式

```python
class MyCard(CardWidget):
    clicked = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._initUI()
        self._initLayout()
```

## 验证安装

启动新会话，尝试触发技能：

```
"帮我开发一个用户卡片组件"  → brainstorming → TDD → verification
"创建一个设置页面"          → project-structure → component-development
```

## 文件结构

```
pyside6-dev/
├── .claude-plugin/
│   ├── plugin.json       # 插件配置
│   └── marketplace.json  # 市场信息
├── skills/               # 技能库
│   ├── using-pyside6-dev/
│   ├── brainstorming/
│   ├── writing-plans/
│   ├── executing-plans/
│   ├── test-driven-development/
│   ├── systematic-debugging/
│   ├── verification-before-completion/
│   ├── using-git-worktrees/
│   ├── committing-changes/
│   ├── finishing-a-development-branch/
│   ├── component-development/
│   ├── project-structure/
│   ├── testing-patterns/
│   ├── fluent-design/
│   ├── theming/
│   └── local-storage/
├── commands/             # 斜杠命令
│   ├── new-component.md
│   └── new-interface.md
└── README.md
```

## 许可证

MIT License
