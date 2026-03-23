# xo1997-dev 工作流程详解

> 版本: 1.2.0
> 更新时间: 2026-03-23
> 适用项目: Spring Boot 2.7.18 + MyBatis-Plus 3.5.7 后端 / Vue 3 + Vite + Element Plus 前端

---

## 一、工作流概述

### 1.1 核心理念

xo1997-dev 是一套完整的软件工程实践工作流，核心理念：

| 原则 | 描述 |
|------|------|
| **测试先行** | 没有失败测试，不写生产代码 |
| **系统化调试** | 没有找到根因，不尝试修复 |
| **证据驱动** | 没有验证证据，不声称完成 |
| **设计优先** | 没有批准设计，不编写代码 |
| **双阶段审查** | 先规范符合性，后代码质量 |

### 1.2 自动触发机制

通过 **SessionStart Hook** 在会话启动时自动注入技能系统说明：

```
会话启动 → 注入 using-xo1997-dev 技能 → AI 自动检查技能适用性
```

**触发规则：** 只要有 1% 的可能性某个技能适用，AI 就**必须**调用该技能。

### 1.3 技能优先级

当多个技能可能适用时，按以下顺序处理：

```
1. 流程技能优先（brainstorming, debugging）→ 决定如何处理任务
2. 实现技能其次（frontend-design, mcp-builder）→ 指导具体实现
```

---

## 二、完整开发工作流

### 2.1 标准开发流程图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        xo1997-dev 完整开发工作流                              │
└─────────────────────────────────────────────────────────────────────────────┘

     ┌──────────────┐
     │  用户需求输入  │
     └──────┬───────┘
            │
            ▼
┌───────────────────────┐
│  using-xo1997-dev     │ ← SessionStart Hook 自动注入
│  (技能系统入口)        │
│  • 检查技能适用性      │
│  • 确定调用顺序        │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  brainstorming        │ ← 任何创意工作前必须调用
│  (需求探索与设计)       │
│                        │
│  Checklist:           │
│  1. 探索项目上下文     │
│     • 检查 docs/modules/ 分支一致性 ✓ │
│  2. 提供可视化伴侣     │ ← 如涉及视觉问题
│  3. 提出澄清问题       │ ← 一次一个问题
│  4. 编写需求文档       │ ← requirements.md
│  5. 提出 2-3 种方案    │
│  6. 展示设计          │
│  7. 数据库设计 ✓      │ ← Spring Boot 强制
│  8. 编写设计文档       │
│  9. 设计评审循环       │ ← spec-document-reviewer
│  10. 用户审查          │
│  11. 过渡到实现       │
└───────────┬───────────┘
            │ 设计批准
            ▼
┌───────────────────────┐
│  using-git-worktrees  │ ← 创建隔离工作空间
│  (Git Worktree 管理)   │
│  • 创建隔离分支        │
│  • 运行项目设置        │
│  • 验证测试基线        │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  writing-plans        │
│  (编写实现计划)        │
│                        │
│  • 分解任务 (2-5分钟)  │
│  • 精确文件路径        │
│  • 完整代码示例        │
│  • TDD 步骤           │
│  • 审计字段验证 ✓     │ ← Entity 创建时强制
│  • Schema 设计确认 ✓  │
│                        │
│  计划审查循环:         │
│  → plan-document-reviewer
│  → 修复问题
│  → 重新审查
│  → 批准               │
└───────────┬───────────┘
            │ 计划批准
            ▼
┌───────────────────────┐
│  执行模式选择          │
│                        │
│  判断: 前端 AND 后端?  │
└───────────┬───────────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
┌─────────┐   ┌───────────────────┐
│ 仅前端   │   │ 前端 + 后端        │
│ 或仅后端 │   │ (并行开发)         │
└────┬────┘   └─────────┬─────────┘
     │                  │
     ▼                  ▼
