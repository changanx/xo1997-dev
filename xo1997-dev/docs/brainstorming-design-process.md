# brainstorming 技能详解 - 设计文档编写流程

> 本文档详细描述 brainstorming 技能如何将想法转化为完整的设计文档

---

## 一、整体流程概览

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Brainstorming 设计文档编写流程                             │
└─────────────────────────────────────────────────────────────────────────────┘

     ┌──────────────────┐
     │  用户输入想法     │
     └────────┬─────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 1: 探索项目上下文       │
│ • 检查文件结构               │
│ • 阅读现有文档               │
│ • 查看最近提交               │
│ • 了解现有模式               │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 2: 提供可视化伴侣       │  ← 可选，仅当涉及视觉问题时
│ • 独立消息发送               │
│ • 询问是否使用浏览器展示     │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 3: 提出澄清问题         │
│ • 一次一个问题               │
│ • 理解目的/约束/成功标准      │
│ • 评估范围是否需要分解       │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 4: 提出 2-3 种方案      │
│ • 包含权衡分析               │
│ • 给出推荐和理由             │
│ • 用户选择方案               │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 5: 分段展示设计         │
│ • 每段询问是否正确           │
│ • 覆盖架构/组件/数据流/错误   │
│ • 用户批准整体设计           │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 6: 数据库设计           │  ← Spring Boot 项目必填
│ • 表结构设计                 │
│ • 索引设计                   │
│ • 审计字段检查 ✓             │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 7: 编写设计文档         │
│ • 保存到 docs/xo1997-dev/   │
│ • 提交到 Git                 │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 8: 设计审查循环         │
│ • 派发 spec-reviewer 子代理  │
│ • 修复问题                   │
│ • 重新审查（最多5次）         │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 9: 用户审查设计文档      │
│ • 展示文档路径               │
│ • 用户确认或提出修改          │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 10: 过渡到实现          │
│ • 调用 writing-plans 技能    │
└─────────────────────────────┘
```

---

## 二、各阶段详细说明

### Step 1: 探索项目上下文

**目的：** 在开始设计前了解现有项目状态

**操作：**
```
1. 检查文件结构
   - 使用 Glob 查找关键文件
   - 了解项目的目录组织

2. 阅读现有文档
   - README.md
   - CLAUDE.md / AGENTS.md
   - 现有设计文档

3. 查看最近提交
   - git log --oneline -10
   - 了解最近的开发方向

4. 了解现有模式
   - 代码风格
   - 架构模式
   - 测试方式
```

**Spring Boot 项目重点关注：**
```
src/main/java/com/example/
├── common/          # 是否已有统一异常处理？
├── module/          # 现有模块结构如何组织？
│   └── user/
│       ├── controller/
│       ├── service/
│       ├── mapper/
│       └── entity/
└── Application.java
```

---

### Step 2: 提供可视化伴侣（可选）

**触发条件：** 预期后续问题会涉及视觉内容

**内容：** UI 原型、线框图、布局对比、架构图

**重要规则：**
- 必须作为**独立消息**发送
- 不能与澄清问题混合
- 用户接受后才可使用浏览器展示

**示例消息：**
```
Some of what we're working on might be easier to explain if I can show it
to you in a web browser. I can put together mockups, diagrams, comparisons,
and other visuals as we go. This feature is still new and can be token-intensive.
Want to try it? (Requires opening a local URL)
```

---

### Step 3: 提出澄清问题

**核心原则：**
- **一次一个问题** - 不要用多个问题淹没用户
- **优先多选题** - 比开放式问题更容易回答
- **聚焦理解** - 目的、约束、成功标准

**问题类型：**

| 类型 | 示例 |
|------|------|
| 目的 | "这个功能主要解决什么问题？" |
| 约束 | "有没有特定的技术限制或时间要求？" |
| 成功标准 | "怎么判断这个功能完成了？" |
| 范围评估 | "这个功能是否可以分解为更小的部分？" |

**范围评估：**

如果用户请求描述了多个独立子系统（如"构建一个包含聊天、文件存储、计费和分析的平台"），需要立即标记：

```
这个请求涉及多个独立子系统。建议分解为：
1. 聊天模块
2. 文件存储模块
3. 计费模块
4. 分析模块

