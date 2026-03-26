---
name: committing-changes
description: Use when creating git commits.
---

# Committing Changes

## Overview

编写规范的 commit message，保持清晰、可搜索的 git 历史。

**核心原则：** commit message 告诉未来的开发者（包括你自己）改了什么、为什么改。

**Announce at start:** "I'm using the committing-changes skill to write the commit message."

## When to Use

**Always use this skill when:**
- Creating any git commit
- Amending commit messages
- Writing PR descriptions (same format applies)

## Conventional Commits Format

```
关联单号：<单号> <type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Rules:**
- 关联单号: **用户提供**，格式为 `关联单号：XXX`
- Type: lowercase, English
- Scope: lowercase, English, optional
- Description: **Chinese**, no period at end
- Body: **Chinese**, separated by blank line from description
- Footer: separated by blank line from body

## 关联单号

**格式:** `关联单号：<单号>`，放在 commit message 最前面

**来源:** 用户在提交时提供

**示例:**
```
关联单号：BUG-123 feat(user): 添加用户注册功能
关联单号：TASK-456 fix(auth): 修复 token 过期问题
关联单号：REQ-789 refactor(video): 提取缩略图生成逻辑
```

**如果用户未提供单号:**
- 询问用户是否有关联单号
- 如果没有，可以省略单号部分：`feat(user): 添加用户注册功能`

## Types

| Type | 用途 | 示例 |
|------|------|------|
| `feat` | 新功能 | `关联单号：REQ-123 feat(user): 添加用户注册功能` |
| `fix` | Bug 修复 | `关联单号：BUG-456 fix(auth): 修复 token 过期问题` |
| `docs` | 文档变更 | `关联单号：DOC-789 docs(api): 更新接口文档` |
| `style` | 代码格式（不影响逻辑） | `关联单号：TASK-101 style: 修复代码缩进` |
| `refactor` | 重构（不是新功能也不是修复） | `关联单号：TASK-202 refactor(user): 提取验证逻辑到独立服务` |
| `perf` | 性能优化 | `关联单号：PERF-303 perf(query): 优化数据库查询性能` |
| `test` | 测试相关 | `关联单号：TEST-404 test(user): 添加用户注册单元测试` |
| `build` | 构建系统变更 | `关联单号：TASK-505 build: 更新 Maven 依赖版本` |
| `ci` | CI/CD 配置变更 | `关联单号：TASK-606 ci: 添加代码检查工作流` |
| `chore` | 其他杂项 | `关联单号：TASK-707 chore: 清理无用导入` |
| `revert` | 回滚提交 | `关联单号：BUG-123 revert: feat(user): 添加用户注册功能` |

## Scopes

**Scope 可选但推荐使用。**

**常用 scope:**

### Spring Boot
| Scope | 模块 |
|-------|------|
| `user` | 用户模块 |
| `video` | 视频模块 |
| `auth` | 认证授权 |
| `common` | 公共组件 |
| `config` | 配置相关 |
| `db` | 数据库相关 |

### Vue 3
| Scope | 模块 |
|-------|------|
| `router` | 路由配置 |
| `store` | Pinia 状态管理 |
| `api` | API 接口 |
| `components` | 组件 |
| `views` | 页面视图 |
| `utils` | 工具函数 |

**不需要 scope 的情况:**
- 根级别变更: `chore: 更新 .gitignore`
- 跨模块变更: `refactor: 统一错误处理逻辑`

## Description Rules

**必须:**
- 使用中文描述
- 不加句号结尾
- 具体明确，简洁有力
- 控制在 50 字以内

**禁止:**
- 使用英文描述: ~~`add feature`~~
- 加句号结尾: ~~`添加用户注册功能。`~~
- 模糊描述: ~~`更新代码`~~、~~`修复问题`~~

**示例:**
```
✅ 关联单号：REQ-123 feat(user): 添加用户注册功能
✅ 关联单号：BUG-456 fix(auth): 修复 token 刷新竞态条件
✅ 关联单号：TASK-789 refactor(video): 提取缩略图生成逻辑到独立服务

❌ feat(user): add user registration
❌ feat(user): 添加用户注册功能。
❌ refactor: 一些修改
```

## Body (Optional)

**使用场景:**
- 变更原因不是显而易见
- 一个提交包含多个相关改动
- 需要解释 WHY（而非 WHAT）

**格式:**
```
关联单号：<单号> <type>(<scope>): <description>

解释变更的原因，对比之前的行为。
正文每行不超过 72 个字符。

- 支持列表形式
- 使用连字符作为列表标记
```

**示例:**
```
关联单号：REQ-101 feat(user): 添加邮箱验证功能

实现邮箱验证流程以减少垃圾账户注册。
用户注册后需在 24 小时内完成邮箱验证。

- 注册时发送验证邮件
- 添加验证令牌（含过期时间）
- 未验证用户禁止执行敏感操作
```

## Footer (Optional)

**使用场景:**

### Breaking Changes（破坏性变更）
```
BREAKING CHANGE: <中文描述>

[可选的迁移指南]
```

**示例:**
```
关联单号：TASK-202 refactor(api): 重命名用户接口路径

