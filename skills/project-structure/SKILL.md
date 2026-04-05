---
name: project-structure
description: Use when setting up a new PySide6 project or reorganizing existing one - provides standard directory layout and file organization
---

# PySide6 Project Structure

## Standard Layout

```
project/
├── app/                           # Application package
│   ├── __init__.py                # Package marker, version
│   ├── main.py                    # Entry point
│   │
│   ├── common/                    # Shared utilities
│   │   ├── __init__.py
│   │   ├── config.py              # QConfig configuration
│   │   ├── signal_bus.py          # Global signal bus
│   │   ├── style_sheet.py         # StyleSheet manager
│   │   ├── icon.py                # Custom icons
│   │   ├── translator.py          # i18n support
│   │   └── resource.py            # Qt resources
│   │
│   ├── components/                # Reusable widgets
│   │   ├── __init__.py
│   │   ├── cards/
│   │   ├── dialogs/
│   │   └── inputs/
│   │
│   ├── view/                      # UI pages
│   │   ├── __init__.py
│   │   ├── main_window.py
│   │   ├── home_interface.py
│   │   └── settings_interface.py
│   │
│   └── resource/                  # Static files
│       ├── qss/
│       ├── images/
│       └── i18n/
│
├── tests/                         # Tests
│   ├── conftest.py
│   ├── test_components/
│   └── test_views/
│
├── docs/                          # Documentation
│   └── specs/
│
├── requirements.txt
├── pytest.ini
└── README.md
```

## Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| `common/` | No UI, pure utilities and configuration |
| `components/` | Reusable widgets, no business logic |
| `view/` | Page composition, business logic coordination |
| `resource/` | Static assets only |

## File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Page | `xxx_interface.py` | `home_interface.py` |
| Widget | `xxx_widget.py` | `user_card_widget.py` |
| Dialog | `xxx_dialog.py` | `confirm_dialog.py` |
| Test | `test_xxx.py` | `test_user_card.py` |

## Key Files

### main.py

```python
import sys
from PySide6.QtWidgets import QApplication
from qfluentwidgets import setThemeColor

from app.view.main_window import MainWindow


def main():
    app = QApplication(sys.argv)
    
    # Setup
    setThemeColor("#0078d4")
    
    # Create window
    window = MainWindow()
    window.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
```

### config.py

```python
from qfluentwidgets import QConfig, ConfigItem, Theme

class Config(QConfig):
    themeMode = ConfigItem("Appearance", "Theme", Theme.AUTO)
    windowGeometry = ConfigItem("MainWindow", "Geometry", None)

cfg = Config()
qconfig.load('app/config/config.json', cfg)
```

### signal_bus.py

```python
from PySide6.QtCore import QObject, Signal

class SignalBus(QObject):
    navigateTo = Signal(str)
    themeChanged = Signal(str)
    refreshRequested = Signal()

signalBus = SignalBus()
```

## Configuration Files

### requirements.txt

```txt
PySide6>=6.4.0
PySide6-Fluent-Widgets>=1.11.0
```

### requirements-dev.txt

```txt
-r requirements.txt
pytest>=7.0.0
pytest-qt>=4.2.0
```

### pytest.ini

```ini
[pytest]
testpaths = tests
qt_api = pyside6
addopts = -v
```