┌──────────────┐  ┌──────────────────┐
│ subagent-    │  │ team-driven-     │
│ driven-      │  │ development      │
│ development  │  │                  │
│              │  │ ┌──────────────┐ │
│ • 每任务     │  │ │ team-        │ │
│   派发子代理 │  │ │ coordinator  │ │
│ • 双阶段审查 │  │ │ (协调者)     │ │
│ • 自动修复   │  │ └──────┬───────┘ │
│              │  │        │         │
│              │  │   ┌────┴────┐    │
│              │  │   │         │    │
│              │  │   ▼         ▼    │
│              │  │ ┌─────┐ ┌─────┐  │
│              │  │ │FE   │ │BE   │  │
│              │  │ │dev  │ │dev  │  │
│              │  │ └──┬──┘ └──┬──┘  │
│              │  │    │       │     │
│              │  │    └───┬───┘     │
│              │  │        │         │
│              │  │  API 变更通知    │
│              │  │  Blocker 处理   │
│              │  │  集成验证       │
└──────┬───────┘  └──────────┬───────┘
       │                     │
       └──────────┬──────────┘
                  │
                  ▼
┌───────────────────────┐
│  test-driven-         │ ← 实现过程中自动应用
│  development          │
│  (测试驱动开发)        │
│                        │
│  RED-GREEN-REFACTOR:  │
│  1. 写失败测试         │
│  2. 运行验证失败       │
│  3. 最小实现          │
│  4. 运行验证通过       │
│  5. 重构             │
│  6. 提交             │
└───────────┬───────────┘
            │ 每个任务完成后
            ▼
┌───────────────────────┐
│  双阶段代码审查        │
│                        │
│  阶段1: 规范符合性      │
│  → spec-reviewer      │
│  → 实现是否符合设计?   │
│  → 有无遗漏/多余?      │
│                        │
│  阶段2: 代码质量        │
│  → code-quality-      │
│    reviewer           │
│  → 分层架构审查 ✓     │
│  → 最佳实践检查       │
│  → 性能/安全审查      │
└───────────┬───────────┘
            │ 所有任务完成
            ▼
┌───────────────────────┐
│  verification-before- │
│  completion           │
│  (完成前验证)          │
│                        │
│  铁律: 证据先于声明    │
│                        │
│  后端验证:             │
│  • mvn clean test     │
│  • mvn clean compile  │
│                        │
│  前端验证:             │
│  • npm run test       │
│  • npm run build      │
│                        │
│  必须: 运行命令        │
│  必须: 读取输出        │
│  必须: 确认结果        │
│  更新模块文档 ✓       │ ← docs/modules/{模块}.md
└───────────┬───────────┘
            │ 验证通过
            ▼
┌───────────────────────┐
│  finishing-a-         │
│  development-branch   │
│  (完成开发分支)        │
│                        │
│  选项:                 │
│  1. 本地合并          │
│  2. 创建 PR           │
│  3. 保持现状          │
│  4. 放弃工作          │
│                        │
│  清理 Worktree        │
└───────────────────────┘
```

### 2.2 调试工作流

```
┌───────────────────────┐
│  发现 Bug 或测试失败   │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  systematic-debugging │ ← 任何 bug 修复前必须调用
│  (系统化调试)          │
│                        │
│  Phase 1: 根因调查     │
│  ┌─────────────────┐  │
│  │ • 仔细阅读错误   │  │
│  │ • 稳定复现      │  │
│  │ • 检查最近变更   │  │
│  │ • 收集证据      │  │
│  └─────────────────┘  │
│                        │
│  Phase 2: 模式分析     │
│  ┌─────────────────┐  │
│  │ • 找到工作示例   │  │
│  │ • 对比差异      │  │
│  └─────────────────┘  │
│                        │
│  Phase 3: 假设测试     │
│  ┌─────────────────┐  │
│  │ • 形成单一假设   │  │
│  │ • 最小化测试    │  │
│  └─────────────────┘  │
│                        │
│  Phase 4: 实现修复     │
│  ┌─────────────────┐  │
│  │ • 创建失败测试   │  │
│  │ • 实现单一修复   │  │
│  │ • 验证修复      │  │
│  └─────────────────┘  │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  test-driven-         │
│  development          │
│  (编写回归测试)        │
│                        │
│  RED: 写失败测试       │
│  GREEN: 修复使测试通过 │
│  REFACTOR: 清理代码    │
└───────────────────────┘
```

### 2.3 代码审查反馈处理流程

```
┌───────────────────────┐
│  收到代码审查反馈      │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│  receiving-code-      │
│  review               │
│  (接收代码审查)        │
│                        │
│  核心原则:             │
│  • 技术严谨性         │
│  • 验证优先           │
│  • 不盲目同意         │
│                        │
│  处理步骤:             │
│  1. 理解反馈意图      │
│  2. 验证技术正确性    │
│  3. 决定接受/讨论/拒绝│
│  4. 实施修改          │
│  5. 验证修改效果      │
└───────────────────────┘
```

---

## 三、执行模式详解

### 3.1 执行模式选择决策

```
计划批准后，选择执行模式:

                    ┌─────────────────┐
                    │ 计划已批准      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ 检查任务类型    │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌─────────┐   ┌───────────┐   ┌─────────┐
        │ 仅后端  │   │ 前端+后端 │   │ 无子代理 │
        │ 或仅前端│   │ 并行开发  │   │ 支持    │
        └────┬────┘   └─────┬─────┘   └────┬────┘
             │              │              │
             ▼              ▼              ▼
    ┌─────────────┐ ┌───────────────┐ ┌───────────┐
    │ subagent-   │ │ team-driven-  │ │ executing │
    │ driven-     │ │ development   │ │ -plans    │
    │ development │ │               │ │           │
    └─────────────┘ └───────────────┘ └───────────┘
