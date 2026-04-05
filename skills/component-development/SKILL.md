---
name: component-development
description: Use when creating reusable UI components - provides patterns for widgets, signals, properties, and layouts
---

# Component Development Patterns

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