我们先从哪个开始设计？
```

---

### Step 4: 提出 2-3 种方案

**目的：** 提供多种实现路径，让用户做出知情选择

**方案结构：**
```
方案 A（推荐）: [名称]
- 描述: ...
- 优点: ...
- 缺点: ...
- 适用场景: ...

方案 B: [名称]
- 描述: ...
- 优点: ...
- 缺点: ...

方案 C: [名称]
- 描述: ...
```

**推荐优先：** 先展示推荐的方案并解释理由

**示例：**
```
我推荐方案 A，理由是：
1. 代码改动最小
2. 与现有架构一致
3. 测试覆盖更容易

方案 A: 扩展现有 UserService
- 在现有服务中添加新方法
- 复用现有数据访问层
- 优点: 改动小，风险低
- 缺点: UserService 可能变大

方案 B: 创建独立 NotificationService
- 新建独立服务
- 优点: 职责分离更清晰
- 缺点: 增加文件数量

您倾向于哪种方案？
```

---

### Step 5: 分段展示设计

**目的：** 逐步展示设计，每段获得用户确认

**设计覆盖内容：**
1. 架构概述
2. 组件设计
3. 数据流
4. 错误处理
5. 测试策略

**段落长度：**
- 简单部分：几句话
- 复杂部分：200-300 字

**示例流程：**

```
--- 第一段：架构概述 ---

整体采用分层架构：
- Controller 层：处理 HTTP 请求，参数校验
- Service 层：业务逻辑，事务管理
- Mapper 层：数据访问

这部分看起来对吗？

[用户确认后继续]

--- 第二段：组件设计 ---

UserController:
- GET /api/users - 用户列表
- GET /api/users/{id} - 用户详情
- POST /api/users - 创建用户
- PUT /api/users/{id} - 更新用户
- DELETE /api/users/{id} - 删除用户

UserService:
- list(): List<UserVO>
- getById(Long id): UserVO
- create(UserCreateDTO dto): UserVO
- update(Long id, UserUpdateDTO dto): UserVO
- delete(Long id): void

这部分看起来对吗？

[用户确认后继续]

--- 第三段：数据流 ---

创建用户流程：
1. Controller 接收 UserCreateDTO
2. 转换为 User Entity
3. Service 调用 Mapper 保存
4. 返回 UserVO

这部分看起来对吗？

[...继续其他段落...]
```

---

### Step 6: 数据库设计（Spring Boot 项目必填）

**触发条件：** Spring Boot + MyBatis-Plus 项目

**设计内容：**
1. 表名、字段、类型、约束
2. 索引设计（查询优化）
3. 表间关系（外键、关联关系）
4. 统一审计字段

**审计字段检查清单：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | BIGINT | ✅ | 主键，自增 |
| `create_by` | VARCHAR(30) | - | 创建人 |
| `create_time` | DATETIME | ✅ | 创建时间，默认 CURRENT_TIMESTAMP |
| `update_by` | VARCHAR(30) | - | 更新人 |
| `update_time` | DATETIME | ✅ | 更新时间，默认 CURRENT_TIMESTAMP |
| `is_del` | TINYINT(1) | ✅ | 逻辑删除(0:未删除,1:删除) |

**设计示例：**

```
用户表 (t_user)

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
|--------|------|----------|--------|------|
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| username | VARCHAR(50) | NOT NULL | - | 用户名 |
| email | VARCHAR(100) | NOT NULL | - | 邮箱 |
| password | VARCHAR(255) | NOT NULL | - | 密码(加密) |
| status | TINYINT | NOT NULL | 1 | 状态(1:正常,0:禁用) |
| create_by | VARCHAR(30) | NULL | - | 创建人 |
| create_time | DATETIME | NOT NULL | CURRENT_TIMESTAMP | 创建时间 |
| update_by | VARCHAR(30) | NULL | - | 更新人 |
| update_time | DATETIME | NOT NULL | CURRENT_TIMESTAMP | 更新时间 |
| is_del | TINYINT(1) | NOT NULL | 0 | 逻辑删除 |

