# xo1997-dev 工作流程详解

> 版本: 1.0.0
> 更新时间: 2026-03-15
> 适用项目: Spring Boot 2.7.18 + MyBatis-Plus 3.5.7 后端项目

---

## 一、工作流触发条件

### 1.1 自动触发

xo1997-dev 通过 **SessionStart Hook** 在会话启动时自动注入技能系统说明，使 AI 在任何任务开始前自动检查是否有相关技能适用。

```
会话启动 → 注入 using-xo1997-dev 技能 → AI 自动检查技能适用性
```

**触发条件：** 只要有 1% 的可能性某个技能适用，AI 就**必须**调用该技能。

### 1.2 主要触发场景

| 场景 | 触发的技能 | 说明 |
|------|-----------|------|
| "帮我开发一个用户管理功能" | brainstorming → writing-plans → subagent-driven-development | 完整新功能开发 |
| "修复这个 bug" | systematic-debugging | 问题排查和修复 |
| "我有个想法..." | brainstorming | 需求探索和设计 |
| "执行这个实现计划" | executing-plans 或 subagent-driven-development | 计划执行 |
| "审查一下代码" | requesting-code-review | 代码审查 |
| "我完成了任务" | verification-before-completion | 验证完成状态 |

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
└───────────┬───────────┘
            │ 检查是否有技能适用
            ▼
┌───────────────────────┐
│  brainstorming        │ ← 任何创意工作前必须调用
│  (需求探索与设计)       │
│  • 澄清问题            │
│  • 探索方案            │
│  • 数据库设计 ✓        │ ← Spring Boot 项目强制检查审计字段
│  • 设计文档            │
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
│  • 分解任务            │
│  • 精确文件路径        │
│  • 完整代码示例        │
│  • 审计字段验证 ✓      │ ← Entity 创建时强制验证
└───────────┬───────────┘
            │ 计划批准
            ▼
     ┌──────┴──────┐
     │  选择执行方式 │
     └──────┬──────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
┌─────────┐   ┌───────────────────┐
│ 当前会话 │   │ subagent-driven-   │
│ 执行     │   │ development        │ ← 推荐（有子代理支持）
│         │   │ (子代理驱动开发)    │
│ executing-│   │ • 每任务派发子代理  │
│ plans    │   │ • 双阶段审查       │
└────┬────┘   └─────────┬─────────┘
     │                  │
     └────────┬─────────┘
              │
              ▼
┌───────────────────────┐
│  test-driven-         │ ← 实现过程中自动应用
│  development          │
│  (测试驱动开发)        │
│  • RED: 写失败测试     │
│  • GREEN: 最小实现     │
│  • REFACTOR: 重构      │
└───────────┬───────────┘
            │ 每个任务完成后
            ▼
┌───────────────────────┐
│  requesting-code-     │
│  review               │
│  (代码审查请求)        │
│  • 派发 code-reviewer │
│  • 分层架构审查 ✓      │ ← Spring Boot 项目专属
│  • MyBatis-Plus 审查 ✓ │
└───────────┬───────────┘
            │ 所有任务完成
            ▼
┌───────────────────────┐
│  verification-before- │
│  completion           │
│  (完成前验证)          │
│  • mvn clean test ✓   │ ← Spring Boot 项目使用 Maven
│  • mvn clean compile ✓│
└───────────┬───────────┘
            │ 验证通过
            ▼
┌───────────────────────┐
│  finishing-a-         │
│  development-branch   │
│  (完成开发分支)        │
│  • 验证测试通过        │
│  • 提供合并选项        │
│  • 清理 Worktree      │
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
│  • 仔细阅读错误信息    │
│  • 稳定复现           │
│  • 检查最近变更        │
│  • 收集证据           │
│                        │
│  Phase 2: 模式分析     │
│  • 找到工作示例        │
│  • 对比差异           │
│                        │
│  Phase 3: 假设测试     │
│  • 形成单一假设        │
│  • 最小化测试          │
│                        │
│  Phase 4: 实现修复     │
│  • 创建失败测试        │
│  • 实现单一修复        │
│  • 验证修复           │
└───────────────────────┘
            │
            ▼
