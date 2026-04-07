---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development for PySide6

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

## Immediate Action

**Upon invoking this skill for a new feature, you MUST:**

1. Create a TodoWrite with the TDD cycle tasks:
```
1. [in_progress] RED: 编写失败测试
2. [pending] GREEN: 最小实现使测试通过
3. [pending] REFACTOR: 清理代码
```

2. **DO NOT** write any implementation code until the test file exists and the test fails

## Red-Green-Refactor

```
RED: Write failing test → Verify failure    ← 必须看到测试失败！
GREEN: Minimal implementation → Verify pass
REFACTOR: Clean up → Verify still passes
```

<HARD-GATE>
Before writing any implementation code:
1. Test file must exist
2. Test must have been run and FAILED
3. You must have seen the failure output
</HARD-GATE>

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

## Edge Cases MUST Test

**对于每个功能，必须测试以下边界条件：**

### 数据操作类

| 场景 | 测试要点 |
|------|----------|
| 插入空数据 | 空字符串、None、空列表 |
| 插入已存在 ID | INSERT OR REPLACE 行为 |
| 更新不存在记录 | 返回值/异常处理 |
| 删除不存在记录 | 返回值/异常处理 |
| 批量操作 | 空列表、部分失败 |

### 示例：Repository 边界测试

```python
class TestDepartmentRepository:

    def test_save_with_existing_id(self, repo):
        """测试：保存已存在 ID 的记录（应该更新或替换）"""
        # 先插入一条
        dept1 = Department(id=1, name="部门A", level=0)
        repo.save(dept1)

        # 用相同 ID 保存新数据
        dept2 = Department(id=1, name="部门B", level=1)
        repo.save(dept2)

        # 验证：应该是更新，不是新增
        assert repo.count() == 1
        found = repo.find_by_id(1)
        assert found.name == "部门B"

    def test_save_with_none_id(self, repo):
        """测试：保存 ID 为 None 的记录（应该自动生成 ID）"""
        dept = Department(id=None, name="新部门", level=0)
        saved = repo.save(dept)

        assert saved.id is not None
        assert repo.count() == 1

    def test_save_all_empty_list(self, repo):
        """测试：批量保存空列表"""
        result = repo.save_all([])
        assert result == []
        assert repo.count() == 0

    def test_save_all_mixed_ids(self, repo):
        """测试：批量保存混合 ID（有/无）"""
        depts = [
            Department(id=1, name="部门A", level=0),  # 有 ID
            Department(id=None, name="部门B", level=0),  # 无 ID
        ]
        saved = repo.save_all(depts)

        assert repo.count() == 2
        assert saved[0].id == 1
        assert saved[1].id is not None
```

### UI 组件类

| 场景 | 测试要点 |
|------|----------|
| 空数据显示 | 无数据时的默认状态 |
| 超长文本 | 文本截断、省略号 |
| 特殊字符 | emoji、换行、HTML |
| 极端数值 | 0、负数、超大数 |

<HARD-GATE>
**每个 Repository 类必须测试：**
1. `save(id=None)` - 自动生成 ID
2. `save(id=existing_id)` - 更新已存在记录
3. `save_all([])` - 空列表处理
4. `delete(non_existent_id)` - 删除不存在记录

**未覆盖边界条件的测试不算完成！**
</HARD-GATE>