索引设计：
- PRIMARY KEY (id)
- UNIQUE KEY uk_username (username)
- UNIQUE KEY uk_email (email)
- KEY idx_create_time (create_time)

性能优化考虑：
- username 和 email 建立唯一索引，支持快速查询和唯一性校验
- create_time 建立索引，支持时间范围查询
```

**强制询问：**

在设计每个表时，必须询问：
```
这个表是否需要标准审计字段 (create_by, create_time, update_by, update_time, is_del)？
```

如果用户说不需要，必须确认原因并记录在文档中。

---

### Step 7: 编写设计文档

**文档位置：** `docs/xo1997-dev/specs/YYYY-MM-DD-<topic>-design.md`

**文档结构：**

```markdown
# [功能名称] 设计文档

> 创建时间: YYYY-MM-DD
> 状态: 草稿 / 待审查 / 已批准

## 1. 概述

### 1.1 目标
[一句话描述这个功能要达成什么目标]

### 1.2 背景
[为什么需要这个功能，解决了什么问题]

### 1.3 范围
[包含什么，不包含什么]

## 2. 架构设计

### 2.1 整体架构
[架构图或描述]

### 2.2 组件设计
[各组件职责]

### 2.3 数据流
[数据如何在组件间流动]

## 3. 详细设计

### 3.1 API 设计
[接口定义]

### 3.2 数据模型
[数据结构设计]

### 3.3 数据库设计
[表结构设计] ← Spring Boot 项目必填

## 4. 错误处理

[异常类型和处理方式]

## 5. 测试策略

[如何测试这个功能]

## 6. 实现注意事项

[需要特别注意的地方]
```

**操作步骤：**
```
1. 使用 Write 工具创建文档
2. 使用 Bash 提交到 Git:
   git add docs/xo1997-dev/specs/YYYY-MM-DD-<topic>-design.md
   git commit -m "docs: add design for <topic>"
```

---

### Step 8: 设计审查循环

**目的：** 通过子代理自动审查设计文档的完整性和质量

**审查维度：**

| 类别 | 检查内容 |
|------|----------|
| **完整性** | TODO 标记、占位符、"TBD"、不完整章节 |
| **覆盖度** | 缺失的错误处理、边界情况、集成点 |
| **一致性** | 内部矛盾、冲突的需求 |
| **清晰度** | 模糊的需求 |
| **YAGNI** | 未请求的功能、过度工程 |
| **范围** | 是否聚焦到可以单个计划实现 |
| **架构** | 单元是否有清晰边界、良好定义的接口 |

**审查流程：**

```
┌─────────────────────────┐
│ 派发 spec-reviewer 子代理│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ 子代理审查设计文档       │
│ • 完整性检查             │
│ • 一致性检查             │
│ • YAGNI 检查             │
└───────────┬─────────────┘
            │
            ▼
     ┌──────┴──────┐
     │ 有问题？     │
     └──────┬──────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
  有问题          无问题
    │               │
    ▼               ▼
┌─────────┐   ┌─────────┐
│ 修复问题 │   │ 审查通过 │
│ 重新审查 │   └────┬────┘
└────┬────┘        │
     │             │
     └──────┬──────┘
            │
            ▼
   ┌────────────────┐
   │ 超过5次迭代？   │
   └────────┬───────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
   是              否
    │               │
    ▼               ▼