BREAKING CHANGE: 所有用户接口路径从 /users 改为 /api/users

迁移指南:
- /users -> /api/users
- /users/{id} -> /api/users/{id}
```

### Issue References（Issue 引用）
```
Closes #123
Fixes #456
Refs #789
```

**示例:**
```
关联单号：REQ-303 feat(user): 添加密码重置功能

Closes #123
```

### Co-authors（共同作者）
```
Co-authored-by: 姓名 <email@example.com>
```

## Complete Examples

### 带正文的特性提交
```
关联单号：REQ-401 feat(video): 添加视频上传进度追踪

实现视频上传的实时进度追踪功能。
每传输 100KB 更新一次进度。

- 添加 ProgressTracker 服务
- 与现有上传服务集成
- 通过 WebSocket 推送进度事件
```

### 带 Issue 的 Bug 修复
```
关联单号：BUG-502 fix(auth): 修复 JWT 验证绕过漏洞

之前的实现允许缺少签名的 token 通过验证。
现在显式检查签名是否存在。

Fixes #234
```

### 破坏性变更
```
关联单号：TASK-603 refactor(user): 重命名 UserDTO 为 UserResponse

BREAKING CHANGE: 为提高语义清晰度，UserDTO 重命名为 UserResponse

迁移指南:
- 所有导入语句中 UserDTO 替换为 UserResponse
- 前端代码同步更新相关引用
```

### 多项变更
```
关联单号：REQ-704 feat(user): 实现用户个人资料管理

添加完整的个人资料管理功能:
- 头像上传
- 资料字段更新
- 账户注销

- 添加 UserProfileService
- 添加资料相关接口
- 添加前端资料页面
- 添加集成测试

Closes #101, #102
```

### 重构
```
关联单号：TASK-805 refactor(video): 提取视频处理逻辑到独立服务

将视频处理逻辑从 VideoController 移至 VideoProcessingService，
提高关注点分离程度。

无功能变更。
```

### 测试添加
```
关联单号：TEST-906 test(user): 添加 UserService 单元测试

添加完整的单元测试覆盖:
- 用户创建
- 用户更新
- 用户删除
- 边界情况和错误处理

覆盖率从 60% 提升至 95%。
```

## Quick Reference

| 元素 | 规则 |
|------|------|
| 关联单号 | 可选，用户提供，格式：`关联单号：XXX` |
| Type | 必填，小写英文，从预定义列表选择 |
| Scope | 可选，小写英文，模块名称 |
| Description | 必填，中文，不加句号，<50 字 |
| Body | 可选，中文，解释 WHY，每行 <72 字 |
| Footer | 可选，BREAKING CHANGE、Issue 引用 |

## Common Mistakes

| 错误 | ❌ 错误 | ✅ 正确 |
|------|---------|---------|
| 使用英文 | `add feature` | `添加功能` |
| 加句号 | `添加功能。` | `添加功能` |
| 模糊描述 | `更新代码` | `添加用户验证逻辑` |
| 类型错误 | `feat: 修复bug` | `fix: 修复登录失败问题` |
| 缺少 scope | `feat: 添加用户注册` | `feat(user): 添加用户注册功能` |
| 缺少关联单号 | `feat(user): 添加功能` | `关联单号：REQ-123 feat(user): 添加功能` |

## Red Flags

**Never:**
- 使用英文描述
- 描述结尾加句号
- 使用模糊描述（"更新"、"修复"、"修改"）
- 一个提交包含多个不相关的变更
- 模块相关变更缺少 scope

**如果提交涉及多个模块:**
- 考虑拆分为多个提交
- 或使用更宽泛的 scope: `feat(core): 添加缓存层`

## Commit Frequency

**频繁提交，每次提交要小:**

```
✅ 推荐：多个小提交
关联单号：REQ-101 feat(user): 添加用户实体类
关联单号：TEST-102 test(user): 添加用户实体测试
关联单号：REQ-103 feat(user): 添加用户仓储接口
关联单号：TEST-104 test(user): 添加仓储测试

❌ 避免：一个大提交
关联单号：REQ-101 feat(user): 添加用户模块包含实体、仓储、服务、控制器和测试
```

**每个提交应该:**
- 代表一个逻辑变更
- 可以独立回滚
- 通过所有测试

## Integration

**Called by:**
- **xo1997-dev:test-driven-development** - GREEN 阶段后
- **xo1997-dev:subagent-driven-development** - 每个任务完成后
- **xo1997-dev:writing-plans** - 任务步骤中

**Workflow:**
```
完成变更 → 暂存文件 → 使用此技能 → 编写消息 → 提交
```

## Pre-commit Checklist

提交前检查:

- [ ] 变更已暂存 (`git add`)
- [ ] 所有测试通过 (`mvn test` 或 `npm test`)
- [ ] 关联单号已确认（询问用户或用户提供）
- [ ] Type 正确
- [ ] Scope 合适（或不适用时省略）
- [ ] Description 使用中文，无句号结尾
- [ ] 变更原因不明确时添加了 Body
- [ ] 破坏性变更或 Issue 引用添加了 Footer