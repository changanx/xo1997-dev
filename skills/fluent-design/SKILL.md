---
name: fluent-design
description: Use when understanding Fluent Design principles and PyQt-Fluent-Widgets component selection - provides design philosophy, component types, and best practices
---

# Fluent Design 与 PyQt-Fluent-Widgets

## Fluent Design System

微软 Fluent Design System 是一套现代 UI 设计语言，基于五大核心原则：

### 五大设计原则

| 原则 | 英文 | 描述 | PyQt-Fluent-Widgets 体现 |
|------|------|------|--------------------------|
| **光感** | Light | 光影效果营造深度和层次 | 阴影、高亮边框 |
| **深度** | Depth | 层次感，元素间的关系 | Acrylic、Mica 效果 |
| **动效** | Motion | 流畅自然的过渡动画 | 悬停、点击动画 |
| **材质** | Material | 物理感的视觉纹理 | 透明、模糊效果 |
| **缩放** | Scale | 从小元素到大画布的一致性 | 响应式布局支持 |

---

## PyQt-Fluent-Widgets 组件体系

### 核心优势

| 特性 | 说明 |
|------|------|
| **开箱即用的 Fluent 风格** | 无需手动编写 QSS |
| **自动主题切换** | 内置 light/dark 主题支持 |
| **丰富的高层组件** | 窗口、导航、卡片等 |
| **动画效果内置** | 悬停、点击、过渡动画 |

### 与原生 Qt 的区别

```python
# 原生 Qt
from PySide6.QtWidgets import QPushButton, QLabel, QWidget

btn = QPushButton("按钮")
label = QLabel("标签")
# 需要手动编写 QSS 实现 Fluent 风格

# PyQt-Fluent-Widgets
from qfluentwidgets import PushButton, BodyLabel, CardWidget

btn = PushButton("按钮")      # 自动 Fluent 风格
label = BodyLabel("标签")     # 自动跟随主题
card = CardWidget()           # 自动悬停动画
```

---

## 组件类型选择指南

### 窗口类型

| 类型 | 特点 | 适用场景 |
|------|------|----------|
| `FluentWindow` | 侧边导航栏，支持展开/折叠 | 标准桌面应用（推荐） |
| `MSFluentWindow` | 顶部导航栏 | 商店风格应用 |
| `SplitFluentWindow` | 分离式标题栏 | 特殊布局需求 |

### 卡片类型

| 类型 | 特点 | 适用场景 |
|------|------|----------|
| `CardWidget` | 悬停高亮、点击动画 | 可交互卡片（推荐） |
| `SimpleCardWidget` | 无动画 | 静态展示卡片 |
| `ElevatedCardWidget` | 阴影+悬浮效果 | 强调型卡片 |
| `HeaderCardWidget` | 带标题头 | 分组展示 |

### 输入组件

| 组件 | 用途 | 特点 |
|------|------|------|
| `LineEdit` | 单行输入 | 支持清除按钮、搜索图标 |
| `TextEdit` | 多行输入 | 支持 Fluent 样式 |
| `ComboBox` | 下拉选择 | 支持搜索、多选 |
| `SpinBox` | 数值输入 | 支持 Fluent 样式 |
| `CheckBox` | 复选框 | 三态支持 |
| `RadioButton` | 单选按钮 | Fluent 样式 |
| `TogglePushButton` | 切换按钮 | 滑块样式 |
| `Slider` | 滑块 | 流畅动画 |

### 按钮类型

| 组件 | 样式 | 适用场景 |
|------|------|----------|
| `PushButton` | 标准按钮 | 主要操作 |
| `PrimaryPushButton` | 强调按钮 | 主要确认操作 |
| `ToolButton` | 图标按钮 | 工具栏 |
| `TransparentToolButton` | 透明图标按钮 | 低干扰操作 |
| `HyperlinkButton` | 超链接按钮 | 导航链接 |
| `DropDownPushButton` | 下拉按钮 | 展开菜单 |

### 信息展示

