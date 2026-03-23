# 前端开发流程适配设计文档

> 创建时间: 2026-03-17
> 状态: 待审查

---

## 1. 概述

### 1.1 目标

将 xo1997-dev 插件扩展为支持 Vue3 + Vite + Element Plus 前端开发工作流，并实现前后端 Agent Team 协作模式。

### 1.2 背景

当前 xo1997-dev 插件仅支持 Spring Boot 2.7.18 + MyBatis-Plus 3.5.7 后端项目开发。实际项目中前端使用 Vue3 + Vite + Element Plus，前后端分离仓库、并行开发，缺少前端标准化开发流程和前后端协作机制。

### 1.3 范围

**包含：**
- 前端技能层设计与实现
- Agent Team 协作模式设计
- 设计文档模板增强
- 执行模式选择逻辑

**不包含：**
- 具体技能内容的详细编写（在实现阶段完成）
- CI/CD 流程
- 部署流程

---

## 2. 架构设计

### 2.1 整体架构

采用分层架构：基础层（通用流程）+ 特性层（前端/后端技能）

```
xo1997-dev/
├── skills/                          # 基础层（通用流程技能）
│   ├── brainstorming/               # 需求探索（前后端共用）
│   ├── writing-plans/               # 计划编写 ← 执行模式决策点
│   ├── subagent-driven-development/ # 单端开发执行模式
│   ├── team-driven-development/     # 新增：前后端协作执行模式
│   ├── test-driven-development/     # TDD（前后端共用）
│   ├── systematic-debugging/        # 调试（前后端共用）
│   ├── verification-before-completion/
│   ├── using-git-worktrees/
│   ├── requesting-code-review/
│   └── ...
│
├── frontend/                        # 前端特性层
│   ├── skills/
│   │   ├── vue3-best-practices/     # Vue3 开发规范
│   │   ├── vue3-project-structure/  # 项目结构规范
│   │   ├── vue3-component-dev/      # 组件开发流程
│   │   ├── vue3-api-integration/    # API 对接流程
│   │   ├── vue3-state-management/   # 状态管理（Pinia/Vuex）
│   │   └── vue3-testing/            # 前端测试（Vitest）
│   └── references/
│       └── project-structure.md     # 项目结构参考
│
├── backend/                         # 后端特性层（现有内容迁移）
│   ├── skills/
│   │   ├── springboot-best-practices/
│   │   ├── mybatis-plus-patterns/
│   │   └── springboot-unified-response/
│   └── references/
│
└── agents/
    ├── frontend-developer.md        # 前端开发 Agent
    ├── backend-developer.md         # 后端开发 Agent
    └── team-coordinator.md          # 队长 Agent（协调 + Review）
```

### 2.2 执行模式选择

在 `writing-plans` 环节，根据任务涉及范围选择执行模式：

```
计划编写完成
    │
    ├─ 涉及范围？
    │       │
    │       ├─ 仅后端 → subagent-driven-development
    │       │
    │       ├─ 仅前端 → subagent-driven-development
    │       │
    │       └─ 前后端都有 → team-driven-development
    │                        │
    │                        ├─ team-coordinator (队长)
    │                        ├─ frontend-developer
    │                        └─ backend-developer
```

### 2.3 数据流

```
用户需求
    │
    ▼
brainstorming（通用）
    │ 输出：设计文档（含前端+后端设计）
    ▼
writing-plans（通用）
    │ 分析涉及范围
    │ 输出：前端任务列表 + 后端任务列表
    │
    ├──────────────┬──────────────┐
    │              │              │
    ▼              ▼              ▼
单端开发      单端开发      Team 开发
(subagent)    (subagent)   (Agent Team)
```

---

## 3. 详细设计

### 3.1 Agent Team 协作模式

#### 角色定义

| 角色 | 职责 | 输入 | 输出 |
|------|------|------|------|
| **team-coordinator** | 协调分工、监控进度、Code Review、处理阻塞 | 设计文档、实现计划 | 协调决策、Review 结果 |
| **frontend-developer** | 前端功能实现 | 前端计划任务、API 定义 | 页面、组件、API 调用代码 |
| **backend-developer** | 后端功能实现 | 后端计划任务 | Controller、Service、Mapper 代码 |

#### Agent 通信机制

Agent 之间通过共享文件进行通信：

```
.claude/team-session/
├── design-doc.md           # 设计文档（只读，所有 Agent 共享）
├── plan.md                 # 实现计划（只读，所有 Agent 共享）
├── frontend-tasks.md       # 前端任务状态
├── backend-tasks.md        # 后端任务状态
├── api-changes.md          # API 变更记录
├── blockers.md             # 阻塞问题记录
└── review-feedback/        # Review 反馈
    ├── frontend.md
    └── backend.md
```

**通信规则：**

| 事件 | 操作 | 文件 |
|------|------|------|
| 任务开始 | 更新状态为 `in_progress` | `*-tasks.md` |
| 任务完成 | 更新状态为 `completed`，记录产出 | `*-tasks.md` |
| 遇到阻塞 | 写入阻塞描述 | `blockers.md` |
| API 变更 | 记录变更内容和原因 | `api-changes.md` |
| Review 反馈 | 写入反馈内容 | `review-feedback/*.md` |

