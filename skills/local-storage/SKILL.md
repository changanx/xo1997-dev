---
name: local-storage
description: Use when implementing local data persistence with SQLite - provides database design, repository patterns, and testing strategies
---

# Local Storage with SQLite

## Overview

PySide6 客户端使用 SQLite 作为本地数据存储方案。本技能涵盖数据库设计、Repository 模式、与 Qt 的集成。

## Architecture

```
app/
├── data/
│   ├── __init__.py
│   ├── database.py        # 数据库连接管理
│   ├── models/            # 数据模型
│   │   ├── __init__.py
│   │   └── user.py
│   └── repositories/      # 数据访问层
│       ├── __init__.py
│       └── user_repository.py
└── ...
```

## Database Connection

### Connection Manager

```python
# app/data/database.py
from pathlib import Path
from typing import Optional
import sqlite3
from contextlib import contextmanager

from PySide6.QtCore import QStandardPaths


class Database:
    """SQLite 数据库连接管理器"""

    _instance: Optional['Database'] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return

        # 数据库路径
        data_dir = Path(QStandardPaths.writableLocation(QStandardPaths.AppDataLocation))
        data_dir.mkdir(parents=True, exist_ok=True)
        self.db_path = data_dir / "app.db"

        self._connection: Optional[sqlite3.Connection] = None
        self._initialized = True

    @property
    def connection(self) -> sqlite3.Connection:
        """获取数据库连接"""
        if self._connection is None:
            self._connection = sqlite3.connect(
                str(self.db_path),
                check_same_thread=False
            )
            self._connection.row_factory = sqlite3.Row
            self._enable_foreign_keys()
        return self._connection

    def _enable_foreign_keys(self):
        """启用外键约束"""
        self.connection.execute("PRAGMA foreign_keys = ON")

    @contextmanager
    def transaction(self):
        """事务上下文管理器"""
        conn = self.connection
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise

    def close(self):
        """关闭连接"""
        if self._connection:
            self._connection.close()
            self._connection = None

    def execute_script(self, script: str):
        """执行 SQL 脚本"""
        self.connection.executescript(script)


# 全局实例
db = Database()
```

## Models

### Data Model

```python
# app/data/models/user.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class User:
    """用户数据模型"""
    id: Optional[int] = None
    name: str = ""
    email: str = ""
    avatar_path: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @classmethod
    def from_row(cls, row: sqlite3.Row) -> 'User':
        """从数据库行创建实例"""
        return cls(
            id=row['id'],
            name=row['name'],
            email=row['email'],
            avatar_path=row['avatar_path'],
            created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None,
            updated_at=datetime.fromisoformat(row['updated_at']) if row['updated_at'] else None,
        )
```

## Repository Pattern

### Base Repository

```python
# app/data/repositories/base.py
from abc import ABC, abstractmethod
from typing import TypeVar, Generic, List, Optional
import sqlite3

from app.data.database import db

T = TypeVar('T')


class BaseRepository(ABC, Generic[T]):
    """Repository 基类"""

    @property
    @abstractmethod
    def table_name(self) -> str:
        """表名"""
        pass

    @abstractmethod
    def from_row(self, row: sqlite3.Row) -> T:
        """从数据库行创建模型实例"""
        pass

    def find_by_id(self, id: int) -> Optional[T]:
        """根据 ID 查找"""
        cursor = db.connection.execute(
            f"SELECT * FROM {self.table_name} WHERE id = ?",
            (id,)
        )
        row = cursor.fetchone()
        return self.from_row(row) if row else None

    def find_all(self) -> List[T]:
        """查找所有"""
        cursor = db.connection.execute(
            f"SELECT * FROM {self.table_name}"
        )
        return [self.from_row(row) for row in cursor.fetchall()]

    def delete(self, id: int) -> bool:
        """删除"""
        cursor = db.connection.execute(
            f"DELETE FROM {self.table_name} WHERE id = ?",
            (id,)
        )
        db.connection.commit()
        return cursor.rowcount > 0

    def count(self) -> int:
        """计数"""
        cursor = db.connection.execute(
            f"SELECT COUNT(*) FROM {self.table_name}"
        )
        return cursor.fetchone()[0]
```

### Concrete Repository

