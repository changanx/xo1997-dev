---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging for PySide6

## Overview

随机修复浪费时间并引入新 bug。系统化调试找到根本原因。

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## The Four Phases

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

#### 1. Read Error Messages Carefully

```
# Python traceback 包含关键信息
Traceback (most recent call last):
  File "app/main.py", line 42, in <module>
    window.show()
  File "app/view/main_window.py", line 28, in __init__
    self.initNavigation()
AttributeError: 'MainWindow' object has no attribute 'homeInterface'
```

**关注：**
- 文件名和行号
- 错误类型
- 调用栈顺序

#### 2. Reproduce Consistently

```python
# 确定复现步骤
1. 启动应用
2. 点击设置按钮
3. 切换主题
4. 应用崩溃  <- 问题点
```

**问题：**
- 能否稳定复现？
- 每次都发生吗？
- 有什么规律？

#### 3. Check Recent Changes

```bash
# 查看最近修改
git log --oneline -10
git diff HEAD~1

# 查看特定文件的修改
git log -p app/view/main_window.py
```

#### 4. Trace Data Flow

```python
# 在关键位置添加日志
def setUser(self, user):
    print(f"[DEBUG] setUser called with: {user}")  # 添加
    print(f"[DEBUG] user type: {type(user)}")       # 添加
    self._user = user
    self._updateUI()

def _updateUI(self):
    print(f"[DEBUG] _updateUI, _user = {self._user}")  # 添加
    self.nameLabel.setText(self._user.name)
```

### Phase 2: Pattern Analysis

#### 1. Find Working Examples

```python
# 在代码库中查找类似的正常工作代码
# 搜索：
grep -r "setUser" app/
grep -r "CardWidget" app/components/

# 对比工作代码和问题代码
```

#### 2. Compare Against References

```python
# 检查 PyQt-Fluent-Widgets 示例
# C:\Users\m1582\Desktop\AI\PyQt-Fluent-Widgets\examples\
```

#### 3. Identify Differences

列出问题代码和工作代码的每个差异：

| 方面 | 工作代码 | 问题代码 |
|------|----------|----------|
| 父类 | CardWidget | QWidget |
| 信号连接 | _connectSignals() | 缺失 |
| objectName | 已设置 | 未设置 |

### Phase 3: Hypothesis and Testing

#### 1. Form Single Hypothesis

```
假设: "点击信号没有被发射，因为信号没有正确连接"

理由:
1. 组件继承 CardWidget
2. CardWidget 的 mouseReleaseEvent 需要调用 super()
3. 当前代码没有调用 super().mouseReleaseEvent(e)
```

#### 2. Test Hypothesis

```python
# 添加调试代码验证假设
def mouseReleaseEvent(self, e):
    print(f"[DEBUG] mouseReleaseEvent called")  # 添加
    super().mouseReleaseEvent(e)                 # 可能的修复
    self.clicked.emit()
    print(f"[DEBUG] clicked signal emitted")     # 添加
```

#### 3. Verify or Refute

```bash
# 运行测试或启动应用
pytest tests/test_components/test_user_card.py -v

# 或
python app/main.py
```

### Phase 4: Fix and Verify

#### 1. Implement Minimal Fix

只修复根本原因，不要"顺便"做其他修改：

```python
# 修复前
def mouseReleaseEvent(self, e):
    self.clicked.emit()

# 修复后（最小化）
def mouseReleaseEvent(self, e):
    super().mouseReleaseEvent(e)  # 添加这一行
    self.clicked.emit()
```

#### 2. Write Regression Test

```python
# tests/test_components/test_user_card.py
def test_click_signal_with_parent(qtbot: QtBot):
    """Regression test: click signal should work with CardWidget"""
    card = UserCard()
    qtbot.addWidget(card)
    
    with qtbot.waitSignal(card.clicked, timeout=1000):
        qtbot.mouseClick(card, Qt.LeftButton)
    
    assert True  # 信号被发射
```

#### 3. Run All Tests

```bash
pytest tests/ -v
```

---

## Qt/PySide6 Specific Debugging

### 1. Signal/Slot Debugging

