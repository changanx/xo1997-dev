---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

## Overview

功能开发完成后的收尾工作：验证、决策、集成。

**前置条件:**
- 所有代码已提交
- 所有测试通过
- 功能已验证

## The Process

### Step 1: Final Verification

```bash
# 运行所有测试
pytest tests/ -v

# 检查代码质量（可选）
ruff check app/
mypy app/

# 手动启动应用验证
python app/main.py
```

**验证清单:**
- [ ] 所有测试通过
- [ ] 新功能正常工作
- [ ] 没有引入回归
- [ ] 主题切换正常（如适用）
- [ ] 控制台无警告/错误

### Step 2: Review Changes

```bash
# 查看所有提交
git log main..HEAD --oneline

# 查看文件变更
git diff main...HEAD --stat

# 查看详细变更
git diff main...HEAD
```

**自检问题:**
- 提交历史是否清晰？
- 是否有需要合并的小提交？
- 是否有遗漏的文件？

### Step 3: Choose Integration Method

根据情况选择集成方式：

#### Option A: Create Pull Request (推荐)

适用于：
- 团队协作项目
- 需要 Code Review
- 有 CI/CD 流程

```bash
# 推送分支
git push origin feature/branch-name

# 创建 PR（使用 gh CLI 或 Web 界面）
gh pr create --title "feat: 功能描述" --body "## Summary\n\n- 变更1\n- 变更2"
```

#### Option B: Merge to Main

适用于：
- 个人项目
- 小型变更
- 无 CI/CD 流程

```bash
# 切换到 main
git checkout main

# 合并分支
git merge --no-ff feature/branch-name

# 推送
git push origin main
```

#### Option C: Squash and Merge

适用于：
- 提交历史较乱
- 想要保持 main 历史整洁

```bash
# 方式一：使用 git merge --squash
git checkout main
git merge --squash feature/branch-name
git commit -m "feat: 功能描述"

# 方式二：交互式 rebase
git checkout feature/branch-name
git rebase -i main
# 将多个 commit 合并为一个
git checkout main
git merge feature/branch-name
```

#### Option D: Rebase onto Main

适用于：
- 保持线性历史
- main 有新的提交

```bash
git checkout feature/branch-name
git rebase main

# 解决冲突后
git checkout main
git merge feature/branch-name
```

### Step 4: Cleanup

```bash
# 删除本地分支
git branch -d feature/branch-name

# 删除远程分支（如果已推送）
git push origin --delete feature/branch-name

# 删除 worktree（如果使用）
git worktree remove .claude/worktrees/branch-name

# 清理孤立引用
git worktree prune
git fetch --prune
```

## Decision Flow

```
                    ┌─────────────────┐
                    │ 功能开发完成？   │
                    └────────┬────────┘
                             │ 是
                             ▼
                    ┌─────────────────┐
                    │ 测试全部通过？   │
                    └────────┬────────┘
                             │ 是
                             ▼
                    ┌─────────────────┐
                    │ 需要代码审查？   │
                    └────────┬────────┘
                     │              │
                    是              否
                     │              │
                     ▼              ▼
              ┌──────────┐   ┌──────────────┐
              │ 创建 PR   │   │ 直接合并？    │
              └──────────┘   └──────┬───────┘
                                    │
                          ┌─────────┴─────────┐
                          │                   │
                         是                   否
                          │                   │
                          ▼                   ▼
                   ┌────────────┐     ┌────────────┐
                   │ merge --ff │     │ rebase or  │
                   │ 或 squash  │     │ 创建 PR    │
                   └────────────┘     └────────────┘
```

## Common Scenarios

### Scenario 1: Feature Complete, Ready for Review

```bash
# 1. 确认测试通过
pytest tests/ -v

# 2. 推送分支
git push origin feature/user-card

# 3. 创建 PR
gh pr create --title "feat: 添加用户卡片组件" --body "$(cat <<'EOF'
## Summary
- 创建 UserCard 组件
- 支持头像、名称、邮箱显示
- 支持点击信号

## Test plan
- [x] 单元测试通过
- [x] 手动测试正常
- [x] 主题切换正常
EOF
)"

# 4. 等待 Review
```

### Scenario 2: Quick Fix, Direct Merge

```bash
# 1. 确认测试通过
pytest tests/ -v

# 2. 切换到 main
git checkout main
git pull origin main

# 3. 合并
git merge --no-ff bugfix/signal-issue

# 4. 推送
git push origin main

# 5. 清理
git branch -d bugfix/signal-issue
```

### Scenario 3: Worktree Workflow

```bash
# 1. 在 worktree 中完成开发
cd .claude/worktrees/feature-user-card

# 2. 确认测试通过
pytest tests/ -v

# 3. 推送分支
git push origin feature/user-card

# 4. 返回主目录
cd ../..

# 5. 创建 PR 或合并
# ...

# 6. 清理 worktree
git worktree remove .claude/worktrees/feature-user-card
```

## Checklist

Before marking complete:

- [ ] 所有测试通过
- [ ] 代码已提交
- [ ] 变更已审查
- [ ] 选择了合适的集成方式
- [ ] 分支已合并或创建 PR
- [ ] Worktree 已清理（如使用）
- [ ] 通知相关人员（如需要）

## Integration

**Called after:**
- **executing-plans** - 所有任务完成后
- **verification-before-completion** - 验证通过后

**Related skills:**
- **using-git-worktrees** - 创建隔离环境
- **committing-changes** - 提交规范
