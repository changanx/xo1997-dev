---
name: testing-patterns
description: Use when writing tests for PySide6/Qt components - provides pytest-qt patterns, fixtures, and testing best practices
---

# PySide6 Testing Patterns with pytest

## 测试框架配置

### 安装依赖

```bash
pip install pytest pytest-qt pytest-cov
```

### pytest.ini 配置

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
qt_api = pyside6
addopts = -v --tb=short
filterwarnings =
    ignore::DeprecationWarning
```

### conftest.py - 测试夹具

```python
# tests/conftest.py
import pytest
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import QSettings, QTemporaryFile
import sys


@pytest.fixture(scope="session")
def qapp():
    """创建 QApplication 实例（整个测试会话共享）"""
    app = QApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    yield app


@pytest.fixture
def qtbot(qapp, qtbot):
    """确保 qtbot 有 qapp 上下文"""
    return qtbot


@pytest.fixture
def temp_config(tmp_path):
    """创建临时配置文件"""
    config_file = tmp_path / "config.json"
    config_file.write_text('{}')
    return str(config_file)


@pytest.fixture
def mock_settings(tmp_path):
    """创建临时 QSettings"""
    from PySide6.QtCore import QSettings
    config_path = tmp_path / "test.ini"
    settings = QSettings(str(config_path), QSettings.IniFormat)
    yield settings
    settings.clear()
```

---

## 核心测试模式

### 1. 组件基础测试

```python
# tests/test_components/test_user_card.py
import pytest
from pytestqt.qtbot import QtBot
from PySide6.QtCore import Qt

from app.components.user_card import UserCard
from app.models.user import User


class TestUserCard:
    """UserCard 组件测试"""
    
    @pytest.fixture
    def widget(self, qtbot: QtBot):
        """创建组件实例"""
        card = UserCard()
        qtbot.addWidget(card)
        return card
    
    def test_创建组件成功(self, widget: UserCard):
        """测试: 组件可以正常创建"""
        assert widget is not None
        assert widget.isVisible() == False  # 未显示
    
    def test_初始状态(self, widget: UserCard):
        """测试: 初始状态正确"""
        assert widget.name() == ""
        assert widget.email() == ""
        assert widget.avatar() is None
    
    def test_设置用户信息(self, widget: UserCard):
        """测试: 设置用户信息后正确显示"""
        user = User(name="张三", email="zhang@example.com")
        
        widget.setUser(user)
        
        assert widget.name() == "张三"
        assert widget.email() == "zhang@example.com"
    
    def test_清空用户信息(self, widget: UserCard):
        """测试: 清空用户信息"""
        user = User(name="张三", email="zhang@example.com")
        widget.setUser(user)
        
        widget.clear()
        
        assert widget.name() == ""
        assert widget.email() == ""
```

### 2. 信号测试

```python
class TestUserCardSignals:
    """UserCard 信号测试"""
    
    @pytest.fixture
    def widget(self, qtbot: QtBot):
        card = UserCard()
        qtbot.addWidget(card)
        return card
    
    def test_点击信号发射(self, qtbot: QtBot, widget: UserCard):
        """测试: 点击时发射 clicked 信号"""
        # 等待信号
        with qtbot.waitSignal(widget.clicked, timeout=1000) as blocker:
            # 模拟点击
            qtbot.mouseClick(widget, Qt.LeftButton)
        
        # 验证信号被发射
        assert blocker.signal_triggered
    
    def test_信号携带参数(self, qtbot: QtBot, widget: UserCard):
        """测试: 信号携带正确的参数"""
        user = User(name="张三", email="zhang@example.com")
        widget.setUser(user)
        
        with qtbot.waitSignal(widget.userClicked) as blocker:
            qtbot.mouseClick(widget, Qt.LeftButton)
        
        # 验证信号参数
        assert blocker.args == [user]
    
    def test_多个信号等待(self, qtbot: QtBot):
        """测试: 等待多个信号"""
        from PySide6.QtCore import QObject, Signal
        
        class Emitter(QObject):
            started = Signal()
            finished = Signal(str)
        
        emitter = Emitter()
        qtbot.addWidget(emitter)
        
        with qtbot.waitSignals([emitter.started, emitter.finished]):
            emitter.started.emit()
            emitter.finished.emit("done")
    
    def test_信号未发射(self, qtbot: QtBot, widget: UserCard):
        """测试: 验证信号未发射"""
        # 禁用组件
        widget.setEnabled(False)
        
        # 使用 raising=False 避免超时异常
        with qtbot.waitSignal(widget.clicked, timeout=500, raising=False) as blocker:
            qtbot.mouseClick(widget, Qt.LeftButton)
        
        # 验证信号未发射
        assert not blocker.signal_triggered