┌─────────┐   ┌─────────┐
│ 请求用户 │   │ 继续流程 │
│ 介入     │   └─────────┘
└─────────┘
```

**子代理调用示例：**

```
使用 Task 工具:
  description: "Review spec document"
  prompt: |
    You are a spec document reviewer. Verify this spec is complete and ready for planning.

    **Spec to review:** docs/xo1997-dev/specs/2026-03-15-user-management-design.md

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, "TBD", incomplete sections |
    | Coverage | Missing error handling, edge cases, integration points |
    | Consistency | Internal contradictions, conflicting requirements |
    | Clarity | Ambiguous requirements |
    | YAGNI | Unrequested features, over-engineering |

    ## Output Format

    **Status:** ✅ Approved | ❌ Issues Found

    **Issues (if any):**
    - [Section X]: [specific issue] - [why it matters]
```

---

### Step 9: 用户审查设计文档

**目的：** 让用户最终确认设计文档

**操作：**
```
设计文档已编写并提交到 docs/xo1997-dev/specs/2026-03-15-user-management-design.md

请审查文档内容，确认是否需要修改。
如果没问题，我们将开始编写实现计划。
```

**用户响应处理：**

| 用户响应 | 处理方式 |
|----------|----------|
| 批准 | 进入 Step 10，调用 writing-plans |
| 请求修改 | 修改后重新运行 Step 8 审查循环 |
| 提出问题 | 回答问题后确认是否需要修改 |

---

### Step 10: 过渡到实现

**唯一允许的下一步：** 调用 `writing-plans` 技能

**禁止行为：**
- 不能调用 frontend-design
- 不能调用 mcp-builder
- 不能调用任何其他实现技能
- 不能直接开始编写代码

**调用方式：**
```
使用 Skill 工具:
  skill: "xo1997-dev:writing-plans"
```

---

## 三、设计文档示例

### 完整示例：用户管理功能

```markdown
# 用户管理功能设计文档

> 创建时间: 2026-03-15
> 状态: 已批准

## 1. 概述

### 1.1 目标
实现用户管理模块，支持用户的增删改查和状态管理。

### 1.2 背景
系统需要基础的用户管理功能，支持管理员对用户进行管理操作。

### 1.3 范围

**包含：**
- 用户 CRUD 操作
- 用户状态管理（启用/禁用）
- 用户查询和分页

**不包含：**
- 用户认证（登录）
- 用户授权（权限管理）
- 用户密码重置

## 2. 架构设计

### 2.1 整体架构

采用分层架构：
- Controller 层：UserController，处理 HTTP 请求
- Service 层：UserService/UserServiceImpl，业务逻辑
- Mapper 层：UserMapper，数据访问

### 2.2 组件设计

**UserController**
- GET /api/users - 用户列表（分页）
- GET /api/users/{id} - 用户详情
- POST /api/users - 创建用户
- PUT /api/users/{id} - 更新用户
- DELETE /api/users/{id} - 删除用户
- PUT /api/users/{id}/status - 更新状态

**UserService**
- Page<UserVO> list(UserQueryDTO dto)
- UserVO getById(Long id)
- UserVO create(UserCreateDTO dto)
- UserVO update(Long id, UserUpdateDTO dto)
- void delete(Long id)
- void updateStatus(Long id, Integer status)

**UserMapper**
- 继承 BaseMapper<User>

### 2.3 数据流

```
创建用户流程：
HTTP Request → Controller (DTO) → Service (Entity) → Mapper (DB)
            ← Controller (VO)   ← Service (Entity) ←
```

## 3. 详细设计

### 3.1 API 设计

| 方法 | 路径 | 描述 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| GET | /api/users | 用户列表 | - | Result<Page<UserVO>> |
| GET | /api/users/{id} | 用户详情 | - | Result<UserVO> |
| POST | /api/users | 创建用户 | UserCreateDTO | Result<UserVO> |
| PUT | /api/users/{id} | 更新用户 | UserUpdateDTO | Result<UserVO> |
| DELETE | /api/users/{id} | 删除用户 | - | Result<Void> |