```python
# app/data/repositories/user_repository.py
from typing import List, Optional
from datetime import datetime

from app.data.repositories.base import BaseRepository
from app.data.models.user import User
from app.data.database import db


class UserRepository(BaseRepository[User]):
    """用户数据仓库"""

    @property
    def table_name(self) -> str:
        return "users"

    def from_row(self, row) -> User:
        return User.from_row(row)

    def find_by_email(self, email: str) -> Optional[User]:
        """根据邮箱查找"""
        cursor = db.connection.execute(
            "SELECT * FROM users WHERE email = ?",
            (email,)
        )
        row = cursor.fetchone()
        return User.from_row(row) if row else None

    def search(self, keyword: str) -> List[User]:
        """搜索用户"""
        cursor = db.connection.execute(
            "SELECT * FROM users WHERE name LIKE ? OR email LIKE ?",
            (f"%{keyword}%", f"%{keyword}%")
        )
        return [User.from_row(row) for row in cursor.fetchall()]

    def create(self, user: User) -> User:
        """创建用户"""
        now = datetime.now().isoformat()
        cursor = db.connection.execute(
            """
            INSERT INTO users (name, email, avatar_path, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (user.name, user.email, user.avatar_path, now, now)
        )
        db.connection.commit()
        user.id = cursor.lastrowid
        user.created_at = datetime.fromisoformat(now)
        user.updated_at = datetime.fromisoformat(now)
        return user

    def update(self, user: User) -> User:
        """更新用户"""
        now = datetime.now().isoformat()
        db.connection.execute(
            """
            UPDATE users
            SET name = ?, email = ?, avatar_path = ?, updated_at = ?
            WHERE id = ?
            """,
            (user.name, user.email, user.avatar_path, now, user.id)
        )
        db.connection.commit()
        user.updated_at = datetime.fromisoformat(now)
        return user

    def save(self, user: User) -> User:
        """保存用户（创建或更新）"""
        if user.id is None:
            return self.create(user)
        return self.update(user)
```

## Schema Migration

### Initial Schema

```python
# app/data/migrations.py
from app.data.database import db

INITIAL_SCHEMA = """
-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    avatar_path TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_name ON users(name);

-- 设置表
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TEXT NOT NULL
);
"""


def init_database():
    """初始化数据库"""
    db.execute_script(INITIAL_SCHEMA)


def migrate_database():
    """数据库迁移"""
    # 检查版本
    cursor = db.connection.execute(
        "SELECT value FROM settings WHERE key = 'schema_version'"
    )
    row = cursor.fetchone()

    current_version = int(row['value']) if row else 0

    # 根据版本执行迁移
    if current_version < 1:
        db.execute_script(INITIAL_SCHEMA)
        db.connection.execute(
            "INSERT INTO settings (key, value, updated_at) VALUES ('schema_version', '1', datetime('now'))"
        )
        db.connection.commit()

    # 未来迁移...
    # if current_version < 2:
    #     db.execute_script(MIGRATION_2)
```

## Qt Integration

### Initialize on App Start

```python
# app/main.py
import sys
from PySide6.QtWidgets import QApplication
from app.data.migrations import init_database
from app.view.main_window import MainWindow


def main():
    app = QApplication(sys.argv)

    # 初始化数据库
    init_database()

    window = MainWindow()
    window.show()

    result = app.exec()

    # 清理
    from app.data.database import db
    db.close()

    sys.exit(result)


if __name__ == "__main__":
    main()
```

### Use in Components

```python
# app/components/user_list_widget.py
from typing import List
from qfluentwidgets import CardWidget, BodyLabel, VBoxContainer
from PySide6.QtCore import Signal, QThread

from app.data.models.user import User
from app.data.repositories.user_repository import UserRepository


class UserListWidget(CardWidget):
    """用户列表组件"""

    userSelected = Signal(object)  # User

    def __init__(self, parent=None):
        super().__init__(parent)
        self._repository = UserRepository()
        self._users: List[User] = []

        self._initUI()
        self._loadUsers()

    def _initUI(self):
        # ... UI 初始化
        pass

    def _loadUsers(self):
        """加载用户列表"""
        self._users = self._repository.find_all()
        self._refreshUI()

    def refresh(self):
        """刷新列表"""
        self._loadUsers()

    def search(self, keyword: str):
        """搜索用户"""
        if keyword:
            self._users = self._repository.search(keyword)
        else:
            self._users = self._repository.find_all()
        self._refreshUI()
```

## Testing

### Test Database Setup