```

### 3.2 subagent-driven-development (单域执行)

**适用场景：** 仅前端或仅后端的实现任务

**流程：**
```
┌─────────────────────────────────────────────────────┐
│              subagent-driven-development             │
├─────────────────────────────────────────────────────┤
│                                                      │
│  读取计划 → 提取所有任务 → 创建 TodoWrite            │
│                                                      │
│  ┌─────────────────────────────────────────────┐   │
│  │ Per Task:                                    │   │
│  │                                              │   │
│  │  1. 派发 implementer subagent               │   │
│  │     └─ 提供完整任务文本 + 上下文             │   │
│  │                                              │   │
│  │  2. 处理 subagent 状态:                      │   │
│  │     ├─ DONE → 继续审查                       │   │
│  │     ├─ DONE_WITH_CONCERNS → 评估后继续       │   │
│  │     ├─ NEEDS_CONTEXT → 补充上下文重新派发   │   │
│  │     └─ BLOCKED → 评估阻塞，升级或调整        │   │
│  │                                              │   │
│  │  3. 规范符合性审查 (spec-reviewer)          │   │
│  │     ├─ 通过 → 继续                          │   │
│  │     └─ 问题 → 修复 → 重新审查               │   │
│  │                                              │   │
│  │  4. 代码质量审查 (code-quality-reviewer)    │   │
│  │     ├─ 通过 → 标记任务完成                  │   │
│  │     └─ 问题 → 修复 → 重新审查               │   │
│  │                                              │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
│  所有任务完成 → 最终代码审查 → finishing-a-branch   │
│                                                      │
└─────────────────────────────────────────────────────┘
```

**模型选择策略：**

| 任务类型 | 推荐模型 | 说明 |
|----------|----------|------|
| 机械实现 (1-2文件，规格完整) | 快速廉价模型 | 大多数实现任务 |
| 集成任务 (多文件协调) | 标准模型 | 需要理解关联 |
| 架构/设计/审查 | 最强模型 | 需要判断力 |

### 3.3 team-driven-development (前后端并行)

**适用场景：** 需要同时开发前端和后端的功能

**Agent 角色：**

| Agent | 职责 | 输入 | 输出 |
|-------|------|------|------|
| **team-coordinator** | 任务分配、进度监控、代码审查、阻塞处理 | 设计文档、实现计划 | 协调决策、审查结果 |
| **frontend-developer** | 前端实现 | 前端任务、API定义 | 页面、组件、API调用 |
| **backend-developer** | 后端实现 | 后端任务 | Controller、Service、Mapper |

**通信机制：**

```
.claude/team-session/
├── design-doc.md           # 设计文档 (只读，共享)
├── plan.md                 # 实现计划 (只读，共享)
├── frontend-tasks.md       # 前端任务状态
├── backend-tasks.md        # 后端任务状态
├── api-changes.md          # API 变更日志
├── blockers.md             # 阻塞问题
└── review-feedback/        # 审查反馈
    ├── frontend.md
    └── backend.md
