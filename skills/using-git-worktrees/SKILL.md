---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans
---

# Using Git Worktrees

## Overview

Git worktree 允许在同一仓库中检出多个分支到不同目录，实现隔离开发。

**为什么使用 worktree:**
- 不污染 main 分支
- 可以同时开发多个功能
- 快速切换上下文
- 保护正在进行的工作

## When to Use

**应该使用 worktree:**
- 开始新功能开发
- 执行实现计划前
- 需要临时切换到其他分支

**不需要 worktree:**
- 小修复（直接在分支上修改）
- 文档更新
- 不涉及代码的变更

## Quick Start

### Create Worktree

```bash
# 方式一：创建新分支的 worktree
git worktree add .claude/worktrees/feature-name -b feature/feature-name

# 方式二：基于现有分支创建
git worktree add .claude/worktrees/feature-name feature/existing-branch

# 方式三：从远程分支创建
git worktree add .claude/worktrees/feature-name -b feature/name origin/main
```

### List Worktrees

```bash
git worktree list
```

输出示例：
```
C:/Users/user/project          abc1234 [main]
C:/Users/user/project/.claude/worktrees/feature-x  def5678 [feature/feature-x]
```

### Remove Worktree

```bash
# 删除前先合并或放弃更改
git worktree remove .claude/worktrees/feature-name

# 强制删除（有未提交更改时）
git worktree remove --force .claude/worktrees/feature-name
```

## Workflow Integration

### Starting a New Feature

```bash
# 1. 确保 main 分支是最新的
git checkout main
git pull origin main

# 2. 创建 worktree
git worktree add .claude/worktrees/user-card -b feature/user-card

# 3. 切换到 worktree 目录
cd .claude/worktrees/user-card

# 4. 开始开发
# ... coding ...
```

### After Feature Complete

```bash
# 1. 确保所有更改已提交
git status

# 2. 推送分支
git push origin feature/user-card

# 3. 创建 PR 或合并到 main
# ...

# 4. 清理 worktree
cd ../..  # 返回主目录
git worktree remove .claude/worktrees/user-card
```

## Best Practices

### Directory Convention

```
project/
├── .claude/
│   └── worktrees/
│       ├── feature-user-card/
│       ├── feature-theme-switch/
│       └── bugfix-signal-issue/
├── app/
├── tests/
└── ...
```

### Naming Convention

| 类型 | 命名 | 示例 |
|------|------|------|
| 新功能 | `feature/{name}` | `feature/user-card` |
| Bug 修复 | `bugfix/{name}` | `bugfix/signal-connection` |
| 重构 | `refactor/{name}` | `refactor/theme-system` |
| 实验 | `experiment/{name}` | `experiment/new-layout` |

### Worktree Limits

建议同时最多 **3-5 个** worktree：
- 太多会占用磁盘空间
- 增加管理复杂度
- 定期清理完成的 worktree

## Common Commands

```bash
# 查看所有 worktree
git worktree list

# 创建 worktree
git worktree add <path> -b <branch>

# 删除 worktree
git worktree remove <path>

# 强制删除
git worktree remove --force <path>

# 清理无效的 worktree 引用
git worktree prune

# 锁定 worktree（防止被删除）
git worktree lock <path>

# 解锁 worktree
git worktree unlock <path>
```

## Troubleshooting

### "already checked out" 错误

```
fatal: 'feature/user-card' is already checked out at 'C:/project/.claude/worktrees/feature-user-card'
```

**解决:** 先删除旧的 worktree 或使用不同的分支名。

### Worktree 目录被锁定

```
fatal: cannot remove worktree: it is locked
```

**解决:** 先解锁再删除
```bash
git worktree unlock .claude/worktrees/feature-name
git worktree remove .claude/worktrees/feature-name
```

### 清理孤立 worktree

```bash
# 查看哪些 worktree 不再存在
git worktree prune --dry-run

# 清理
git worktree prune
```

## Integration

**Called before:**
- **writing-plans** - 编写计划前创建隔离环境
- **brainstorming** - 开始需求探索前（可选）

**Related skills:**
- **finishing-a-development-branch** - 完成后清理 worktree