```python
# tests/conftest.py
import pytest
import sqlite3
from pathlib import Path
import tempfile

from app.data.database import Database


@pytest.fixture
def temp_db():
    """临时数据库 fixture"""
    # 创建临时文件
    fd, path = tempfile.mkstemp(suffix='.db')

    # 替换数据库路径
    old_instance = Database._instance
    Database._instance = None

    db = Database()
    db.db_path = Path(path)
    db._initialized = True

    # 初始化 schema
    from app.data.migrations import init_database
    init_database()

    yield db

    # 清理
    db.close()
    Database._instance = old_instance

    import os
    os.close(fd)
    os.unlink(path)


@pytest.fixture
def user_repository(temp_db):
    """用户仓库 fixture"""
    from app.data.repositories.user_repository import UserRepository
    return UserRepository()
```

### Repository Tests

```python
# tests/test_data/test_user_repository.py
import pytest
from datetime import datetime

from app.data.models.user import User
from app.data.repositories.user_repository import UserRepository


class TestUserRepository:

    def test_create_user(self, user_repository: UserRepository):
        """测试创建用户"""
        user = User(name="张三", email="zhang@example.com")

        created = user_repository.create(user)

        assert created.id is not None
        assert created.name == "张三"
        assert created.created_at is not None

    def test_find_by_id(self, user_repository: UserRepository):
        """测试根据 ID 查找"""
        user = User(name="李四", email="li@example.com")
        created = user_repository.create(user)

        found = user_repository.find_by_id(created.id)

        assert found is not None
        assert found.name == "李四"

    def test_find_by_email(self, user_repository: UserRepository):
        """测试根据邮箱查找"""
        user = User(name="王五", email="wang@example.com")
        user_repository.create(user)

        found = user_repository.find_by_email("wang@example.com")

        assert found is not None
        assert found.name == "王五"

    def test_search(self, user_repository: UserRepository):
        """测试搜索"""
        user_repository.create(User(name="张三", email="zhang@example.com"))
        user_repository.create(User(name="李四", email="li@example.com"))

        results = user_repository.search("张")

        assert len(results) == 1
        assert results[0].name == "张三"

    def test_update_user(self, user_repository: UserRepository):
        """测试更新用户"""
        user = user_repository.create(User(name="张三", email="zhang@example.com"))

        user.name = "张三三"
        updated = user_repository.update(user)

        assert updated.name == "张三三"

    def test_delete_user(self, user_repository: UserRepository):
        """测试删除用户"""
        user = user_repository.create(User(name="张三", email="zhang@example.com"))

        result = user_repository.delete(user.id)

        assert result is True
        assert user_repository.find_by_id(user.id) is None
```

## Best Practices

### 1. 使用事务

```python
# 好：使用事务
with db.transaction() as conn:
    conn.execute("INSERT INTO users ...")
    conn.execute("INSERT INTO logs ...")
# 自动提交或回滚

# 坏：手动管理
conn = db.connection
conn.execute("INSERT INTO users ...")
# 如果这里出错，上面的数据不会回滚
conn.execute("INSERT INTO logs ...")
conn.commit()
```

### 2. 参数化查询

```python
# 好：参数化查询
cursor = db.connection.execute(
    "SELECT * FROM users WHERE name = ?",
    (name,)
)

# 坏：字符串拼接（SQL 注入风险）
cursor = db.connection.execute(
    f"SELECT * FROM users WHERE name = '{name}'"
)
```

### 3. 连接管理

```python
# 好：单例 + 延迟初始化
db = Database()
# 使用时才创建连接
user = UserRepository().find_by_id(1)

# 坏：每次操作创建新连接
def get_user(id):
    conn = sqlite3.connect('app.db')  # 性能差
    ...
    conn.close()
```

### 4. 异步考虑

SQLite 写操作会阻塞，长时间写入应考虑：

```python
from PySide6.QtCore import QThread, Signal

class DatabaseWriter(QThread):
    """后台数据库写入线程"""
    finished = Signal(bool)

    def __init__(self, operation, *args):
        super().__init__()
        self.operation = operation
        self.args = args

    def run(self):
        try:
            self.operation(*self.args)
            self.finished.emit(True)
        except Exception as e:
            print(f"Database error: {e}")
            self.finished.emit(False)
```

## Checklist

- [ ] 数据库文件路径使用 QStandardPaths
- [ ] 启用外键约束
- [ ] 使用事务保证数据一致性
- [ ] 参数化查询防止 SQL 注入
- [ ] Repository 模式分离数据访问逻辑
- [ ] 编写 Repository 单元测试
- [ ] 应用退出时关闭数据库连接