```

**流程：**

```
Phase 1: 计划分配
team-coordinator 分析计划，识别依赖，分发任务

Phase 2: 并行开发
┌─────────────────────┬─────────────────────┐
│  backend-developer  │  frontend-developer │
│  • 实现 Controller  │  • 实现页面组件      │
│  • 实现 Service     │  • 实现 API 调用     │
│  • 实现 Mapper      │  • 集成状态管理      │
│  • TDD 工作流       │  • TDD 工作流        │
└─────────────────────┴─────────────────────┘

Phase 3: 代码审查
team-coordinator 审查每个完成的端点

Phase 4: API 变更处理
任一方需要变更 API 时:
1. 更新设计文档
2. team-coordinator 通知另一方
3. 另一方调整实现

Phase 5: 集成验证
team-coordinator 协调集成测试

Phase 6: 完成
调用 finishing-a-development-branch
```

**错误处理：**

| 场景 | 处理方式 |
|------|----------|
| API 定义不清晰 | team-coordinator 协调澄清 |
| 前后端冲突 | team-coordinator 仲裁 |
| 一方阻塞 | team-coordinator 评估影响，调整计划 |
| Agent 超时 (>30分钟) | team-coordinator 检查进度，提供帮助或升级 |

### 3.4 executing-plans (无子代理支持)

**适用场景：** 平台不支持子代理时的执行方式

**特点：**
- 在当前会话中执行
- 按批次执行，每批次后设置人工检查点
- 适用于小型、独立性强的任务

---

## 四、技能 (Skills) 详解

### 4.1 流程控制技能

#### brainstorming - 需求探索与设计

| 属性 | 值 |
|------|-----|
| **触发条件** | 任何创意工作前（创建功能、构建组件、添加功能、修改行为） |
| **调用时机** | 在 EnterPlanMode 之前、编写代码之前 |
| **类型** | 刚性（HARD-GATE：必须先有批准的设计） |

**Checklist:**
1. 探索项目上下文（检查 `docs/modules/` 分支一致性）
2. 提供可视化伴侣（如涉及视觉问题）
3. 提出澄清问题（一次一个）
4. **编写需求文档** → `docs/specs/feature_{模块}_{功能}_{日期}/requirements.md`
5. 提出 2-3 种方案
6. 展示设计（按复杂度调整详细程度）
7. **数据库设计（Spring Boot 项目必填）**
8. 编写设计文档 → `docs/specs/feature_{模块}_{功能}_{日期}/design.md`
9. 设计评审循环（spec-document-reviewer）
10. 用户审查设计文档
11. 过渡到实现（调用 writing-plans）

**文档路径规范：**
```
docs/specs/feature_{模块}_{功能}_{日期}/
├── requirements.md    # 需求文档
├── design.md          # 设计文档
├── plan.md            # 实现计划
├── test-cases.md      # 测试用例
└── test-report.md     # 测试报告
```

**终止状态：** 只能调用 `writing-plans`，不能直接调用其他实现技能。

---

#### writing-plans - 编写实现计划

| 属性 | 值 |
|------|-----|
| **触发条件** | 有已批准的设计文档，需要编写实现计划 |
| **调用时机** | brainstorming 完成后 |
| **前置技能** | brainstorming, using-git-worktrees |

**任务结构:**
```markdown
### Task N: [组件名称]