```python
from PySide6.QtCore import QObject

# 检查信号是否有接收者
print(f"Receivers: {self.receivers(self.clicked)}")

# 临时断开所有信号
self.blockSignals(True)
# ... 操作 ...
self.blockSignals(False)

# 使用 qInstallMessageHandler 捕获 Qt 消息
from PySide6.QtCore import qInstallMessageHandler, QtMsgType

def message_handler(msg_type, context, msg):
    print(f"[Qt] {msg_type}: {msg}")

qInstallMessageHandler(message_handler)
```

### 2. Widget Lifecycle Debugging

```python
# 检查 widget 状态
print(f"Widget visible: {widget.isVisible()}")
print(f"Widget enabled: {widget.isEnabled()}")
print(f"Widget parent: {widget.parent()}")
print(f"Widget geometry: {widget.geometry()}")

# 检查布局
layout = widget.layout()
if layout:
    print(f"Layout count: {layout.count()}")
    for i in range(layout.count()):
        item = layout.itemAt(i)
        print(f"  Item {i}: {item.widget()}")
```

### 3. Memory Leak Detection

```python
# 检查对象是否被正确删除
import weakref

class MyWidget(CardWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._debug_ref = weakref.ref(self, lambda ref: print("Widget destroyed"))

# 如果输出没有显示 "Widget destroyed"，说明有内存泄漏
```

### 4. Threading Issues

```python
from PySide6.QtCore import QThread, QMetaObject, Qt

# 检查是否在主线程
print(f"In main thread: {QThread.currentThread() == QThread.mainThread()}")

# 跨线程调用应该使用信号
# 错误：直接调用
# other_widget.update()  # 如果 other_widget 在另一个线程

# 正确：使用信号
self.updateRequested.emit()  # 连接到 other_widget.update
```

### 5. StyleSheet Debugging

```python
# 检查应用的样式
print(f"Widget styleSheet: {widget.styleSheet()}")

# 检查有效样式
from PySide6.QtWidgets import QApplication
app = QApplication.instance()
print(f"App styleSheet: {app.styleSheet()}")

# 强制刷新样式
widget.style().unpolish(widget)
widget.style().polish(widget)
widget.update()
```

---

## Common Qt Bugs

| 问题 | 症状 | 原因 | 解决方案 |
|------|------|------|----------|
| **信号未发射** | 点击无响应 | 未调用 super() 或未连接 | 检查 connect() 和 super() |
| **布局问题** | 控件不显示 | 未设置 parent 或未添加到布局 | 检查 parent 和 layout.addWidget() |
| **内存泄漏** | 内存持续增长 | 循环引用或未删除 | 使用 weakref，检查 deleteLater() |
| **跨线程错误** | 随机崩溃 | 非 UI 线程操作 UI | 使用信号/槽跨线程通信 |
| **样式不生效** | QSS 无效 | objectName 未设置或语法错误 | 设置 objectName，检查 QSS 语法 |
| **事件循环阻塞** | UI 冻结 | 长时间操作在主线程 | 使用 QThread 或 QTimer |

---

## Debugging Checklist

### Phase 1 Checklist
- [ ] 仔细阅读错误信息和调用栈
- [ ] 确定稳定复现步骤
- [ ] 检查最近的代码变更
- [ ] 添加日志追踪数据流

### Phase 2 Checklist
- [ ] 找到类似的工作代码
- [ ] 对比差异
- [ ] 检查 PyQt-Fluent-Widgets 文档/示例

### Phase 3 Checklist
- [ ] 形成单一假设
- [ ] 添加调试代码验证假设
- [ ] 确认或否定假设

### Phase 4 Checklist
- [ ] 实现最小修复
- [ ] 编写回归测试
- [ ] 运行所有测试通过
- [ ] 清理调试代码

---

## Red Flags

**Never:**
- 不调查根本原因就直接修改代码
- "试试这个看看行不行"
- 同时修改多处代码
- 跳过编写回归测试
- 清理代码时"顺便"做其他修改

**Always:**
- 先理解问题，再修改
- 一次只改一处
- 写测试防止回归
- 提交前运行全部测试
