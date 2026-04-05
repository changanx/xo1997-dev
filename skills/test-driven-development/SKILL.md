---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development for PySide6

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

## Red-Green-Refactor

```
RED: Write failing test → Verify failure
GREEN: Minimal implementation → Verify pass
REFACTOR: Clean up → Verify still passes
```

## 测试框架配置

**详细测试模式请参考:** `testing-patterns` 技能

### 依赖安装

```bash
pip install pytest pytest-qt pytest-cov
```

### pytest.ini

```ini
[pytest]
testpaths = tests
qt_api = pyside6
addopts = -v --tb=short
```

## Qt Testing with pytest-qt

### Basic Widget Test

```python
import pytest
from pytestqt.qtbot import QtBot
from PySide6.QtCore import Qt

from app.components.my_widget import MyWidget


class TestMyWidget:
    
    @pytest.fixture
    def widget(self, qtbot: QtBot):
        w = MyWidget()
        qtbot.addWidget(w)
        return w
    
    def test_initial_state(self, widget: MyWidget):
        """Test initial state"""
        assert widget.text() == ""
    
    def test_set_text(self, widget: MyWidget):
        """Test setting text"""
        widget.setText("Hello")
        assert widget.text() == "Hello"
```

### Testing Signals

```python
def test_click_signal(self, qtbot: QtBot, widget: MyWidget):
    """Test click signal emission"""
    with qtbot.waitSignal(widget.clicked) as blocker:
        qtbot.mouseClick(widget, Qt.LeftButton)
    
    assert blocker.args == [True]
```

### Testing User Input

```python
def test_text_input(self, qtbot: QtBot):
    """Test text input"""
    edit = QLineEdit()
    qtbot.addWidget(edit)
    
    qtbot.keyClicks(edit, "Hello World")
    
    assert edit.text() == "Hello World"
```

## TDD Workflow

### Step 1: Write Failing Test

```python
def test_shouldDisplayUserName_whenUserLoaded(self, qtbot: QtBot):
    """Test user display after loading"""
    card = UserCard()
    qtbot.addWidget(card)
    
    user = User(name="张三", email="zhang@example.com")
    card.setUser(user)
    
    assert card.nameLabel.text() == "张三"
    assert card.emailLabel.text() == "zhang@example.com"
```

### Step 2: Run and Verify Failure

```bash
pytest tests/test_user_card.py -v
# FAIL: MyWidget has no attribute 'setUser'
```

### Step 3: Write Minimal Implementation

```python
class UserCard(CardWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.nameLabel = BodyLabel(self)
        self.emailLabel = CaptionLabel(self)
        # ... layout setup ...
    
    def setUser(self, user: User):
        self.nameLabel.setText(user.name)
        self.emailLabel.setText(user.email)
```

### Step 4: Run and Verify Pass

```bash
pytest tests/test_user_card.py -v
# PASS
```

### Step 5: Refactor

After green, clean up the code while keeping tests passing.

### Step 6: Commit

Use pyside6-dev:committing-changes skill.

## Test File Structure

```
tests/
├── conftest.py           # Fixtures
├── test_components/      # Component tests
│   ├── test_user_card.py
│   └── test_search_box.py
├── test_views/           # View tests
│   └── test_home_interface.py
└── test_integration/     # Integration tests
    └── test_main_window.py
```

## Common Test Patterns

### Testing Theme Changes

```python
def test_theme_change(self, qtbot: QtBot, widget: MyWidget):
    """Test widget responds to theme change"""
    from qfluentwidgets import setTheme, Theme
    
    setTheme(Theme.DARK)
    
    # Verify dark theme applied
    assert widget.property("dark") == True
```

### Testing Async Operations

```python
def test_async_loading(self, qtbot: QtBot, widget: DataLoader):
    """Test async data loading"""
    with qtbot.waitSignal(widget.dataLoaded, timeout=5000):
        widget.loadData()
    
    assert widget.data() is not None
```

## Verification Checklist

Before marking complete:

- [ ] Every new component has tests
- [ ] Watched each test fail before implementing
- [ ] All tests pass: `pytest tests/ -v`
- [ ] No warnings in test output
- [ ] Edge cases covered
