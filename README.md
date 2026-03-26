# xo1997-dev

xo1997-dev 是一套完整的软件开发工作流，专为 **Spring Boot + Vue3** 全栈项目设计，基于可组合的"技能"(Skills) 系统构建，确保 AI 编码代理遵循最佳实践。

## 核心特性

| 特性 | 描述 |
|------|------|
| **测试驱动开发** | 强制执行 RED-GREEN-REFACTOR 循环 |
| **系统化调试** | 四阶段根因分析流程 |
| **证据驱动验证** | 没有验证证据不声称完成 |
| **设计优先** | 没有批准设计不编写代码 |
| **双阶段审查** | 先规范符合性，后代码质量 |
| **前后端协同** | 多 Agent 并行开发支持 |

## 工作原理

```
用户需求 → using-xo1997-dev (技能入口) → brainstorming (需求探索)
                                                │
                            ┌───────────────────┴───────────────────┐
                            │                                       │
                            ▼                                       ▼
                    using-git-worktrees                   (optional 直接到 plans)
                    (创建隔离工作空间)
                            │
                            ▼
                    writing-plans (实现计划)
                            │
                            ▼
                    执行模式选择
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
subagent-driven-development          team-driven-development
(单域执行：仅前端或仅后端)            (前后端并行开发)
        │                                       │
        └───────────────────┬───────────────────┘
                            │
                            ▼
            TDD 实现 → 双阶段审查 → verification → 完成
```

### 自动触发机制

通过 **SessionStart Hook** 在会话启动时自动注入技能系统。只要有 1% 的可能性某个技能适用，AI 就必须调用该技能。

---

## 适用项目

### 后端

| 技术 | 版本 |
|------|------|
| Spring Boot | 2.7.18 |
| MyBatis-Plus | 3.5.7 |
| JUnit 5 + Mockito | - |
| H2 (MySQL 兼容模式) | - |

### 前端

| 技术 | 版本 |
|------|------|
| Vue | 3.x |
| Vite | 5.x |
| Element Plus | 2.x |
| Pinia | 2.x |
| Vitest | 1.x |

---

## 完整工作流程

### 1. brainstorming - 需求探索与设计

**触发：** 任何创意工作前（新功能、构建组件、修改行为）

**流程：**
```
探索项目上下文 → 提出澄清问题 → 提出 2-3 种方案 → 展示设计
    → 数据库设计 (Spring Boot) → 编写设计文档 → 设计评审循环 → 用户审查
```

**产出：** `docs/xo1997-dev/specs/YYYY-MM-DD-<topic>-design.md`

### 2. using-git-worktrees - 创建隔离工作空间

**触发：** 设计批准后

**作用：**
- 创建隔离分支
- 运行项目设置
- 验证测试基线

### 3. writing-plans - 编写实现计划

**触发：** 设计批准后

**特点：**
- 任务粒度：2-5 分钟每步
- 包含：精确文件路径、完整代码、TDD 步骤
- Spring Boot：强制审计字段验证

**产出：** `docs/specs/feature_{模块}_{功能}_{日期}/plan.md`

### 4. 执行模式选择

```
                 计划批准
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
   仅前端/后端    前端+后端    无子代理
        │           │           │
        ▼           ▼           ▼
subagent-driven  team-driven  executing-plans
```

#### subagent-driven-development (单域执行)

**适用：** 仅前端或仅后端的实现

**流程：**
```
Per Task:
  派发 implementer subagent
       ↓
  处理状态 (DONE/NEEDS_CONTEXT/BLOCKED)
       ↓
  规范符合性审查 (spec-reviewer)
       ↓
  代码质量审查 (code-quality-reviewer)
       ↓
  标记任务完成
```

#### team-driven-development (前后端并行)

**适用：** 需要同时开发前端和后端

**Agent 角色：**

| Agent | 职责 |
|-------|------|
| team-coordinator | 任务分配、进度监控、代码审查、阻塞处理 |
| frontend-developer | 前端页面、组件、API 调用 |
| backend-developer | Controller、Service、Mapper |