### 3.2 数据模型

**UserCreateDTO:**
```java
@Data
public class UserCreateDTO {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 2, max = 50, message = "用户名长度2-50字符")
    private String username;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度6-20字符")
    private String password;
}
```

**UserVO:**
```java
@Data
public class UserVO {
    private Long id;
    private String username;
    private String email;
    private Integer status;
    private LocalDateTime createTime;
}
```

### 3.3 数据库设计

**用户表 (t_user)**

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
|--------|------|----------|--------|------|
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| username | VARCHAR(50) | NOT NULL | - | 用户名 |
| email | VARCHAR(100) | NOT NULL | - | 邮箱 |
| password | VARCHAR(255) | NOT NULL | - | 密码(BCrypt加密) |
| status | TINYINT | NOT NULL | 1 | 状态(1:正常,0:禁用) |
| create_by | VARCHAR(30) | NULL | - | 创建人 |
| create_time | DATETIME | NOT NULL | CURRENT_TIMESTAMP | 创建时间 |
| update_by | VARCHAR(30) | NULL | - | 更新人 |
| update_time | DATETIME | NOT NULL | CURRENT_TIMESTAMP | 更新时间 |
| is_del | TINYINT(1) | NOT NULL | 0 | 逻辑删除 |

**索引设计：**
- PRIMARY KEY (id)
- UNIQUE KEY uk_username (username)
- UNIQUE KEY uk_email (email)
- KEY idx_status (status)
- KEY idx_create_time (create_time)

## 4. 错误处理

| 场景 | 异常类型 | 错误码 | 错误信息 |
|------|----------|--------|----------|
| 用户不存在 | NotFoundException | 404 | 用户不存在 |
| 用户名已存在 | BadRequestException | 400 | 用户名已被使用 |
| 邮箱已存在 | BadRequestException | 400 | 邮箱已被使用 |

## 5. 测试策略

### 5.1 单元测试

- UserServiceTest：使用 Mockito mock UserMapper
- 覆盖所有业务方法
- 测试正常流程和异常情况

### 5.2 集成测试

- UserControllerTest：使用 @WebMvcTest
- 测试所有 API 端点
- 验证参数校验和响应格式

### 5.3 测试数据

使用 H2 内存数据库，MODE=MySQL

## 6. 实现注意事项

1. 密码使用 BCrypt 加密存储
2. 用户名和邮箱需要唯一性校验
3. 删除使用逻辑删除，不物理删除
4. 分页查询需要支持用户名模糊搜索
```

---

## 四、关键原则总结

| 原则 | 说明 |
|------|------|
| **一次一个问题** | 不要用多个问题淹没用户 |
| **多选题优先** | 比开放式问题更容易回答 |
| **YAGNI 无情** | 从设计中移除不必要的功能 |
| **探索替代方案** | 总是提出 2-3 种方案再确定 |
| **增量验证** | 展示设计，获得批准后继续 |
| **Spring Boot 特有** | 数据库设计必须验证审计字段 |

---

## 五、常见问题处理

### Q1: 用户说"这个很简单，直接做吧"

**回应：**
```
即使是简单的功能，先确认设计也能避免后续返工。
设计文档只需要几分钟，但能确保我们对需求理解一致。
```

### Q2: 用户在审查后提出大量修改

**处理：**
1. 记录所有修改请求
2. 更新设计文档
3. 重新运行审查循环（Step 8）
4. 再次请用户确认

### Q3: 审查循环超过 5 次仍未通过

**处理：**
1. 停止自动审查
2. 向用户报告问题
3. 请求用户介入指导

### Q4: 涉及多个独立子系统

**处理：**
1. 立即标记范围问题
2. 帮助用户分解为子项目
3. 逐个子项目进行设计
4. 每个子项目独立走完整流程