**Files:**
- Create: `src/main/java/.../UserController.java`
- Create: `src/main/java/.../UserService.java`
...

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Write minimal implementation**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
```

**Spring Boot 项目结构:**
```
src/main/java/com/example/
├── common/                    # 公共组件
│   ├── exception/             # 统一异常处理
│   └── result/                # 统一响应格式
├── module/                    # 业务模块
│   └── user/
│       ├── controller/
│       ├── service/
│       ├── mapper/
│       ├── entity/
│       ├── dto/
│       └── vo/
└── Application.java
```

**文件创建顺序（Top-Down）:**
1. Controller → 定义 API 端点
2. DTO/VO → 定义请求/响应对象
3. Service Interface → 定义业务方法
4. Service Implementation → 实现业务逻辑
5. Mapper → 定义数据访问
6. Entity → 定义数据库映射
7. Test → 编写测试

**产出：** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

---

### 4.2 开发实践技能

#### test-driven-development - 测试驱动开发

| 属性 | 值 |
|------|-----|
| **触发条件** | 实现任何功能或修复 bug |
| **调用时机** | 编写实现代码之前 |
| **类型** | 刚性（必须严格遵循） |

**RED-GREEN-REFACTOR 循环:**
```
RED: 写失败测试 → 验证测试失败 →
GREEN: 最小实现 → 验证测试通过 →
REFACTOR: 重构 → 保持测试通过 → Commit
```

**Spring Boot 测试适配:**
| 测试类型 | 注解 | 用途 |
|----------|------|------|
| Service 单元测试 | `@ExtendWith(MockitoExtension.class)` | Mock 依赖 |
| Controller 测试 | `@WebMvcTest` | 切片测试 |
| 集成测试 | `@SpringBootTest` | 全量测试 |

**测试命令:**
```bash
# 运行所有测试
mvn clean test

# 运行单个测试类
mvn test -Dtest=UserServiceTest

# 运行单个测试方法
mvn test -Dtest=UserServiceTest#shouldCreateUser
```

---

#### systematic-debugging - 系统化调试

| 属性 | 值 |
|------|-----|
| **触发条件** | 遇到任何 bug、测试失败或意外行为 |
| **调用时机** | 提出修复方案之前 |
| **类型** | 刚性（必须严格遵循） |

**核心原则：** 没有找到根因，不尝试修复。

**四阶段流程:**

| 阶段 | 活动 | 成功标准 |
|------|------|----------|
| **Phase 1** | 根因调查 | 理解 WHAT 和 WHY |
| **Phase 2** | 模式分析 | 识别差异 |
| **Phase 3** | 假设测试 | 确认或新假设 |
| **Phase 4** | 实现修复 | Bug 解决，测试通过 |

---

#### verification-before-completion - 完成前验证

| 属性 | 值 |
|------|-----|
| **触发条件** | 声称工作完成、修复问题、测试通过之前 |
| **调用时机** | 提交代码、创建 PR、完成任务之前 |
| **类型** | 刚性（必须严格遵循） |

**铁律:**
```
没有新鲜验证证据，不声称完成。
如果这个消息中没有运行验证命令，就不能声称它通过。
```

**验证流程:**
```
BEFORE 声称任何状态:

1. IDENTIFY: 什么命令证明这个声明？
2. RUN: 执行完整命令（新鲜的、完整的）
3. READ: 完整输出，检查退出码，统计失败
4. VERIFY: 输出是否确认声明？
   - NO: 说明实际状态，提供证据
   - YES: 声明并提供证据
5. ONLY THEN: 做出声明
```

**验证命令:**

| 类型 | 后端 | 前端 |
|------|------|------|
| 运行测试 | `mvn clean test` | `npm run test` |
| 编译检查 | `mvn clean compile` | `npm run build` |
| 单个测试 | `mvn test -Dtest=ClassName` | `npm run test -- --grep "test name"` |

**模块文档更新:**
```
验证通过后，更新 docs/modules/{模块}.md：
1. 读取设计文档 docs/specs/feature_{模块}_{功能}_{日期}/design.md
2. 更新对应模块文档：
   - 新增功能 → 核心功能
   - 新增文件 → 代码结构
   - 新增 API → API 接口
   - 新增实体 → 数据模型
