---
name: new-interface
description: Create a new page/interface for the application
---

# Create New Interface

Create a new page/interface following PyQt-Fluent-Widgets best practices.

## Parameters

Ask the user for:
1. **Interface name** (e.g., Home, Settings, UserProfile)
2. **Navigation icon** (FluentIcon name)
3. **Navigation position** (top, scroll, bottom)

## Process

1. Create interface file: `app/view/{name}_interface.py`
2. Update `app/view/main_window.py` to add navigation
3. Add stylesheet to `app/common/style_sheet.py`

## Template

```python
# app/view/{name}_interface.py
from PySide6.QtCore import Qt
from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel
from qfluentwidgets import (
    ScrollArea, TitleLabel, SubtitleLabel, BodyLabel,
    CardWidget, FluentIcon as FIF
)

from ..common.style_sheet import StyleSheet
from ..common.signal_bus import signalBus


class {Name}Interface(ScrollArea):
    """TODO: Description"""

    def __init__(self, parent=None):
        super().__init__(parent=parent)

        # Scroll content widget
        self.view = QWidget(self)
        self.vBoxLayout = QVBoxLayout(self.view)

        # UI Components
        self.titleLabel = TitleLabel(self.tr("Title"), self)
        self.subtitleLabel = SubtitleLabel(self.tr("Subtitle"), self)

        self._initLayout()
        self._connectSignals()

        # Set objectName for QSS
        self.view.setObjectName('view')
        self.setObjectName('{name}Interface')

        # Apply stylesheet
        StyleSheet.{NAME}_INTERFACE.apply(self)

    def _initLayout(self):
        """Setup layout"""
        # ScrollArea settings
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.setViewportMargins(0, 80, 0, 20)  # Top margin for title
        self.setWidget(self.view)
        self.setWidgetResizable(True)

        # Vertical layout
        self.vBoxLayout.setSpacing(20)
        self.vBoxLayout.setContentsMargins(36, 20, 36, 36)
        self.vBoxLayout.setAlignment(Qt.AlignTop)

        # Add widgets
        self.vBoxLayout.addWidget(self.titleLabel)
        self.vBoxLayout.addWidget(self.subtitleLabel)

    def _connectSignals(self):
        """Connect to signal bus"""
        signalBus.refreshRequested.connect(self._onRefresh)

    def _onRefresh(self):
        """Handle refresh signal"""
        # TODO: Implement refresh logic
        pass
```

## Main Window Integration

Add to `MainWindow.initNavigation()`:

```python
from .{name}_interface import {Name}Interface
from qfluentwidgets import NavigationItemPosition, FluentIcon as FIF

class MainWindow(FluentWindow):

    def __init__(self):
        super().__init__()

        # Create interfaces
        self.{name}Interface = {Name}Interface(self)

        self.initNavigation()
        self.initWindow()

    def initNavigation(self):
        # Add sub interface
        self.addSubInterface(
            self.{name}Interface,
            FIF.{ICON},
            self.tr('{Display Name}')
        )

        # Or with specific position:
        # self.addSubInterface(
        #     self.{name}Interface, FIF.{ICON}, self.tr('{Display Name}'),
        #     NavigationItemPosition.SCROLL
        # )
        # self.addSubInterface(
        #     self.{name}Interface, FIF.{ICON}, self.tr('{Display Name}'),
        #     NavigationItemPosition.BOTTOM
        # )

    def initWindow(self):
        self.resize(900, 700)
        self.setWindowTitle('App Name')

        # Enable Mica effect (Windows 11)
        self.setMicaEffectEnabled(True)
```

## Navigation Positions

| Position | Constant | Use When |
|----------|----------|----------|
| Top | `NavigationItemPosition.TOP` | Primary navigation items |
| Scroll | `NavigationItemPosition.SCROLL` | Secondary items (scrollable area) |
| Bottom | `NavigationItemPosition.BOTTOM` | Settings, help, user profile |

## Complete MainWindow Example

```python
# app/view/main_window.py
from qfluentwidgets import (
    FluentWindow, NavigationItemPosition, FluentIcon as FIF,
    setTheme, Theme
)
from ..common.config import cfg
from ..common.signal_bus import signalBus

from .home_interface import HomeInterface
from .setting_interface import SettingInterface


class MainWindow(FluentWindow):

    def __init__(self):
        super().__init__()

        # Create interfaces
        self.homeInterface = HomeInterface(self)
        self.settingInterface = SettingInterface(self)

        self.initNavigation()
        self.initWindow()

        # Connect signals
        self._connectSignals()

    def initNavigation(self):
        # Primary navigation (top)
        self.addSubInterface(self.homeInterface, FIF.HOME, self.tr('Home'))

        # Secondary navigation (scroll area)
        # self.navigationInterface.addSeparator()

        # Bottom navigation
        self.addSubInterface(
            self.settingInterface, FIF.SETTING, self.tr('Settings'),
            NavigationItemPosition.BOTTOM
        )

    def initWindow(self):
        self.resize(900, 700)
        self.setWindowTitle('My App')

        # Apply theme
        setTheme(cfg.themeMode.value)

        # Enable Mica effect (Windows 11)
        if cfg.micaEnabled.value:
            self.setMicaEffectEnabled(True)

    def _connectSignals(self):
        """Connect to signal bus"""
        signalBus.themeChanged.connect(self._onThemeChanged)

    def _onThemeChanged(self, theme: str):
        """Handle theme change"""
        setTheme(Theme(theme))
```

## Usage

```
/new-interface
```

Then follow the prompts.