#### 协作流程

```
Phase 1: 计划分发
team-coordinator 分析计划，识别依赖关系，派发任务

Phase 2: 并行开发
┌─────────────────┬─────────────────┐
│ backend-developer │ frontend-developer │
│ - 实现后端接口    │ - 实现前端页面     │
│ - TDD 开发       │ - TDD 开发        │
│ - 完成后通知队长  │ - 完成后通知队长   │
└─────────────────┴─────────────────┘

Phase 3: Code Review（每端完成后）
team-coordinator 审查代码
- 规范符合性检查
- 代码质量检查
- 反馈修复或确认通过

Phase 4: API 变更处理（如需要）
任一方发现需要变更 API：
1. 更新设计文档
2. team-coordinator 通知对应方
3. 对应方调整实现

Phase 5: 联调验证（全部完成后）
team-coordinator 协调联调
- 确认前后端对接正确
- 验证完整流程
```

### 3.2 前端技能设计

#### 技能清单

| 技能 | 触发条件 | 说明 |
|------|----------|------|
| **vue3-best-practices** | 开发 Vue3 项目 | 组合式 API、生命周期、响应式规范 |
| **vue3-project-structure** | 创建/重构项目结构 | 目录规范、命名约定、模块划分 |
| **vue3-component-dev** | 开发 Vue 组件 | 组件设计、Props/Emits、插槽规范 |
| **vue3-api-integration** | 对接后端 API | 基于 API 定义生成请求代码、类型定义 |
| **vue3-state-management** | 状态管理开发 | Pinia/Vuex store 设计、使用规范 |
| **vue3-testing** | 前端测试 | Vitest 组件测试、E2E 测试 |

#### API 对接技能详细设计

**触发条件**：前端开发需要对接后端 API

**输入**：设计文档中的 API 定义和 DTO/VO 结构

```
| POST | /api/users | 创建用户 | UserCreateDTO | Result<UserVO> |
```

**输出**：
```
src/api/user.js          # API 请求函数
src/api/types/user.ts    # TypeScript 类型定义（如使用 TS）
```

**生成示例**：

```javascript
// src/api/user.js
import request from '@/utils/request'

/**
 * 创建用户
 * @param {Object} data - UserCreateDTO
 * @returns {Promise<Result<UserVO>>}
 */
export function createUser(data) {
  return request({
    url: '/api/users',
    method: 'post',
    data
  })
}

/**
 * 获取用户列表
 * @param {Object} params - 查询参数
 * @returns {Promise<Result<Page<UserVO>>>}
 */
export function fetchUsers(params) {
  return request({
    url: '/api/users',
    method: 'get',
    params
  })
}
```

### 3.3 设计文档模板增强

**目标文件**：`xo1997-dev/docs/templates/design-document-template.md`

**修改方式**：在现有模板基础上新增前端设计章节（3.4 节）

**新增内容**：

```markdown
## 3. 详细设计

### 3.1 API 设计（现有，前后端共用）

| 方法 | 路径 | 描述 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| GET | /api/users | 获取用户列表 | - | Result<Page<UserVO>> |
| POST | /api/users | 创建用户 | UserCreateDTO | Result<UserVO> |
| ... | ... | ... | ... | ... |

### 3.2 数据模型（现有，后端）

### 3.3 数据库设计（现有，后端）

### 3.4 前端设计（新增）

#### 页面结构

| 页面 | 路由 | 组件 | 说明 |
|------|------|------|------|
| 用户列表 | /users | views/user/UserList.vue | 用户管理列表页 |
| 用户详情 | /users/:id | views/user/UserDetail.vue | 用户详情页 |
| 用户新增 | /users/create | views/user/UserForm.vue | 新增用户表单 |

#### 组件设计

| 组件名 | 路径 | Props | Emits | 说明 |
|--------|------|-------|-------|------|
| UserTable | components/user/UserTable.vue | users, loading | edit, delete | 用户列表表格 |
| UserForm | components/user/UserForm.vue | user?, mode | submit, cancel | 用户表单（新增/编辑）|
| UserSearch | components/user/UserSearch.vue | - | search | 搜索筛选组件 |

#### 状态管理

| Store | 文件 | State | Actions | 说明 |
|-------|------|-------|---------|------|
| useUserStore | stores/user.js | users, currentUser, loading | fetchUsers, createUser, updateUser | 用户状态管理 |

#### API 调用映射

| 页面/组件 | API 函数 | 调用时机 | 说明 |
|-----------|----------|----------|------|
| UserList.vue | fetchUsers | onMounted | 加载用户列表 |
| UserForm.vue | createUser | submit | 创建用户 |
| UserForm.vue | updateUser | submit | 更新用户 |
```

### 3.4 team-driven-development 技能设计

**触发条件**：`writing-plans` 判定任务涉及前后端

**流程**：