3. 与功能代码一起提交
```

---

### 4.3 协作技能

#### requesting-code-review - 请求代码审查

| 属性 | 值 |
|------|-----|
| **触发条件** | 完成任务、实现主要功能、合并前 |
| **调用时机** | 任务完成后、合并前 |

**作用：**
1. 派发 code-reviewer 子代理
2. 提供精确的审查上下文（不含会话历史）
3. 分类处理反馈

---

#### receiving-code-review - 接收代码审查

| 属性 | 值 |
|------|-----|
| **触发条件** | 收到代码审查反馈 |
| **调用时机** | 实施建议之前 |

**核心原则:**
- 技术严谨性，不是表演性同意
- 验证优先，不盲目实施
- 有疑问时提出讨论

---

#### for-test - 测试人员工作流

| 属性 | 值 |
|------|-----|
| **触发条件** | 设计文档批准后需要细化测试用例、开发提测需要执行验收、功能上线需要出具测试报告 |
| **调用时机** | 设计阶段、实现阶段、完成阶段 |

**测试人员职责：**

| 阶段 | 职责 | 输出 |
|------|------|------|
| 设计阶段 | 参与需求评审，确认验收标准 | 验收标准确认 |
| 实现阶段 | 补充完整测试用例 | test-cases.md |
| 实现阶段 | 执行测试，记录缺陷 | 缺陷报告 |
| 完成阶段 | 出具测试报告 | test-report.md |

**流程：**
```
Phase 1: 测试用例设计
输入: design.md, plan.md
输出: test-cases.md

Phase 2: 测试用例评审
参与方: 测试负责人、开发负责人、产品

Phase 3: 测试执行
顺序: 冒烟 → 功能 → 边界 → 异常 → 回归

Phase 4: 测试报告
输出: test-report.md（含测试签名）
```

---

#### finishing-a-development-branch - 完成开发分支

| 属性 | 值 |
|------|-----|
| **触发条件** | 实现完成、所有测试通过 |
| **调用时机** | 所有任务完成后 |

**选项:**
| 选项 | 操作 |
|------|------|
| 1. 本地合并 | 切换到基础分支 → 合并 → 删除特性分支 |
| 2. 创建 PR | 推送 → 使用 gh 创建 PR |
| 3. 保持现状 | 保留分支和 Worktree |
| 4. 放弃工作 | 确认后删除分支和 Worktree |

---

#### using-git-worktrees - Git Worktree 管理

| 属性 | 值 |
|------|-----|
| **触发条件** | 开始需要隔离的功能工作、执行实现计划前 |
| **调用时机** | 设计批准后、实现开始前 |

**作用：**
1. 创建隔离的工作空间
2. 自动运行项目设置
3. 验证干净的测试基线

---

#### dispatching-parallel-agents - 并行代理调度

| 属性 | 值 |
|------|-----|
| **触发条件** | 有 2+ 个独立任务，无共享状态或顺序依赖 |
| **调用时机** | 需要并行处理多个独立问题时 |

**适用场景:**
- 多个测试文件失败，根因不同
- 多个子系统独立损坏

**不适用场景:**
- 失败相关（修复一个可能修复其他）
- 需要理解完整系统状态

---

#### committing-changes - 提交代码变更

| 属性 | 值 |
|------|-----|
| **触发条件** | 创建 git commit 时 |
| **调用时机** | TDD GREEN 阶段完成后、每个任务完成后 |

**格式：Conventional Commits**
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Type 类型：**
| Type | 用途 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档变更 |
| `style` | 代码格式（不影响逻辑） |
| `refactor` | 重构（不是新功能也不是修复） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `build` | 构建系统 |
| `ci` | CI/CD 配置 |
| `chore` | 其他杂项 |
| `revert` | 回滚提交 |

**核心规则：**
- 关联单号由用户提供，放在最前面
- 描述使用中文
- 不加句号结尾
- 控制在 50 字以内
- 每次提交应是一个逻辑变更

**示例：**
```
关联单号：REQ-123 feat(user): 添加密码重置功能

关联单号：BUG-456 fix(auth): 修复 token 刷新竞态条件