┌───────────────────────┐
│  test-driven-         │
│  development          │
│  (编写回归测试)        │
└───────────────────────┘
```

---

## 三、技能 (Skills) 详解

### 3.1 流程控制技能

#### brainstorming - 需求探索与设计

| 属性 | 值 |
|------|-----|
| **触发条件** | 任何创意工作前（创建功能、构建组件、添加功能、修改行为） |
| **调用时机** | 在 EnterPlanMode 之前、编写代码之前 |
| **优先级** | 最高（必须首先调用） |

**作用：**
1. 通过苏格拉底式对话探索用户真实意图
2. 提出 2-3 种方案并给出推荐
3. **Spring Boot 项目特有：** 强制进行数据库表结构设计，验证审计字段

**Checklist:**
1. 探索项目上下文
2. 提供可视化伴侣（如需要）
3. 提出澄清问题（一次一个）
4. 提出 2-3 种方案
5. 展示设计
6. **数据库设计（Spring Boot 项目必填）** ← 新增
7. 编写设计文档
8. 设计评审循环
9. 用户审查设计文档
10. 过渡到实现（调用 writing-plans）

**产出：** `docs/xo1997-dev/specs/YYYY-MM-DD-<topic>-design.md`

---

#### writing-plans - 编写实现计划

| 属性 | 值 |
|------|-----|
| **触发条件** | 有已批准的设计文档，需要编写实现计划 |
| **调用时机** | brainstorming 完成后 |
| **前置技能** | brainstorming, using-git-worktrees |

**作用：**
1. 将设计分解为 2-5 分钟的小任务
2. 提供精确的文件路径和完整代码
3. **Spring Boot 项目特有：** Entity 创建时验证审计字段

**任务结构:**
```markdown
### Task N: [组件名称]

**Files:**
- Create: `src/main/java/com/example/module/user/entity/User.java`
- Create: `src/main/java/com/example/module/user/mapper/UserMapper.java`
...

- [ ] **Step 1: Write the failing test**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Write minimal implementation**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
```

**产出：** `docs/plans/YYYY-MM-DD-<feature-name>.md`

---

#### executing-plans - 执行实现计划（当前会话）

| 属性 | 值 |
|------|-----|
| **触发条件** | 有实现计划需要在当前会话执行 |
| **调用时机** | writing-plans 完成后 |
| **适用场景** | 无子代理支持的平台 |

**作用：**
1. 加载并审查计划
2. 逐个执行任务
3. 每批次后进行代码审查
4. 完成后调用 finishing-a-development-branch

**注意：** 如果平台支持子代理（如 Claude Code），推荐使用 subagent-driven-development 代替。

---

#### subagent-driven-development - 子代理驱动开发

| 属性 | 值 |
|------|-----|
| **触发条件** | 有实现计划需要执行，且任务相对独立 |
| **调用时机** | writing-plans 完成后 |
| **适用场景** | 有子代理支持的平台（Claude Code、Codex） |
| **优先级** | 高于 executing-plans |

**作用：**
1. 为每个任务派发独立的子代理
2. 双阶段审查：
   - **阶段1：** 规范符合性审查
   - **阶段2：** 代码质量审查
3. 自动修复审查问题
4. 完成后调用 finishing-a-development-branch

**流程:**
```
Task 1 → 派发实现子代理 → 规范审查 → 质量审查 → 完成
    ↓
Task 2 → 派发实现子代理 → 规范审查 → 质量审查 → 完成
    ↓
...
    ↓
