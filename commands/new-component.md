---
name: new-component
description: Create a new PySide6 UI component with tests
---

# Create New Component

Create a new reusable UI component following PyQt-Fluent-Widgets best practices.

## Parameters

Ask the user for:
1. **Component name** (e.g., UserCard, SearchBox, StatusBadge)
2. **Component type** (CardWidget, SimpleCardWidget, ElevatedCardWidget, or custom QWidget)
3. **Parent module** (components/, components/cards/, etc.)

## Process

1. Create component file: `app/components/{name.lower()}_widget.py`
2. Create test file: `tests/test_components/test_{name.lower()}.py`
3. Update `app/components/__init__.py`

## Template

### Component File (CardWidget)

```python
# app/components/{name}_widget.py
from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import QHBoxLayout, QVBoxLayout
from qfluentwidgets import (
    CardWidget, IconWidget, BodyLabel, CaptionLabel,
    TransparentToolButton, FluentIcon as FIF
)

from ..common.style_sheet import StyleSheet


class {Name}(CardWidget):
    """TODO: Description - supports hover highlight and click animation"""

    # Signals
    clicked = Signal()
    actionTriggered = Signal()

    def __init__(self, parent=None):
        super().__init__(parent=parent)

        # Set objectName for QSS selector
        self.setObjectName('{name}Card')

        self._initUI()
        self._initLayout()
        self._connectSignals()

        # Apply stylesheet
        StyleSheet.{NAME}_CARD.apply(self)

    def _initUI(self):
        """Initialize UI components"""
        # Icon/Avatar
        self.iconWidget = IconWidget(FIF.USER, self)

        # Labels
        self.titleLabel = BodyLabel("Title", self)
        self.subtitleLabel = CaptionLabel("Subtitle", self)

        # Set objectName for child widgets
        self.titleLabel.setObjectName('titleLabel')
        self.subtitleLabel.setObjectName('subtitleLabel')

        # Action button
        self.actionBtn = TransparentToolButton(FIF.MORE, self)

    def _initLayout(self):
        """Setup layout"""
        layout = QHBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 12)
        layout.setSpacing(12)

        # Left: Icon
        layout.addWidget(self.iconWidget)

        # Center: Info
        infoLayout = QVBoxLayout()
        infoLayout.setSpacing(4)
        infoLayout.addWidget(self.titleLabel)
        infoLayout.addWidget(self.subtitleLabel)
        layout.addLayout(infoLayout, 1)

        # Right: Action
        layout.addWidget(self.actionBtn)

    def _connectSignals(self):
        """Connect internal signals"""
        self.actionBtn.clicked.connect(self.actionTriggered.emit)

    def setTitle(self, title: str):
        """Set title text"""
        self.titleLabel.setText(title)

    def setSubtitle(self, subtitle: str):
        """Set subtitle text"""
        self.subtitleLabel.setText(subtitle)

    def mouseReleaseEvent(self, e):
        """Handle click - CardWidget provides hover/click animations"""
        super().mouseReleaseEvent(e)
        if e.button() == Qt.LeftButton:
            self.clicked.emit()
```

### Test File

```python
# tests/test_components/test_{name}.py
import pytest
from pytestqt.qtbot import QtBot
from PySide6.QtCore import Qt

from app.components.{name}_widget import {Name}


class Test{Name}:

    @pytest.fixture
    def widget(self, qtbot: QtBot):
        """Create widget instance"""
        w = {Name}()
        qtbot.addWidget(w)
        return w

    def test_creation(self, widget: {Name}):
        """Test widget can be created"""
        assert widget is not None

    def test_initial_state(self, widget: {Name}):
        """Test initial state"""
        assert widget.titleLabel.text() == "Title"
        assert widget.subtitleLabel.text() == "Subtitle"

    def test_set_title(self, widget: {Name}):
        """Test setting title"""
        widget.setTitle("New Title")
        assert widget.titleLabel.text() == "New Title"

    def test_set_subtitle(self, widget: {Name}):
        """Test setting subtitle"""
        widget.setSubtitle("New Subtitle")
        assert widget.subtitleLabel.text() == "New Subtitle"

    def test_click_signal(self, qtbot: QtBot, widget: {Name}):
        """Test click signal emission"""
        with qtbot.waitSignal(widget.clicked, timeout=1000):
            qtbot.mouseClick(widget, Qt.LeftButton)

    def test_action_signal(self, qtbot: QtBot, widget: {Name}):
        """Test action button signal"""
        with qtbot.waitSignal(widget.actionTriggered, timeout=1000):
            qtbot.mouseClick(widget.actionBtn, Qt.LeftButton)

    # TODO: Add more tests
```

## Card Type Selection Guide

| Type | Use When |
|------|----------|
| `CardWidget` | Component is interactive (clickable, hoverable) |
| `SimpleCardWidget` | Component is static display only |
| `ElevatedCardWidget` | Component needs visual emphasis |
| `QWidget` | Custom container without card appearance |

## Usage

```
/new-component
```

Then follow the prompts.