```
Step 1: 计划分发
- team-coordinator 分析任务依赖
- 确定并行/串行执行顺序
- 派发任务给 frontend-developer 和 backend-developer

Step 2: 并行开发
- 各 Agent 独立完成分配任务
- 遵循 TDD 流程
- 遇到阻塞上报 team-coordinator

Step 3: Code Review（每端完成后）
- team-coordinator 执行双阶段审查
  - 阶段1: 规范符合性
  - 阶段2: 代码质量
- 反馈修复或确认通过

Step 4: API 变更同步
- 任一方需变更 API 时
- 更新设计文档
- team-coordinator 通知对应方

Step 5: 联调验证
- team-coordinator 协调联调
- 验证前后端对接正确
- 确认完整流程通过

Step 6: 完成处理
- 调用 `skills/finishing-a-development-branch/SKILL.md` 技能
- 处理分支合并/PR
```

---

## 4. 错误处理

### 4.1 常见错误场景

| 场景 | 处理方式 |
|------|----------|
| API 定义不明确 | team-coordinator 协调前后端确认 |
| 前后端实现冲突 | team-coordinator 仲裁，更新设计文档 |
| 一方进度阻塞 | team-coordinator 评估影响，调整计划 |
| 测试失败 | 各 Agent 自行调试，必要时协调 |

### 4.2 Agent 异常处理

| 场景 | 处理方式 |
|------|----------|
| Agent 执行失败 | team-coordinator 记录错误，重试或人工介入 |
| 部分完成（前端完成，后端失败） | 保留前端代码，记录后端待办，等待后续处理 |
| 长时间任务超时 | 设置超时阈值（如 30 分钟），超时后 team-coordinator 检查进度并决定是否继续 |
| API 同时变更冲突 | 先提交方优先，后提交方合并变更；team-coordinator 裁决不一致情况 |

### 4.3 恢复机制

- **状态检查点**：每个任务完成后写入状态文件，支持从中断点恢复
- **人工介入点**：当 team-coordinator 无法自动处理时，暂停并等待用户决策

---

## 5. 测试策略

### 5.1 单元测试

- 后端：JUnit 5 + Mockito（现有）
- 前端：Vitest + Vue Test Utils

### 5.2 集成测试

- 后端：@SpringBootTest
- 前端：组件测试 + API Mock

### 5.3 联调测试

- team-coordinator 协调完整流程验证
- 前后端实际对接测试

---

## 6. 实现注意事项

### 6.1 实现顺序（按依赖关系）

```
Phase 1: 基础设施
├── 1. Agent 定义文件编写
│   ├── agents/team-coordinator.md
│   ├── agents/frontend-developer.md
│   └── agents/backend-developer.md
├── 2. 设计文档模板更新
│   └── docs/templates/design-document-template.md
└── 3. 目录结构调整
    ├── 创建 frontend/skills/ 目录
    └── 创建 backend/skills/ 目录

Phase 2: 后端迁移（无依赖）
└── 迁移现有 springboot-* 技能到 backend/skills/

Phase 3: 前端技能开发（依赖 Phase 1）
├── frontend/skills/vue3-best-practices/
├── frontend/skills/vue3-project-structure/
├── frontend/skills/vue3-component-dev/
├── frontend/skills/vue3-api-integration/
├── frontend/skills/vue3-state-management/
└── frontend/skills/vue3-testing/

Phase 4: Team 开发模式（依赖 Phase 1, 2, 3）
├── skills/team-driven-development/SKILL.md
└── skills/writing-plans/SKILL.md 更新（增加执行模式选择逻辑）

Phase 5: 集成测试
├── 单端开发流程验证
└── Team 开发流程验证
```

### 6.2 关键实现点

1. **现有后端技能迁移**：将 `springboot-*` 技能迁移到 `backend/skills/` 目录
2. **技能路径适配**：更新 `using-xo1997-dev` 技能，支持前端/后端技能发现
3. **Agent 定义**：编写三个 Agent 的详细 prompt 定义
4. **设计文档模板更新**：增加前端设计章节
5. **team-driven-development 技能**：新增协作开发流程技能

---

## 附录

### A. 前端项目结构参考

```
src/
├── api/                    # API 请求
│   ├── user.js             # 用户相关 API
│   ├── video.js            # 视频相关 API
│   └── types/              # TypeScript 类型定义
├── assets/                 # 静态资源
│   ├── images/
│   └── styles/
├── components/             # 公共组件
│   ├── common/             # 通用组件
│   └── business/           # 业务组件
├── router/                 # 路由配置
│   └── index.js
├── stores/                 # 状态管理 (Pinia)
│   ├── user.js
│   └── app.js
├── utils/                  # 工具函数
│   ├── request.js          # Axios 封装
│   └── auth.js             # 认证相关
├── views/                  # 页面组件
│   ├── user/
│   └── video/
├── App.vue
└── main.js
```

### B. 修订历史

| 版本 | 日期 | 修改人 | 修改内容 |
|------|------|--------|----------|
| 1.0 | 2026-03-17 | AI | 初始版本 |