关联单号：TASK-789 refactor(video): 提取缩略图生成逻辑到独立服务
```

---

### 4.4 Spring Boot 专属技能

#### springboot-best-practices

**覆盖内容:**
- 分层架构规范
- 核心注解使用
- 依赖注入规范
- 配置管理
- 参数校验
- 异常处理
- 事务管理

#### mybatis-plus-patterns

**覆盖内容:**
- Entity 设计规范（含审计字段）
- Mapper 接口规范
- 条件构造器使用
- 分页查询
- 逻辑删除
- 自定义 SQL 方法

#### springboot-unified-response

**覆盖内容:**
- Result<T> 统一响应格式
- 分类业务异常（400/403/404）
- 全局异常处理
- 错误码规范

---

### 4.5 Vue3 专属技能

#### vue3-best-practices

**覆盖内容:**
- Composition API 使用
- 响应式系统
- 生命周期钩子
- 组件设计模式

#### vue3-project-structure

**目录结构:**
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

#### vue3-component-dev

**组件设计原则:**
- 单一职责
- Props 向下，Events 向上
- 组合优于继承

#### vue3-api-integration

**Axios 配置:**
- 请求拦截器
- 响应拦截器
- 错误处理
- API 函数生成

#### vue3-state-management

**Pinia Store 设计:**
- State 定义
- Getters 计算
- Actions 操作
- 持久化配置

#### vue3-testing

**Vitest 配置:**
- 组件测试
- Store 测试
- API Mock

---

## 五、Spring Boot 项目特殊配置

### 5.1 审计字段强制检查

**位置：** `brainstorming` 和 `writing-plans` 技能

**触发时机：**
- brainstorming：数据库表结构设计阶段
- writing-plans：Entity 类创建阶段

**必需字段：**
| 字段 | 类型 | 注解 |
|------|------|------|
| `id` | Long | `@TableId(type = IdType.AUTO)` |
| `create_by` | String | `@TableField(fill = FieldFill.INSERT)` |
| `create_time` | LocalDateTime | `@TableField(fill = FieldFill.INSERT)` |
| `update_by` | String | `@TableField(fill = FieldFill.INSERT_UPDATE)` |
| `update_time` | LocalDateTime | `@TableField(fill = FieldFill.INSERT_UPDATE)` |
| `is_del` | Integer | `@TableLogic` |

### 5.2 分层架构审查

| 审查项 | Controller | Service | Mapper |
|--------|------------|---------|--------|
| 业务逻辑 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 数据库操作 | ❌ 禁止 | ✅ 通过 Mapper | ✅ 允许 |
| HTTP 相关代码 | ✅ 允许 | ❌ 禁止 | ❌ 禁止 |
| 参数校验 | ✅ 允许 | ✅ 允许 | ❌ 禁止 |
| 事务控制 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 实体对象使用 | DTO/VO | Entity | Entity |

### 5.3 测试命令速查

| 场景 | 命令 |
|------|------|
| 运行所有测试 | `mvn clean test` |
| 运行单个测试类 | `mvn test -Dtest=ClassName` |
| 运行单个测试方法 | `mvn test -Dtest=ClassName#methodName` |
| 编译验证 | `mvn clean compile` |
| 打包验证 | `mvn clean package -DskipTests` |

---

## 六、技能调用决策树

```
用户输入
    │
    ├─ 是创意工作？（新功能、构建组件、修改行为）
    │       │
    │       └─ YES → brainstorming → writing-plans → ...
    │
    ├─ 是 bug 或测试失败？
    │       │
    │       └─ YES → systematic-debugging
    │
    ├─ 是完成声明？
    │       │
    │       └─ YES → verification-before-completion
    │
    ├─ 是代码审查请求？
    │       │
    │       └─ YES → requesting-code-review
    │
    ├─ 收到代码审查反馈？
    │       │
    │       └─ YES → receiving-code-review
    │
    ├─ 是执行计划请求？
    │       │
    │       ├─ 前端+后端？ → team-driven-development
    │       │
    │       ├─ 单域+有子代理？ → subagent-driven-development
    │       │
    │       └─ 无子代理？ → executing-plans
    │
    ├─ 是数据库操作？
    │       │
    │       └─ mybatis-plus-patterns
    │
    ├─ 是 REST API 开发？
    │       │
    │       ├─ springboot-best-practices
    │       │
    │       └─ springboot-unified-response
    │
    ├─ 是 Vue3 开发？
    │       │
    │       ├─ vue3-best-practices
    │       ├─ vue3-component-dev
    │       ├─ vue3-api-integration
    │       └─ vue3-state-management
    │
    └─ 多个独立任务？
            │
            └─ dispatching-parallel-agents
```

---

## 七、最佳实践

### 7.1 开发新功能