```

### 3. 用户交互测试

```python
class TestUserInteractions:
    """用户交互测试"""
    
    def test_按钮点击(self, qtbot: QtBot):
        """测试: 按钮点击响应"""
        from qfluentwidgets import PushButton
        
        btn = PushButton("点击我")
        qtbot.addWidget(btn)
        
        clicked = []
        btn.clicked.connect(lambda: clicked.append(True))
        
        qtbot.mouseClick(btn, Qt.LeftButton)
        
        assert len(clicked) == 1
    
    def test_文本输入(self, qtbot: QtBot):
        """测试: 文本输入"""
        from qfluentwidgets import LineEdit
        
        edit = LineEdit()
        qtbot.addWidget(edit)
        
        # 模拟键盘输入
        qtbot.keyClicks(edit, "Hello World")
        
        assert edit.text() == "Hello World"
    
    def test_键盘快捷键(self, qtbot: QtBot):
        """测试: 键盘快捷键"""
        from PySide6.QtGui import QKeySequence, QShortcut
        from PySide6.QtWidgets import QWidget
        
        widget = QWidget()
        qtbot.addWidget(widget)
        
        triggered = []
        shortcut = QShortcut(QKeySequence("Ctrl+S"), widget)
        shortcut.activated.connect(lambda: triggered.append(True))
        
        # 模拟 Ctrl+S
        qtbot.keyClick(widget, Qt.Key_S, Qt.ControlModifier)
        
        assert len(triggered) == 1
    
    def test_下拉框选择(self, qtbot: QtBot):
        """测试: 下拉框选择"""
        from qfluentwidgets import ComboBox
        
        combo = ComboBox()
        combo.addItems(["选项1", "选项2", "选项3"])
        qtbot.addWidget(combo)
        
        # 选择第二项
        combo.setCurrentIndex(1)
        
        assert combo.currentText() == "选项2"
    
    def test_复选框切换(self, qtbot: QtBot):
        """测试: 复选框状态切换"""
        from qfluentwidgets import CheckBox
        
        checkbox = CheckBox("同意条款")
        qtbot.addWidget(checkbox)
        
        assert checkbox.isChecked() == False
        
        qtbot.mouseClick(checkbox, Qt.LeftButton)
        
        assert checkbox.isChecked() == True
```

### 4. 异步操作测试

```python
from PySide6.QtCore import QThread, Signal, QTimer


class TestAsyncOperations:
    """异步操作测试"""
    
    def test_QTimer超时(self, qtbot: QtBot):
        """测试: QTimer 超时"""
        triggered = []
        
        timer = QTimer()
        timer.setSingleShot(True)
        timer.timeout.connect(lambda: triggered.append(True))
        timer.start(100)  # 100ms
        
        # 等待足够时间
        qtbot.wait(200)
        
        assert len(triggered) == 1
    
    def test_线程完成(self, qtbot: QtBot):
        """测试: 后台线程完成"""
        class Worker(QThread):
            finished = Signal(str)
            
            def run(self):
                import time
                time.sleep(0.1)
                self.finished.emit("done")
        
        worker = Worker()
        
        with qtbot.waitSignal(worker.finished, timeout=5000) as blocker:
            worker.start()
        
        assert blocker.args == ["done"]
        worker.wait()
        worker.deleteLater()
    
    def test_异步数据加载(self, qtbot: QtBot):
        """测试: 异步数据加载组件"""
        from app.components.data_loader import DataLoader
        
        loader = DataLoader()
        qtbot.addWidget(loader)
        
        # 模拟数据加载
        with qtbot.waitSignal(loader.dataLoaded, timeout=5000):
            loader.loadData()
        
        assert loader.isLoading() == False
        assert loader.data() is not None
```

### 5. 模型和视图测试

```python
from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex


class TestModels:
    """数据模型测试"""
    
    def test_列表模型(self, qtbot: QtBot):
        """测试: 自定义列表模型"""
        class StringListModel(QAbstractListModel):
            def __init__(self, strings, parent=None):
                super().__init__(parent)
                self._strings = strings
            
            def rowCount(self, parent=QModelIndex()):
                return len(self._strings)
            
            def data(self, index, role=Qt.DisplayRole):
                if not index.isValid() or role != Qt.DisplayRole:
                    return None
                return self._strings[index.row()]
        
        model = StringListModel(["A", "B", "C"])
        
        assert model.rowCount() == 3
        assert model.data(model.index(0, 0)) == "A"
        assert model.data(model.index(1, 0)) == "B"
    
    def test_模型更新信号(self, qtbot: QtBot):
        """测试: 模型更新发射信号"""
        from PySide6.QtCore import QStringListModel
        
        model = QStringListModel(["A", "B"])
        
        with qtbot.waitSignals([
            model.dataChanged,
            model.layoutChanged
        ], raising=False):
            model.setStringList(["A", "B", "C"])
```

---

## 参数化测试

```python
@pytest.mark.parametrize("input_text,expected_valid", [
    ("", False),           # 空
    ("a", False),          # 太短
    ("ab", False),         # 太短
    ("abc", True),         # 有效
    ("abcd", True),        # 有效
    ("   ", False),        # 空白
    ("  abc  ", True),     # 带空格但有效
])
def test_输入验证(input_text: str, expected_valid: bool, qtbot: QtBot):
    """测试: 输入验证逻辑"""
    from app.components.validated_input import ValidatedLineEdit
    
    widget = ValidatedLineEdit(min_length=3)
    qtbot.addWidget(widget)
    
    widget.setText(input_text)
    
    assert widget.isValid() == expected_valid


