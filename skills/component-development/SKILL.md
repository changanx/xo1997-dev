---
name: component-development
description: Use when creating reusable UI components - provides patterns for widgets, signals, properties, and layouts based on PyQt-Fluent-Widgets
---

# Component Development Patterns

## PyQt-Fluent-Widgets 卡片类型

选择正确的卡片基类是组件开发的第一步：

| 类型 | 特点 | 适用场景 | 动画 |
|------|------|----------|------|
| `CardWidget` | 悬停高亮、点击动画 | 可交互卡片 | ✓ |
| `SimpleCardWidget` | 无动画 | 静态展示卡片 | ✗ |
| `ElevatedCardWidget` | 阴影+悬浮效果 | 强调型卡片 | ✓ |
| `HeaderCardWidget` | 带标题头 | 分组展示 | ✓ |

## Design Principles

### 1. Single Responsibility

```python
# Good: Focused component
class UserAvatar(QWidget):
    """Displays user avatar with status indicator"""
    
    clicked = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._avatar = None
        self._status = None

# Bad: Too many responsibilities
class UserWidget(QWidget):
    """Displays user, handles login, manages settings..."""
```

### 2. Props-Driven Design

```python
class StatusCard(CardWidget):
    """Status display card"""
    
    def __init__(self, title: str = "", value: str = "", 
                 icon: FluentIcon = None, parent=None):
        super().__init__(parent)
        self._title = title
        self._value = value
        self._icon = icon
    
    @property
    def title(self) -> str:
        return self._title
    
    @title.setter
    def title(self, value: str):
        self._title = value
        self.titleLabel.setText(value)
```

### 3. Signal-Based Communication

```python
class SearchBox(QWidget):
    """Search input component"""
    
    # Output signals
    searchRequested = Signal(str)
    textChanged = Signal(str)
    cleared = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.inputEdit = LineEdit(self)
        self.searchBtn = ToolButton(FluentIcon.SEARCH, self)
        
        self._connectSignals()
    
    def _connectSignals(self):
        self.inputEdit.textChanged.connect(self.textChanged)
        self.inputEdit.returnPressed.connect(self._onSearch)
        self.searchBtn.clicked.connect(self._onSearch)
    
    def _onSearch(self):
        text = self.inputEdit.text().strip()
        if text:
            self.searchRequested.emit(text)
```

## Component Types

### Display Component

```python
class StatCard(CardWidget):
    """Display a statistic"""
    
    def __init__(self, title: str, parent=None):
        super().__init__(parent)
        self.titleLabel = CaptionLabel(title, self)
        self.valueLabel = TitleLabel("-", self)
        self._initLayout()
    
    def setValue(self, value: str):
        self.valueLabel.setText(value)
```

### Input Component

```python
class FormBuilder(QWidget):
    """Form with validation"""
    
    submitted = Signal(dict)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._fields = {}
    
    def addField(self, name: str, label: str, required: bool = False):
        """Add form field"""
        ...
    
    def validate(self) -> bool:
        """Validate all fields"""
        ...
    
    def getData(self) -> dict:
        """Get form data"""
        ...
```

### Container Component

```python
class UserList(ScrollArea):
    """User list with filtering"""
    
    userSelected = Signal(object)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._users = []
        self._filter = ""
    
    def setUsers(self, users: list):
        self._users = users
        self._refresh()
    
    def setFilter(self, filter: str):
        self._filter = filter.lower()
        self._refresh()
```

## Layout Patterns

### Card Layout

```python
class UserCard(CardWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._initUI()
        self._initLayout()
    
    def _initLayout(self):
        layout = QHBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 12)
        layout.setSpacing(12)
        
        # Left: Avatar
        layout.addWidget(self.avatarLabel)
        
        # Center: Info
        infoLayout = QVBoxLayout()
        infoLayout.addWidget(self.nameLabel)
        infoLayout.addWidget(self.emailLabel)
        layout.addLayout(infoLayout, 1)
        
        # Right: Action
        layout.addWidget(self.actionBtn)
```

### Scroll Area Layout

```python
class MyInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        
        self.view = QWidget(self)
        self.vBoxLayout = QVBoxLayout(self.view)
        
        self.setWidget(self.view)
        self.setWidgetResizable(True)
        
        self.vBoxLayout.setSpacing(20)
        self.vBoxLayout.setContentsMargins(36, 20, 36, 36)
        self.vBoxLayout.setAlignment(Qt.AlignTop)
```

## CardWidget 继承模式

### CardWidget（可交互卡片）

