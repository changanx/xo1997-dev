---
name: new-component
description: Create a new PySide6 UI component with tests
---

# Create New Component

Create a new reusable UI component following best practices.

## Parameters

Ask the user for:
1. **Component name** (e.g., UserCard, SearchBox, StatusBadge)
2. **Component type** (display, input, container)
3. **Parent module** (components/, components/cards/, etc.)

## Process

1. Create component file: `app/components/{name.lower()}_widget.py`
2. Create test file: `tests/test_components/test_{name.lower()}.py`
3. Update `app/components/__init__.py`

## Template

### Component File

```python
# app/components/{name}_widget.py
from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import QWidget, QHBoxLayout, QVBoxLayout
from qfluentwidgets import CardWidget, BodyLabel, CaptionLabel

from ..common.style_sheet import StyleSheet


class {Name}(CardWidget):
    """TODO: Description"""
    
    # Signals
    clicked = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._initUI()
        self._initLayout()
        self._connectSignals()
    
    def _initUI(self):
        """Initialize UI components"""
        # TODO: Create widgets
        pass
    
    def _initLayout(self):
        """Setup layout"""
        # TODO: Setup layout
        pass
    
    def _connectSignals(self):
        """Connect internal signals"""
        # TODO: Connect signals
        pass
```

### Test File

```python
# tests/test_components/test_{name}.py
import pytest
from pytestqt.qtbot import QtBot

from app.components.{name}_widget import {Name}


class Test{Name}:
    
    @pytest.fixture
    def widget(self, qtbot: QtBot):
        w = {Name}()
        qtbot.addWidget(w)
        return w
    
    def test_creation(self, widget: {Name}):
        """Test widget can be created"""
        assert widget is not None
    
    # TODO: Add more tests
```

## Usage

```
/new-component
```

Then follow the prompts.