**通信机制：**
```
.claude/team-session/
├── design-doc.md        # 设计文档
├── plan.md              # 实现计划
├── frontend-tasks.md    # 前端任务状态
├── backend-tasks.md     # 后端任务状态
├── api-changes.md       # API 变更日志
└── blockers.md          # 阻塞问题
```

### 5. test-driven-development - 测试驱动开发

**触发：** 实现任何功能或修复 bug

**RED-GREEN-REFACTOR 循环：**
```
RED: 写失败测试 → 验证失败
GREEN: 最小实现 → 验证通过
REFACTOR: 重构 → 提交
```

### 6. 双阶段代码审查

**阶段 1：规范符合性审查**
- 实现是否符合设计？
- 有无遗漏/多余功能？

**阶段 2：代码质量审查**
- 分层架构检查
- 最佳实践验证
- 性能/安全审查

### 7. verification-before-completion - 完成前验证

**铁律：** 没有新鲜验证证据，不声称完成。

**验证命令：**
| 类型 | 后端 | 前端 |
|------|------|------|
| 测试 | `mvn clean test` | `npm run test` |
| 编译 | `mvn clean compile` | `npm run build` |

### 8. finishing-a-development-branch - 完成分支

**选项：**
1. 本地合并
2. 创建 PR
3. 保持现状
4. 放弃工作

---

## 技能库

### 流程控制技能

| 技能 | 用途 | 类型 |
|------|------|------|
| **brainstorming** | 需求探索与设计 | 刚性 |
| **writing-plans** | 编写实现计划 | - |
| **executing-plans** | 当前会话执行计划 | - |
| **subagent-driven-development** | 子代理驱动开发 | - |
| **team-driven-development** | 多 Agent 并行开发 | - |

### 开发实践技能

| 技能 | 用途 | 类型 |
|------|------|------|
| **test-driven-development** | 测试驱动开发 | 刚性 |
| **systematic-debugging** | 系统化调试 | 刚性 |
| **verification-before-completion** | 完成前验证 | 刚性 |

### 协作技能

| 技能 | 用途 |
|------|------|
| **requesting-code-review** | 请求代码审查 |
| **receiving-code-review** | 接收审查反馈 |
| **using-git-worktrees** | Git Worktree 管理 |
| **finishing-a-development-branch** | 完成开发分支 |
| **committing-changes** | 提交代码变更 (Conventional Commits) |
| **dispatching-parallel-agents** | 并行代理调度 |

### Spring Boot 专属技能

| 技能 | 用途 |
|------|------|
| **springboot-best-practices** | 分层架构、依赖注入、配置、验证、事务 |
| **mybatis-plus-patterns** | Entity 设计、Mapper 接口、条件构造器、分页 |
| **springboot-unified-response** | Result<T> 格式、分类异常、全局处理 |

### Vue3 专属技能

| 技能 | 用途 |
|------|------|
| **vue3-best-practices** | Composition API、响应式、生命周期 |
| **vue3-project-structure** | 目录组织规范 |
| **vue3-component-dev** | 组件设计模式 |
| **vue3-api-integration** | Axios 配置、API 函数生成 |
| **vue3-state-management** | Pinia Store 设计 |
| **vue3-testing** | Vitest 配置、组件测试 |

---

## 项目结构

### Spring Boot 后端

```
src/main/java/com/example/
├── common/                          # 公共组件
│   ├── exception/                   # GlobalExceptionHandler, BusinessException
│   └── result/                      # Result<T> 统一响应
├── schedule/                        # 定时任务
└── module/                          # 业务模块
    └── user/
        ├── controller/              # REST API 控制器
        ├── service/                 # 业务逻辑
        ├── mapper/                  # 数据访问
        ├── entity/                  # 数据库实体
        ├── dto/                     # 请求数据传输对象
        └── vo/                      # 响应视图对象
```

### Vue3 前端