最终代码审查 → finishing-a-development-branch
```

---

### 3.2 开发实践技能

#### test-driven-development - 测试驱动开发

| 属性 | 值 |
|------|-----|
| **触发条件** | 实现任何功能或修复 bug |
| **调用时机** | 编写实现代码之前 |
| **类型** | 刚性（必须严格遵循） |

**详细文档：** [tdd-process.md](./tdd-process.md)

**核心原则：** 没有失败测试，不写生产代码。

**RED-GREEN-REFACTOR 循环:**
```
RED: 写失败测试 → 验证测试失败 →
GREEN: 最小实现 → 验证测试通过 →
REFACTOR: 重构 → 保持测试通过
```

**Spring Boot 项目适配:**
- 测试框架：JUnit 5 + Mockito
- 测试命令：`mvn test -Dtest=ClassName#methodName`
- Service 测试：`@ExtendWith(MockitoExtension.class)`
- Controller 测试：`@WebMvcTest`
- 集成测试：`@SpringBootTest` + H2 内存数据库

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

**Spring Boot 项目适配:**
- 日志配置调试指南
- 5 个常见问题排查手册
- Actuator 端点使用说明

---

#### verification-before-completion - 完成前验证

| 属性 | 值 |
|------|-----|
| **触发条件** | 声称工作完成、修复问题、测试通过之前 |
| **调用时机** | 提交代码、创建 PR、完成任务之前 |

**核心原则：** 证据先于声明，永远如此。

**铁律:**
```
没有新鲜验证证据，不声称完成。
如果这个消息中没有运行验证命令，就不能声称它通过。
```

**Spring Boot 项目验证命令:**
| 验证类型 | 命令 |
|----------|------|
| 运行所有测试 | `mvn clean test` |
| 运行单个测试类 | `mvn test -Dtest=ClassName` |
| 运行单个测试方法 | `mvn test -Dtest=ClassName#methodName` |
| 仅编译 | `mvn clean compile` |
| 打包（跳过测试）| `mvn clean package -DskipTests` |

---

### 3.3 协作技能

#### requesting-code-review - 请求代码审查

| 属性 | 值 |
|------|-----|
| **触发条件** | 完成任务、实现主要功能、合并前 |
| **调用时机** | 任务完成后、合并前 |

**作用：**
1. 派发 code-reviewer 子代理
2. 提供精确的审查上下文（不含会话历史）
3. 分类处理反馈

**问题分类:**
| 类型 | 处理方式 |
|------|----------|
| **Critical** | 立即修复 |
| **Important** | 继续前修复 |
| **Minor** | 稍后处理 |

---

#### code-reviewer Agent - 代码审查代理

| 属性 | 值 |
|------|-----|
| **类型** | Agent（子代理） |
| **触发方式** | 由 requesting-code-review 调用 |

**审查维度:**

| 维度 | 检查项 |
|------|--------|
| **计划符合性** | 实现是否与计划一致 |
| **分层架构** | Controller/Service/Mapper 职责划分 |
| **MyBatis-Plus** | Entity 注解、Mapper 接口、条件构造器 |
| **事务管理** | @Transactional 位置、传播行为、大事务避免 |
| **API 规范** | RESTful 风格、统一响应格式、参数校验 |

**分层架构审查清单:**

| 审查项 | Controller | Service | Mapper |
|--------|------------|---------|--------|
| 业务逻辑 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 数据库操作 | ❌ 禁止 | ✅ 通过 Mapper | ✅ 允许 |
| HTTP 相关代码 | ✅ 允许 | ❌ 禁止 | ❌ 禁止 |
| 参数校验 | ✅ 允许 | ✅ 允许 | ❌ 禁止 |
| 事务控制 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 实体对象使用 | DTO/VO | Entity | Entity |

---

#### finishing-a-development-branch - 完成开发分支

| 属性 | 值 |
|------|-----|
| **触发条件** | 实现完成、所有测试通过 |
| **调用时机** | 所有任务完成后 |

**流程:**
1. 验证测试通过
2. 确定基础分支
3. 提供 4 个选项
4. 执行用户选择
5. 清理 Worktree

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