```python
from qfluentwidgets import CardWidget, IconWidget, BodyLabel, CaptionLabel
from PySide6.QtCore import Signal, Qt
from PySide6.QtWidgets import QHBoxLayout, QVBoxLayout

class UserCard(CardWidget):
    """用户卡片 - 支持悬停高亮和点击动画"""
    
    # 信号
    clicked = Signal()
    userSelected = Signal(object)  # User 对象
    
    def __init__(self, user=None, parent=None):
        super().__init__(parent=parent)
        self._user = user
        
        # 设置 objectName 用于 QSS 选择器
        self.setObjectName('userCard')
        
        self._initUI()
        self._initLayout()
        self._connectSignals()
    
    def _initUI(self):
        """初始化 UI 组件"""
        self.avatarLabel = IconWidget(self)
        self.nameLabel = BodyLabel(self)
        self.emailLabel = CaptionLabel(self)
        self.actionBtn = TransparentToolButton(FIF.MORE, self)
        
        # 设置 objectName
        self.avatarLabel.setObjectName('avatarLabel')
        self.nameLabel.setObjectName('nameLabel')
        
        if self._user:
            self._updateUI()
    
    def _initLayout(self):
        """设置布局"""
        layout = QHBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 12)
        layout.setSpacing(12)
        
        # 左侧：头像
        layout.addWidget(self.avatarLabel)
        
        # 中间：信息
        infoLayout = QVBoxLayout()
        infoLayout.setSpacing(4)
        infoLayout.addWidget(self.nameLabel)
        infoLayout.addWidget(self.emailLabel)
        layout.addLayout(infoLayout, 1)
        
        # 右侧：操作
        layout.addWidget(self.actionBtn)
    
    def _connectSignals(self):
        """连接信号"""
        self.actionBtn.clicked.connect(self._onActionClick)
    
    def _updateUI(self):
        """更新 UI 显示"""
        self.nameLabel.setText(self._user.name)
        self.emailLabel.setText(self._user.email)
    
    def setUser(self, user):
        """设置用户数据"""
        self._user = user
        self._updateUI()
    
    def mouseReleaseEvent(self, e):
        """点击事件 - CardWidget 自动处理悬停动画"""
        super().mouseReleaseEvent(e)
        self.clicked.emit()
        if self._user:
            self.userSelected.emit(self._user)
```

### SimpleCardWidget（静态卡片）

```python
from qfluentwidgets import SimpleCardWidget, BodyLabel, CaptionLabel

class StatCard(SimpleCardWidget):
    """统计卡片 - 无动画的静态展示"""
    
    def __init__(self, title: str, parent=None):
        super().__init__(parent=parent)
        self._title = title
        
        self.titleLabel = CaptionLabel(title, self)
        self.valueLabel = TitleLabel("-", self)
        
        self._initLayout()
    
    def _initLayout(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(8)
        
        layout.addWidget(self.titleLabel)
        layout.addWidget(self.valueLabel)
    
    def setValue(self, value: str):
        """设置统计值"""
        self.valueLabel.setText(value)
```

### ElevatedCardWidget（强调卡片）

```python
from qfluentwidgets import ElevatedCardWidget, BodyLabel

class FeaturedCard(ElevatedCardWidget):
    """特色卡片 - 带阴影和悬浮效果"""
    
    def __init__(self, icon, title: str, description: str, parent=None):
        super().__init__(parent=parent)
        
        self.iconWidget = IconWidget(icon, self)
        self.titleLabel = SubtitleLabel(title, self)
        self.descLabel = BodyLabel(description, self)
        
        self._initLayout()
    
    def _initLayout(self):
        layout = QHBoxLayout(self)
        layout.setContentsMargins(20, 16, 20, 16)
        layout.setSpacing(16)
        
        layout.addWidget(self.iconWidget)
        
        textLayout = QVBoxLayout()
        textLayout.addWidget(self.titleLabel)
        textLayout.addWidget(self.descLabel)
        layout.addLayout(textLayout, 1)
```

---

## Common Patterns

### Loading State

```python
class DataLoader(QWidget):
    dataLoaded = Signal(object)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._loading = False
        self.progressRing = ProgressRing(self)
        self.contentWidget = QWidget(self)
        
    def setLoading(self, loading: bool):
        self._loading = loading
        if loading:
            self.contentWidget.hide()
            self.progressRing.show()
        else:
            self.progressRing.hide()
            self.contentWidget.show()
```

### Error Handling

```python
class ErrorBoundary(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.contentWidget = QWidget(self)
        self.errorWidget = QWidget(self)
        self.errorWidget.hide()
    
    def showError(self, message: str):
        self.contentWidget.hide()
        self.errorMessage.setText(message)
        self.errorWidget.show()
    
    def clearError(self):
        self.errorWidget.hide()
        self.contentWidget.show()
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Always set parent** | `widget = MyWidget(parent=self)` |
| **Use signals for communication** | Don't call parent methods directly |
| **Block signals during updates** | `widget.blockSignals(True)` |
| **Clean up in closeEvent** | Save state, release resources |
| **Support themes** | Test with light and dark themes |
| **Set objectName** | For QSS selector targeting |
| **Use CardWidget for interactivity** | Get free hover/click animations |
| **Apply StyleSheet via StyleSheetBase** | See theming skill for details |