@pytest.mark.parametrize("theme,expected_bg", [
    ("light", "#ffffff"),
    ("dark", "#1a1a1a"),
])
def test_主题切换(theme: str, expected_bg: str, qtbot: QtBot):
    """测试: 主题切换"""
    from app.components.themed_card import ThemedCard
    
    card = ThemedCard()
    qtbot.addWidget(card)
    
    card.setTheme(theme)
    
    assert card.backgroundColor() == expected_bg
```

---

## 测试夹具进阶

```python
# tests/conftest.py 进阶配置

import pytest
from pathlib import Path


@pytest.fixture
def sample_user():
    """示例用户数据"""
    from app.models.user import User
    return User(
        id=1,
        name="测试用户",
        email="test@example.com",
        avatar=":/images/default_avatar.png"
    )


@pytest.fixture
def sample_users():
    """示例用户列表"""
    from app.models.user import User
    return [
        User(id=1, name="张三", email="zhang@example.com"),
        User(id=2, name="李四", email="li@example.com"),
        User(id=3, name="王五", email="wang@example.com"),
    ]


@pytest.fixture
def main_window(qtbot: QtBot):
    """创建主窗口实例"""
    from app.view.main_window import MainWindow
    
    window = MainWindow()
    qtbot.addWidget(window)
    
    yield window
    
    # 清理
    window.close()


@pytest.fixture
def mock_api(monkeypatch):
    """Mock API 调用"""
    def mock_fetch_users():
        return [
            {"id": 1, "name": "张三"},
            {"id": 2, "name": "李四"},
        ]
    
    import app.services.api
    monkeypatch.setattr(app.services.api, "fetch_users", mock_fetch_users)
    
    return mock_fetch_users
```

---

## 运行测试

```bash
# 运行所有测试
pytest tests/ -v

# 运行特定测试文件
pytest tests/test_components/test_user_card.py -v

# 运行特定测试类
pytest tests/test_components/test_user_card.py::TestUserCard -v

# 运行特定测试方法
pytest tests/test_components/test_user_card.py::TestUserCard::test_设置用户信息 -v

# 带覆盖率
pytest tests/ --cov=app --cov-report=html --cov-report=term

# 只运行标记的测试
pytest tests/ -m "slow" -v

# 并行运行（需要 pytest-xdist）
pytest tests/ -n auto
```

---

## 测试标记

```python
import pytest

@pytest.mark.slow
def test_耗时操作():
    """标记为慢速测试"""
    ...

@pytest.mark.integration
def test_集成测试():
    """标记为集成测试"""
    ...

@pytest.mark.skip(reason="等待修复")
def test_待修复():
    """跳过的测试"""
    ...

@pytest.mark.skipif(sys.platform == "linux", reason="Linux 不支持")
def test_Windows专用():
    """条件跳过"""
    ...
```

---

## 测试最佳实践

### 1. 测试命名规范

```python
# 好: 描述性的测试名称
def test_应当显示错误信息_当输入为空时():
    ...

def test_应当在点击后发射信号():
    ...

# 坏: 模糊的测试名称
def test_1():
    ...

def test_widget():
    ...
```

### 2. 一个测试一个概念

```python
# 好: 每个测试只验证一个行为
def test_初始状态_应当为空(widget):
    assert widget.text() == ""

def test_设置文本_应当更新显示(widget):
    widget.setText("test")
    assert widget.text() == "test"

# 坏: 一个测试验证多个行为
def test_widget_所有功能(widget):
    assert widget.text() == ""
    widget.setText("test")
    assert widget.text() == "test"
    widget.clear()
    assert widget.text() == ""
```

### 3. 使用 AAA 模式

```python
def test_用户搜索功能(qtbot: QtBot):
    # Arrange (准备)
    search_box = SearchBox()
    qtbot.addWidget(search_box)
    search_box.setItems(["Apple", "Banana", "Cherry"])
    
    # Act (执行)
    qtbot.keyClicks(search_box.inputEdit, "Ap")
    
    # Assert (断言)
    results = search_box.getVisibleItems()
    assert "Apple" in results
    assert "Banana" not in results
```

---

## 常见问题排查

### 问题: 测试超时

```python
# 增加超时时间
with qtbot.waitSignal(widget.finished, timeout=10000):  # 10秒
    widget.start()
```

### 问题: 组件未显示

```python
# 显式显示组件
widget = MyWidget()
widget.show()
qtbot.wait(100)  # 等待显示
qtbot.addWidget(widget)
```

### 问题: 信号未触发

```python
# 检查信号连接
assert receiver.receivers(signal) > 0

# 使用 qWait 等待事件处理
qtbot.wait(100)
```

---

## 测试覆盖率目标

| 组件类型 | 目标覆盖率 |
|----------|------------|
| 工具函数 | 90%+ |
| 组件逻辑 | 80%+ |
| UI 层 | 60%+ |
| 集成测试 | 关键路径 100% |
