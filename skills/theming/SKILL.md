---
name: theming
description: Use when working with themes, stylesheets, or appearance settings - provides theme switching, StyleSheet management, and Mica effect patterns
---

# 主题管理

## 主题 API

### 基本操作

```python
from qfluentwidgets import setTheme, toggleTheme, Theme, isDarkTheme

# 设置主题
setTheme(Theme.LIGHT)    # 浅色主题
setTheme(Theme.DARK)     # 深色主题
setTheme(Theme.AUTO)     # 跟随系统

# 切换主题（带持久化）
toggleTheme(save=True)

# 检查当前主题
if isDarkTheme():
    print("当前是深色主题")
```

### 主题枚举

```python
from enum import Enum

class Theme(Enum):
    LIGHT = "Light"   # 浅色
    DARK = "Dark"     # 深色
    AUTO = "Auto"     # 跟随系统
```

---

## 完整主题配置

### 1. 创建配置类

```python
# app/common/config.py
from qfluentwidgets import (
    QConfig, OptionsConfigItem, OptionsValidator, 
    EnumSerializer, Theme, qconfig
)

class Config(QConfig):
    """应用配置"""
    
    # 主题配置
    themeMode = OptionsConfigItem(
        "QFluentWidgets", "ThemeMode", Theme.AUTO,
        OptionsValidator(Theme), EnumSerializer(Theme)
    )
    
    # Mica 效果（仅 Windows 11）
    micaEnabled = ConfigItem("MainWindow", "MicaEnabled", True, BoolValidator())
    
    # 窗口几何
    windowGeometry = ConfigItem("MainWindow", "Geometry", None)

# 全局配置实例
cfg = Config()

# 加载配置
qconfig.load('app/config/config.json', cfg)
```

### 2. 连接主题信号

```python
# app/view/main_window.py
from qfluentwidgets import FluentWindow, setTheme, setMicaEffectEnabled
from ..common.config import cfg

class MainWindow(FluentWindow):
    def __init__(self):
        super().__init__()
        
        # 应用保存的主题
        setTheme(cfg.themeMode.value)
        
        # 监听主题变化
        cfg.themeChanged.connect(self._onThemeChanged)
        
        # 应用 Mica 效果
        if cfg.micaEnabled.value:
            self.setMicaEffectEnabled(True)
    
    def _onThemeChanged(self, theme: Theme):
        """主题变化处理"""
        setTheme(theme)
```

### 3. 设置界面主题卡片

```python
# app/view/setting_interface.py
from qfluentwidgets import (
    ScrollArea, ExpandLayout, OptionsSettingCard,
    FluentIcon as FIF
)
from ..common.config import cfg

class SettingInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # 主题选择卡片
        self.themeCard = OptionsSettingCard(
            cfg.themeMode,
            FIF.BRUSH,
            '应用主题',
            '更改应用程序的外观',
            texts=['浅色', '深色', '跟随系统']
        )
        
        # Mica 效果卡片
        self.micaCard = SwitchSettingCard(
            FIF.TRANSPARENT,
            'Mica 效果',
            '启用 Windows 11 的 Mica 效果',
            cfg.micaEnabled
        )
```

---

## 系统主题监听

### 自动跟随系统主题

```python
from qfluentwidgets import SystemThemeListener

class MainWindow(FluentWindow):
    def __init__(self):
        super().__init__()
        
        # 创建系统主题监听器
        self.themeListener = SystemThemeListener(self)
        self.themeListener.start()
    
    def closeEvent(self, e):
        """窗口关闭时清理"""
        self.themeListener.terminate()
        self.themeListener.deleteLater()
        super().closeEvent(e)
```

---

## StyleSheet 管理

### 方式一：StyleSheetBase 枚举（推荐）

