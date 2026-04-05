---
name: new-interface
description: Create a new page/interface for the application
---

# Create New Interface

Create a new page/interface following the project structure.

## Parameters

Ask the user for:
1. **Interface name** (e.g., Home, Settings, UserProfile)
2. **Navigation icon** (FluentIcon name)
3. **Navigation position** (top, scroll, bottom)

## Process

1. Create interface file: `app/view/{name}_interface.py`
2. Update `app/view/main_window.py` to add navigation

## Template

```python
# app/view/{name}_interface.py
from PySide6.QtCore import Qt
from PySide6.QtWidgets import QWidget, QVBoxLayout
from qfluentwidgets import ScrollArea, TitleLabel, BodyLabel

from ..common.style_sheet import StyleSheet
from ..common.signal_bus import signalBus


class {Name}Interface(ScrollArea):
    """TODO: Description"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        self.view = QWidget(self)
        self.vBoxLayout = QVBoxLayout(self.view)
        
        # UI Components
        self.titleLabel = TitleLabel(self.tr("Title"), self)
        
        self._initLayout()
        self._connectSignals()
        
        self.view.setObjectName('view')
        StyleSheet.{NAME}_INTERFACE.apply(self)
    
    def _initLayout(self):
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.setWidget(self.view)
        self.setWidgetResizable(True)
        
        self.vBoxLayout.setSpacing(20)
        self.vBoxLayout.setContentsMargins(36, 20, 36, 36)
        self.vBoxLayout.setAlignment(Qt.AlignTop)
        
        self.vBoxLayout.addWidget(self.titleLabel)
    
    def _connectSignals(self):
        # Connect to signal bus
        pass
```

## Main Window Integration

Add to `MainWindow.initNavigation()`:

```python
from .{name}_interface import {Name}Interface

# In __init__:
self.{name}Interface = {Name}Interface(self)

# In initNavigation:
self.addSubInterface(
    self.{name}Interface, 
    FluentIcon.{ICON}, 
    self.tr('{Display Name}')
)
```

## Usage

```
/new-interface
```

Then follow the prompts.