**目录选择优先级:**
1. 已存在的目录（`.worktrees` 或 `worktrees`）
2. CLAUDE.md 中的配置
3. 询问用户

**安全验证：** 对于项目本地目录，必须验证已在 .gitignore 中忽略。

---

#### dispatching-parallel-agents - 并行代理调度

| 属性 | 值 |
|------|-----|
| **触发条件** | 有 2+ 个独立任务，无共享状态或顺序依赖 |
| **调用时机** | 需要并行处理多个独立问题时 |

**使用场景:**
- 3+ 测试文件失败，根因不同
- 多个子系统独立损坏
- 每个问题可以独立理解

**不适用场景:**
- 失败相关（修复一个可能修复其他）
- 需要理解完整系统状态
- 代理会互相干扰

---

### 3.4 Spring Boot 专属技能

#### springboot-best-practices - Spring Boot 最佳实践

| 属性 | 值 |
|------|-----|
| **触发条件** | 构建 Spring Boot REST API、重构不一致的控制器 |
| **适用项目** | Spring Boot 2.7.18 |

**覆盖内容:**
- 分层架构规范
- 核心注解使用
- 依赖注入规范
- 配置管理
- 参数校验
- 异常处理
- 事务管理

---

#### mybatis-plus-patterns - MyBatis-Plus 模式

| 属性 | 值 |
|------|-----|
| **触发条件** | 使用 MyBatis-Plus 进行数据库操作 |
| **适用版本** | MyBatis-Plus 3.5.7 |

**覆盖内容:**
- Entity 设计规范（含审计字段）
- Mapper 接口规范
- 条件构造器使用
- 分页查询
- 逻辑删除
- 自定义 SQL 方法

---

#### springboot-unified-response - Spring Boot 统一响应

| 属性 | 值 |
|------|-----|
| **触发条件** | 构建需要一致响应格式的 REST API |

**覆盖内容:**
- Result<T> 统一响应格式
- 分类业务异常（400/403/404）
- 全局异常处理
- 错误码规范

---

## 四、钩子 (Hooks)

### 4.1 SessionStart Hook

**触发时机：** 会话启动、恢复、清空、压缩时

**作用：** 自动注入 `using-xo1997-dev` 技能内容，确保 AI 在任何任务开始前都知道技能系统的存在和使用规则。

**配置文件：** `hooks/hooks.json`
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

**执行脚本：** `hooks/session-start`
- 读取 `using-xo1997-dev/SKILL.md` 内容
- 转义为 JSON 格式
- 注入到会话上下文中

---

## 五、命令 (Commands)

### 5.1 /brainstorm

**文件：** `commands/brainstorm.md`

**作用：** 快速启动头脑风暴工作流

**用法：**
```
/brainstorm
```

**等效于：** 调用 `xo1997-dev:brainstorming` 技能

---

### 5.2 /write-plan

**文件：** `commands/write-plan.md`

**作用：** 快速启动编写实现计划工作流

**用法：**
```
/write-plan
```

**等效于：** 调用 `xo1997-dev:writing-plans` 技能

---

### 5.3 /execute-plan

**文件：** `commands/execute-plan.md`

**作用：** 快速启动执行实现计划工作流

**用法：**
```
/execute-plan
```

**等效于：** 调用 `xo1997-dev:executing-plans` 技能

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
    ├─ 是执行计划请求？
    │       │
    │       ├─ 有子代理支持？ → subagent-driven-development
    │       │
    │       └─ 无子代理支持？ → executing-plans
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
    └─ 多个独立任务？
            │
            └─ dispatching-parallel-agents
```

---

## 七、Spring Boot 项目特殊配置

### 7.1 审计字段强制检查

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

### 7.2 测试命令

| 场景 | 命令 |
|------|------|
| 运行所有测试 | `mvn clean test` |
| 运行单个测试类 | `mvn test -Dtest=ClassName` |
| 运行单个测试方法 | `mvn test -Dtest=ClassName#methodName` |
| 编译验证 | `mvn clean compile` |
| 打包验证 | `mvn clean package -DskipTests` |

