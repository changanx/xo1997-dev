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
# app/common/config.py
from qfluentwidgets import (
    QConfig, ConfigItem, OptionsConfigItem, RangeConfigItem,
    OptionsValidator, RangeValidator, BoolValidator, EnumSerializer,
    Theme, qconfig
)

class Config(QConfig):
    """应用配置"""

    # 主题配置
    themeMode = OptionsConfigItem(
        "QFluentWidgets", "ThemeMode", Theme.AUTO,
        OptionsValidator(Theme), EnumSerializer(Theme)
    )

    # Mica 效果（仅 Windows 11）
    micaEnabled = ConfigItem(
        "MainWindow", "MicaEnabled", True, BoolValidator()
    )

    # 窗口几何
    windowGeometry = ConfigItem("MainWindow", "Geometry", None)

    # DPI 缩放
    dpiScale = OptionsConfigItem(
        "MainWindow", "DpiScale", "Auto",
        OptionsValidator([1, 1.25, 1.5, 1.75, 2, "Auto"]),
        restart=True
    )

    # 下载文件夹
    downloadFolder = ConfigItem(
        "Folders", "Download", "app/download", FolderValidator()
    )

# 全局配置实例
cfg = Config()

# 加载配置文件
qconfig.load('app/config/config.json', cfg)
```

### signal_bus.py

```python
# app/common/signal_bus.py
from PySide6.QtCore import QObject, Signal

class SignalBus(QObject):
    """全局信号总线 - 用于组件间通信"""

    # 导航信号
    navigateTo = Signal(str)              # 导航到指定页面
    navigateBack = Signal()               # 返回上一页

    # 主题信号
    themeChanged = Signal(str)            # 主题变化

    # 数据信号
    refreshRequested = Signal()           # 请求刷新
    dataLoaded = Signal(object)           # 数据加载完成

    # 用户信号
    userLoggedIn = Signal(object)         # 用户登录
    userLoggedOut = Signal()              # 用户登出

    # 业务信号（根据应用需求添加）
    switchToSampleCard = Signal(str, int) # 切换到示例卡片
    micaEnableChanged = Signal(bool)      # Mica 效果状态

# 全局单例
signalBus = SignalBus()
```

### style_sheet.py

```python
# app/common/style_sheet.py
from enum import Enum
from qfluentwidgets import StyleSheetBase, Theme, qconfig

class StyleSheet(StyleSheetBase, Enum):
    """样式表定义 - 支持主题切换"""

    # 界面样式
    HOME_INTERFACE = "home_interface"
    SETTING_INTERFACE = "setting_interface"

    # 组件样式
    USER_CARD = "user_card"
    SAMPLE_CARD = "sample_card"

    def path(self, theme=Theme.AUTO):
        """获取样式表路径"""
        theme = qconfig.theme if theme == Theme.AUTO else theme
        return f":/qss/{theme.value.lower()}/{self.value}.qss"
```

**使用方式：**

```python
# 在组件中应用样式
from ..common.style_sheet import StyleSheet

class HomeInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        # ...
        StyleSheet.HOME_INTERFACE.apply(self)  # 自动处理主题切换
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