```
1. /brainstorm          → 探索需求，设计数据库表结构
2. 批准设计             → 自动创建 Worktree
3. /write-plan          → 编写详细实现计划
4. 批准计划             →
5. 自动选择执行模式     →
   - 单域 → subagent-driven-development
   - 前后端 → team-driven-development
6. 每任务双阶段审查     → 规范 + 质量
7. 完成验证             → verification-before-completion
8. 分支处理             → finishing-a-development-branch
```

### 7.2 修复 Bug

```
1. 发现问题             →
2. systematic-debugging → 四阶段调试流程
3. 找到根因             →
4. test-driven-development → 编写回归测试
5. 实现修复             →
6. verification-before-completion → 验证修复
```

### 7.3 处理审查反馈

```
1. 收到反馈             →
2. receiving-code-review → 技术严谨性分析
3. 验证反馈正确性       →
4. 决定接受/讨论/拒绝   →
5. 实施修改             →
6. 验证修改效果         →
```

---

## 八、文件结构

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
├── backend/skills/
│   ├── springboot-best-practices/
│   ├── mybatis-plus-patterns/
│   └── springboot-unified-response/
├── frontend/skills/
│   ├── vue3-best-practices/
│   ├── vue3-project-structure/
│   ├── vue3-component-dev/
│   ├── vue3-api-integration/
│   ├── vue3-state-management/
│   └── vue3-testing/
├── commands/
│   ├── brainstorm.md            # /brainstorm 命令
│   ├── execute-plan.md          # /execute-plan 命令
│   └── write-plan.md            # /write-plan 命令
├── docs/
│   ├── workflow-guide.md        # 本文档
│   ├── tdd-process.md           # TDD 详细流程
│   ├── brainstorming-design-process.md
│   ├── writing-plans-process.md
│   └── templates/
│       ├── design-document-template.md   # 设计文档模板
│       ├── requirements-template.md      # 需求文档模板
│       ├── test-case-template.md         # 测试用例模板
│       └── module-template.md            # 模块文档模板
├── hooks/
│   ├── hooks.json               # 钩子配置
│   ├── session-start            # 会话启动钩子
│   └── run-hook.cmd             # 钩子运行器
├── skills/
│   ├── using-xo1997-dev/        # 技能系统入口
│   ├── brainstorming/           # 需求探索与设计
│   ├── writing-plans/           # 编写实现计划
│   ├── executing-plans/         # 执行实现计划
│   ├── subagent-driven-development/
│   ├── team-driven-development/
│   ├── test-driven-development/
│   ├── systematic-debugging/
│   ├── verification-before-completion/
│   ├── requesting-code-review/
│   ├── receiving-code-review/
│   ├── finishing-a-development-branch/
│   ├── using-git-worktrees/
│   ├── committing-changes/        # 提交代码变更
│   ├── for-test/                  # 测试人员工作流
│   └── dispatching-parallel-agents/
├── GEMINI.md                    # Gemini CLI 兼容配置
├── README.md                    # 插件说明
└── xo1997-dev-customization.md  # 定制化文档
```

---

## 九、总结

xo1997-dev 提供了一套完整的软件工程实践工作流：

| 核心价值 | 实现方式 |
|----------|----------|
| **测试先行** | test-driven-development 的 RED-GREEN-REFACTOR 循环 |
| **系统化调试** | systematic-debugging 的四阶段流程 |
| **证据驱动** | verification-before-completion 的铁律 |
| **代码质量** | 双阶段审查（规范 + 质量）|
| **提交规范** | committing-changes 的 Conventional Commits 格式 |
| **隔离开发** | using-git-worktrees 的隔离工作空间 |
| **前后端协同** | team-driven-development 的多代理协调 |
| **测试左移** | for-test 技能支持测试人员全程参与 |
| **文档规范** | 需求文档、设计文档、测试用例、模块文档模板 |
| **Spring Boot 适配** | 审计字段检查、Maven 命令、分层架构审查 |
| **Vue3 适配** | Composition API、Pinia 状态管理、Vitest 测试 |

通过 SessionStart Hook 自动注入技能系统，确保 AI 在任何任务开始前都能正确识别和调用相关技能。