| 组件 | 用途 |
|------|------|
| `TitleLabel` | 大标题 |
| `SubtitleLabel` | 副标题 |
| `BodyLabel` | 正文 |
| `CaptionLabel` | 说明文字 |
| `StrongBodyLabel` | 强调正文 |
| `IconWidget` | 图标显示 |

### 反馈组件

| 组件 | 用途 |
|------|------|
| `InfoBar` | 顶部通知条 |
| `InfoBarIcon` | 带图标的通知 |
| `StateToolTip` | 状态提示 |
| `ProgressRing` | 圆形进度 |
| `ProgressBar` | 条形进度 |
| `MessageBox` | 消息对话框 |
| `Dialog` | 对话框 |

### 导航组件

| 组件 | 用途 |
|------|------|
| `Pivot` | 标签页切换 |
| `SegmentedWidget` | 分段控件 |
| `BreadcrumbBar` | 面包屑导航 |
| `NavigationInterface` | 侧边导航栏 |

---

## 设计原则应用

### 1. 一致性

```python
# 好：使用统一的 Fluent 组件
from qfluentwidgets import PushButton, PrimaryPushButton

save_btn = PrimaryPushButton("保存")    # 主要操作用 Primary
cancel_btn = PushButton("取消")         # 次要操作用普通

# 坏：混用原生和 Fluent 组件
from PySide6.QtWidgets import QPushButton
from qfluentwidgets import PrimaryPushButton

save_btn = PrimaryPushButton("保存")    # Fluent 风格
cancel_btn = QPushButton("取消")         # 原生风格，不一致
```

### 2. 层次感

```python
from qfluentwidgets import TitleLabel, SubtitleLabel, BodyLabel, CaptionLabel

# 标题层次
title = TitleLabel("设置")
subtitle = SubtitleLabel("外观")
body = BodyLabel("选择应用主题")
hint = CaptionLabel("主题将在重启后生效")
```

### 3. 反馈

```python
from qfluentwidgets import InfoBar, InfoBarPosition

# 操作反馈
InfoBar.success(
    title="保存成功",
    content="配置已保存",
    orient=Qt.Horizontal,
    isClosable=True,
    position=InfoBarPosition.TOP,
    duration=2000,
    parent=self
)
```

### 4. 效率

```python
from qfluentwidgets import SearchLineEdit

# 搜索输入提供即时反馈
search_box = SearchLineEdit()
search_box.setPlaceholderText("搜索...")
search_box.setClearButtonEnabled(True)
```

---

## 常用图标

```python
from qfluentwidgets import FluentIcon as FIF

# 常用图标
FIF.HOME           # 首页
FIF.SETTING        # 设置
FIF.SEARCH         # 搜索
FIF.ADD            # 添加
FIF.EDIT           # 编辑
FIF.DELETE         # 删除
FIF.SAVE           # 保存
FIF.CLOSE          # 关闭
FIF.BACK           # 返回
FIF.FORWARD        # 前进
FIF.UP             # 上
FIF.DOWN           # 下
FIF.FOLDER         # 文件夹
FIF.DOCUMENT       # 文档
FIF.PHOTO          # 图片
FIF.VIDEO          # 视频
FIF.MUSIC          # 音乐
FIF.PERSON         # 用户
FIF.BRUSH          # 画笔/主题
FIF.INFO           # 信息
FIF.QUESTION       # 帮助
FIF.WARNING        # 警告
FIF.ERROR          # 错误
FIF.COMPLETE       # 完成
```

---

## 最佳实践清单

- [ ] 优先使用 PyQt-Fluent-Widgets 组件而非原生 Qt
- [ ] 窗口使用 FluentWindow 作为基类
- [ ] 卡片使用 CardWidget 获取自动动画效果
- [ ] 文本使用语义化 Label（Title/Subtitle/Body/Caption）
- [ ] 主要操作使用 PrimaryPushButton
- [ ] 使用 FluentIcon 枚举而非自定义图标路径
- [ ] 操作后提供 InfoBar 反馈
- [ ] 测试 light 和 dark 两种主题下的显示效果