```python
# app/common/style_sheet.py
from enum import Enum
from qfluentwidgets import StyleSheetBase, Theme, qconfig

class StyleSheet(StyleSheetBase, Enum):
    """样式表定义"""
    
    HOME_INTERFACE = "home_interface"
    SETTING_INTERFACE = "setting_interface"
    USER_CARD = "user_card"
    
    def path(self, theme=Theme.AUTO):
        """获取样式表路径"""
        theme = qconfig.theme if theme == Theme.AUTO else theme
        return f":/qss/{theme.value.lower()}/{self.value}.qss"
```

**使用方式：**

```python
# 在组件中应用
class HomeInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        # ...
        StyleSheet.HOME_INTERFACE.apply(self)  # 自动处理主题切换
```

**QSS 文件组织：**

```
resource/
├── qss/
│   ├── light/
│   │   ├── home_interface.qss
│   │   ├── setting_interface.qss
│   │   └── user_card.qss
│   └── dark/
│       ├── home_interface.qss
│       ├── setting_interface.qss
│       └── user_card.qss
└── resource.qrc
```

**resource.qrc 示例：**

```xml
<RCC>
    <qresource prefix="/qss">
        <file>qss/light/home_interface.qss</file>
        <file>qss/dark/home_interface.qss</file>
        <!-- 更多文件 -->
    </qresource>
</RCC>
```

### 方式二：setCustomStyleSheet

```python
from qfluentwidgets import setCustomStyleSheet

# 为单个组件设置自定义样式
setCustomStyleSheet(
    widget,
    lightQss="""
        QWidget {
            background: white;
            border: 1px solid #e0e0e0;
        }
    """,
    darkQss="""
        QWidget {
            background: #2d2d2d;
            border: 1px solid #404040;
        }
    """
)
```

### 方式三：动态 QSS

```python
from qfluentwidgets import isDarkTheme

class MyWidget(CardWidget):
    def _applyStyle(self):
        if isDarkTheme():
            self.setStyleSheet("""
                MyWidget {
                    background: #2d2d2d;
                }
            """)
        else:
            self.setStyleSheet("""
                MyWidget {
                    background: white;
                }
            """)
```

---

## Mica 效果（Windows 11）

### 启用 Mica

```python
from qfluentwidgets import FluentWindow, isMicaEffectEnabled

class MainWindow(FluentWindow):
    def __init__(self):
        super().__init__()
        
        # 检查支持
        if isMicaEffectEnabled():
            self.setMicaEffectEnabled(True)
```

### Mica 与主题配合

```python
# Mica 效果与主题颜色配合
from qfluentwidgets import setThemeColor

# 设置主题色（影响 Mica 效果色调）
setThemeColor("#0078d4")  # 蓝色
```

---

## Acrylic 效果（Windows 10+）

```python
from qfluentwidgets import FluentWindow

class MainWindow(FluentWindow):
    def __init__(self):
        super().__init__()
        
        # 启用亚克力效果
        self.navigationInterface.setAcrylicEnabled(True)
        
        # 设置模糊半径
        self.navigationInterface.setAcrylicBlurRadius(15)
```

---

## 主题相关的测试

```python
import pytest
from qfluentwidgets import setTheme, Theme, isDarkTheme

class TestThemeSwitching:
    
    def test_切换到浅色主题(self):
        setTheme(Theme.LIGHT)
        assert not isDarkTheme()
    
    def test_切换到深色主题(self):
        setTheme(Theme.DARK)
        assert isDarkTheme()
    
    def test_组件响应主题变化(self, qtbot):
        from qfluentwidgets import CardWidget
        
        card = CardWidget()
        qtbot.addWidget(card)
        
        # 切换主题
        setTheme(Theme.DARK)
        
        # 验证样式已更新
        # 具体验证取决于样式实现
```

---

## 最佳实践清单

- [ ] 使用 QConfig 管理主题配置，支持持久化
- [ ] 使用 StyleSheetBase 枚举管理样式表
- [ ] 为每个主题（light/dark）准备独立的 QSS 文件
- [ ] 使用 SystemThemeListener 支持跟随系统主题
- [ ] 在 closeEvent 中清理监听器
- [ ] 测试两种主题下的显示效果
- [ ] Mica 效果仅 Windows 11 支持，需要检测