### 7.3 代码审查标准

Spring Boot 项目审查包含：
1. **分层架构审查** - Controller/Service/Mapper 职责划分
2. **MyBatis-Plus 规范** - Entity 注解、Mapper 接口、条件构造器
3. **事务管理审查** - @Transactional 位置、传播行为
4. **API 规范审查** - RESTful 风格、统一响应格式

---

## 八、最佳实践

### 8.1 开发新功能

```
1. /brainstorm          → 探索需求，设计数据库表结构
2. 批准设计             → 自动创建 Worktree
3. /write-plan          → 编写详细实现计划
4. 批准计划             →
5. 自动执行             → subagent-driven-development（推荐）
6. 每任务审查           → 双阶段审查
7. 完成验证             → verification-before-completion
8. 分支处理             → finishing-a-development-branch
```

### 8.2 修复 Bug

```
1. 发现问题             →
2. systematic-debugging → 四阶段调试流程
3. 找到根因             →
4. test-driven-development → 编写回归测试
5. 实现修复             →
6. verification-before-completion → 验证修复
```

### 8.3 并行处理多问题

```
1. 识别独立问题域       →
2. dispatching-parallel-agents → 派发多个子代理
3. 并行处理             →
4. 整合结果             →
5. 验证                 → 运行完整测试套件
```

---

## 九、文件结构

```
xo1997-dev/
├── .claude-plugin/
│   ├── plugin.json          # 插件配置
│   └── marketplace.json     # 市场信息
├── agents/
│   └── code-reviewer.md     # 代码审查代理
├── commands/
│   ├── brainstorm.md        # /brainstorm 命令
│   ├── execute-plan.md      # /execute-plan 命令
│   └── write-plan.md        # /write-plan 命令
├── hooks/
│   ├── hooks.json           # 钩子配置
│   ├── session-start        # 会话启动钩子脚本
│   └── run-hook.cmd         # 钩子运行器
├── skills/
│   ├── brainstorming/       # 需求探索与设计
│   ├── writing-plans/       # 编写实现计划
│   ├── executing-plans/     # 执行实现计划
│   ├── subagent-driven-development/  # 子代理驱动开发
│   ├── test-driven-development/      # 测试驱动开发
│   ├── systematic-debugging/         # 系统化调试
│   ├── verification-before-completion/ # 完成前验证
│   ├── requesting-code-review/       # 请求代码审查
│   ├── finishing-a-development-branch/ # 完成开发分支
│   ├── using-git-worktrees/          # Git Worktree 管理
│   ├── dispatching-parallel-agents/  # 并行代理调度
│   ├── using-xo1997-dev/             # 技能系统入口
│   ├── springboot-best-practices/    # Spring Boot 最佳实践
│   ├── mybatis-plus-patterns/        # MyBatis-Plus 模式
│   └── springboot-unified-response/  # 统一响应格式
├── GEMINI.md                # Gemini CLI 兼容配置
├── README.md                # 插件说明
└── xo1997-dev-customization.md  # 定制化文档
```

---

## 十、总结

xo1997-dev 提供了一套完整的软件工程实践工作流：

| 核心价值 | 实现方式 |
|----------|----------|
| **测试先行** | test-driven-development 的 RED-GREEN-REFACTOR 循环 |
| **系统化调试** | systematic-debugging 的四阶段流程 |
| **证据驱动** | verification-before-completion 的铁律 |
| **代码质量** | 双阶段审查（规范 + 质量）|
| **隔离开发** | using-git-worktrees 的隔离工作空间 |
| **Spring Boot 适配** | 审计字段检查、Maven 命令、分层架构审查 |

通过 SessionStart Hook 自动注入技能系统，确保 AI 在任何任务开始前都能正确识别和调用相关技能。