```
src/
├── api/              # API 接口
├── assets/           # 静态资源
├── components/       # 通用组件
├── composables/      # 组合式函数
├── router/           # 路由配置
├── stores/           # Pinia 状态
├── styles/           # 全局样式
├── utils/            # 工具函数
└── views/            # 页面组件
```

---

## Spring Boot 审计字段

所有 Entity 类必须包含审计字段：

| 字段 | 类型 | 注解 |
|------|------|------|
| `id` | Long | `@TableId(type = IdType.AUTO)` |
| `create_by` | String | `@TableField(fill = FieldFill.INSERT)` |
| `create_time` | LocalDateTime | `@TableField(fill = FieldFill.INSERT)` |
| `update_by` | String | `@TableField(fill = FieldFill.INSERT_UPDATE)` |
| `update_time` | LocalDateTime | `@TableField(fill = FieldFill.INSERT_UPDATE)` |
| `is_del` | Integer | `@TableLogic` |

---

## 测试模式

### Spring Boot 测试

| 测试类型 | 注解 | 用途 |
|----------|------|------|
| Service 单元测试 | `@ExtendWith(MockitoExtension.class)` | Mock 依赖 |
| Controller 测试 | `@WebMvcTest` | 切片测试 |
| 集成测试 | `@SpringBootTest` | 全量测试 |

### Vue3 测试

| 测试类型 | 工具 | 用途 |
|----------|------|------|
| 组件测试 | Vitest + Vue Test Utils | 组件行为验证 |
| Store 测试 | Vitest + Pinia | 状态管理验证 |
| API Mock | MSW / Vitest mock | 接口模拟 |

---

## 分层架构审查

| 审查项 | Controller | Service | Mapper |
|--------|------------|---------|--------|
| 业务逻辑 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 数据库操作 | ❌ 禁止 | ✅ 通过 Mapper | ✅ 允许 |
| HTTP 相关 | ✅ 允许 | ❌ 禁止 | ❌ 禁止 |
| 参数校验 | ✅ 允许 | ✅ 允许 | ❌ 禁止 |
| 事务控制 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 实体对象 | DTO/VO | Entity | Entity |

---

## 验证安装

启动新会话，尝试触发技能：

```
"帮我开发一个用户管理功能"  → using-xo1997-dev → brainstorming → using-git-worktrees → writing-plans → ...
"修复这个 bug"             → systematic-debugging
"我完成了任务"             → verification-before-completion
```

---

## 命令

| 命令 | 用途 |
|------|------|
| `/brainstorm` | 启动头脑风暴 |
| `/write-plan` | 编写实现计划 |
| `/execute-plan` | 执行实现计划 |

---

## 核心理念

| 原则 | 描述 |
|------|------|
| **测试先行** | 没有失败测试，不写生产代码 |
| **系统化调试** | 没有找到根因，不尝试修复 |
| **证据驱动** | 没有验证证据，不声称完成 |
| **设计优先** | 没有批准设计，不编写代码 |
| **复杂度控制** | 简洁作为首要目标 |

---

## 文件结构

```
xo1997-dev/
├── .claude-plugin/
│   ├── plugin.json              # 插件配置
│   └── marketplace.json         # 市场信息
├── agents/
│   ├── code-reviewer.md         # 代码审查代理
│   ├── frontend-developer.md    # 前端开发代理
│   ├── backend-developer.md     # 后端开发代理
│   └── team-coordinator.md      # 团队协调代理
├── backend/skills/              # 后端专属技能
├── frontend/skills/             # 前端专属技能
├── commands/                    # 斜杠命令
├── docs/                        # 文档
├── hooks/                       # 钩子配置
├── skills/                      # 核心技能库
└── README.md
```

---

## 贡献

1. Fork 仓库
2. 创建特性分支
3. 遵循 `writing-skills` 技能创建和测试新技能
4. 提交 PR

详见 `skills/writing-skills/SKILL.md`。

---

## 许可证

MIT License