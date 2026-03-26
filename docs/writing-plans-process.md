# writing-plans 技能详解 - 实现计划编写流程

> 本文档详细描述 writing-plans 技能如何将设计文档转化为可执行的实现计划

---

## 一、整体流程概览

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Writing Plans 实现计划编写流程                             │
└─────────────────────────────────────────────────────────────────────────────┘

     ┌──────────────────┐
     │  设计文档已批准   │ ← 来自 brainstorming
     └────────┬─────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 1: 范围检查             │
│ • 是否包含多个独立子系统？   │
│ • 是否需要拆分为多个计划？   │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 2: 创建隔离工作空间     │
│ • 检查是否已在 worktree 中   │
│ • 调用 using-git-worktrees   │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 3: 确认数据库设计       │
│ • 读取设计文档中的表结构     │
│ • 创建 database.md          │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 4: 规划文件结构         │
│ • 确定需要创建的文件         │
│ • 文件创建顺序               │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 5: 任务分解             │
│ • 按功能模块拆分为任务       │
│ • 每个任务 2-5 分钟完成      │
│ • 遵循 TDD 流程              │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 6: 编写计划文档         │
│ • 计划头部信息               │
│ • 分块（Chunk）编写          │
│ • 每块 ≤ 1000 行             │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 7: 计划审查循环         │
│ • 派发 plan-reviewer 子代理  │
│ • 修复问题                   │
│ • 重新审查（最多5次）         │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 8: 用户确认             │
│ • 展示计划路径               │
│ • 用户确认执行               │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Step 9: 执行交接             │
│ • 有子代理 → subagent-driven-development │
│ • 前后端 → team-driven-development    │
│ • 无子代理 → executing-plans          │
└─────────────────────────────┘
```

---

## 二、各阶段详细说明

### Step 1: 范围检查

**目的：** 确保计划范围合理，不会过大

**检查内容：**
```
设计文档是否描述了多个独立子系统？
例如："构建一个包含用户管理、订单管理、支付系统的平台"

如果是 → 建议拆分为多个独立计划
```

**拆分原则：**
- 每个计划应该能独立产出可工作、可测试的软件
- 每个子系统有自己的 spec → plan → implementation 周期

**示例：**
```
原设计："用户管理 + 订单管理 + 支付系统"

拆分建议：
1. 计划1：用户管理模块（独立可用）
2. 计划2：订单管理模块（依赖计划1）
3. 计划3：支付系统集成（依赖计划1、2）

执行顺序：计划1 → 计划2 → 计划3
```

---

### Step 2: 确认数据库设计

**目的：** 将设计文档中的数据库设计固化为独立的表结构文档

**两阶段数据库设计：**

| 阶段 | 时机 | 内容 |
|------|------|------|
| **讨论阶段** | brainstorming | 讨论并设计表结构 |
| **确认阶段** | writing-plans | 最终确认并记录 |

**操作步骤：**

```
1. 读取设计文档中的数据库设计部分
2. 创建或更新 docs/database/表结构设计.md
3. 确保每个表包含审计字段
```

**审计字段必填检查：**

| 字段 | 类型 | 注解 |
|------|------|------|
| `id` | BIGINT | `@TableId(type = IdType.AUTO)` |
| `create_by` | VARCHAR(30) | - |
| `create_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| `update_by` | VARCHAR(30) | - |
| `update_time` | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| `is_del` | TINYINT(1) | DEFAULT 0 |

---

### Step 3: 规划文件结构

**目的：** 明确需要创建/修改的文件及其职责

**Spring Boot 项目标准目录结构：**

```
src/main/java/com/example/
├── common/                          # 公共组件
│   ├── exception/                   # 统一异常处理
│   │   ├── GlobalExceptionHandler.java
│   │   ├── BusinessException.java
│   │   ├── BadRequestException.java
│   │   ├── NotFoundException.java
│   │   └── ForbiddenException.java
│   └── result/                      # 统一响应格式
│       └── Result.java
├── schedule/                        # 定时任务
├── module/                          # 业务模块
│   └── user/                        # 用户模块
│       ├── controller/
│       │   └── UserController.java
│       ├── service/
│       │   ├── UserService.java
│       │   └── impl/
│       │       └── UserServiceImpl.java
│       ├── mapper/
│       │   └── UserMapper.java
│       ├── entity/
│       │   └── User.java
│       ├── dto/
│       │   ├── UserCreateDTO.java
│       │   ├── UserUpdateDTO.java
│       │   └── UserQueryDTO.java
│       ├── vo/
│       │   └── UserVO.java
│       ├── constants/
│       │   └── UserConstants.java
│       └── enums/
│           └── UserStatus.java
└── Application.java
```

**文件创建顺序（自顶向下）：**

```
1. Controller    → 定义 API 端点
2. DTO/VO        → 定义请求/响应对象
3. Service 接口  → 定义业务方法
4. Service 实现  → 实现业务逻辑
5. Mapper        → 定义数据访问
6. Entity        → 定义数据库映射
7. Test          → 编写测试
```

**为什么自顶向下？**
- 先定义 API 接口，确保接口设计正确
- 再逐层实现，每层依赖上层已定义的接口
- 最后编写测试验证

**文件职责划分：**

| 文件类型 | 职责 | 示例 |
|----------|------|------|
| Controller | HTTP 请求处理、参数校验、响应封装 | UserController.java |
| DTO | 接收请求参数 | UserCreateDTO.java |
| VO | 返回响应数据 | UserVO.java |
| Service | 业务逻辑定义 | UserService.java |
| ServiceImpl | 业务逻辑实现 | UserServiceImpl.java |
| Mapper | 数据库操作 | UserMapper.java |
| Entity | 数据库映射 | User.java |
| Test | 单元测试 | UserServiceTest.java |

---

### Step 4: 任务分解

**目的：** 将功能拆分为可执行的小任务

**任务粒度原则：**
- 每个步骤 2-5 分钟
- 一个步骤 = 一个动作
- 遵循 TDD 的 RED-GREEN-REFACTOR 循环

**标准任务结构：**

```markdown
### Task N: [组件名称]

**Files:**
- Create: `path/to/File1.java`
- Create: `path/to/File2.java`
...

- [ ] **Step 1: Write the failing test**
      [测试代码]

- [ ] **Step 2: Run test to verify it fails**
      Run: `mvn test -Dtest=ClassName#methodName`
      Expected: FAIL with [错误信息]

- [ ] **Step 3: Write minimal implementation**
      [实现代码]

- [ ] **Step 4: Run test to verify it passes**
      Run: `mvn test -Dtest=ClassName#methodName`
      Expected: PASS

- [ ] **Step 5: Commit**
      git add ...
      git commit -m "..."
```

**任务分解示例：**

假设要实现"用户创建"功能：

```
Task 1: 定义 API 和数据模型
  - Step 1: 创建 UserCreateDTO
  - Step 2: 创建 UserVO
  - Step 3: Commit

Task 2: 实现 Service 层
  - Step 1: 写测试 - shouldCreateUser_whenValidInput
  - Step 2: 运行测试验证失败
  - Step 3: 实现 UserService 接口
  - Step 4: 实现 UserServiceImpl
  - Step 5: 运行测试验证通过
  - Step 6: Commit

Task 3: 实现 Mapper 和 Entity
  - Step 1: 写测试 - shouldInsertUser
  - Step 2: 运行测试验证失败
  - Step 3: 创建 User Entity（含审计字段验证）
  - Step 4: 创建 UserMapper
  - Step 5: 运行测试验证通过
  - Step 6: Commit

Task 4: 实现 Controller 层
  - Step 1: 写测试 - shouldReturn201_whenCreateUser
  - Step 2: 运行测试验证失败
  - Step 3: 实现 UserController
  - Step 4: 运行测试验证通过
  - Step 5: Commit

Task 5: 集成验证
  - Step 1: 运行所有测试
  - Step 2: 验证 API 响应格式
  - Step 3: Commit
```

---

### Step 5: 编写计划文档

**计划文档位置：** `docs/plans/YYYY-MM-DD-<feature-name>.md`

**文档结构：**

```markdown
# [功能名称] Implementation Plan

> **For agentic workers:** REQUIRED: Use subagent-driven-development (if subagents available) or executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [一句话描述要构建什么]

**Architecture:** [2-3 句话描述架构方法]

**Tech Stack:** Spring Boot 2.7.18, MyBatis-Plus 3.5.7, MySQL, etc.

---

## Chunk 1: [模块/功能名称]

### Task 1: [任务名称]

**Files:**
- Create: `src/main/java/...`

- [ ] **Step 1: ...**
...

### Task 2: [任务名称]
...

---

## Chunk 2: [模块/功能名称]

### Task 3: [任务名称]
...
```

**计划头部必填项：**

```markdown
# User Management Implementation Plan

> **For agentic workers:** REQUIRED: Use subagent-driven-development (if subagents available) or executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement user CRUD operations with validation and error handling.

**Architecture:** Layered architecture with Controller-Service-Mapper pattern. RESTful API design with unified response format.

**Tech Stack:** Spring Boot 2.7.18, MyBatis-Plus 3.5.7, MySQL 8.0, JUnit 5, Mockito

---
```

**分块（Chunk）原则：**
- 使用 `## Chunk N: <name>` 分隔
- 每块 ≤ 1000 行
- 每块逻辑上自包含
- 便于分块审查

---

### Step 6: 计划审查循环

**目的：** 通过子代理自动审查计划的完整性和可执行性

**审查维度：**

| 类别 | 检查内容 |
|------|----------|
| **完整性** | 所有设计点都有对应任务 |
| **文件路径** | 路径是否正确、符合项目结构 |
| **代码正确性** | 代码示例是否可编译、语法正确 |
| **TDD 流程** | 每个功能是否有测试先行 |
| **审计字段** | Entity 是否包含审计字段 |
| **命令正确性** | Maven 命令是否正确 |

**审查流程：**

```
┌─────────────────────────┐
│ 派发 plan-reviewer 子代理│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ 子代理审查计划文档       │
│ • 完整性检查             │
│ • 代码正确性检查         │
│ • TDD 流程检查           │
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

---

### Step 7: 用户确认

**目的：** 让用户最终确认实现计划

**操作：**
```
计划已完成并保存到 docs/plans/2026-03-15-user-management.md

请审查计划内容，确认是否可以开始执行。
```

**用户响应处理：**

| 用户响应 | 处理方式 |
|----------|----------|
| 批准 | 进入 Step 9，执行交接 |
| 请求修改 | 修改后重新运行审查循环 |
| 提出问题 | 回答问题后确认是否需要修改 |

---

### Step 9: 执行交接

**目的：** 根据平台能力和项目类型选择正确的执行方式

**决策树：**

```
平台是否支持子代理？
        │
    ┌───┴───┐
    │       │
   是       否
    │       │
    ▼       ▼
┌────────┐ ┌────────┐
│判断项目 │ │executing│
│类型     │ │-plans  │
└───┬────┘ └────────┘
    │
    ├── 仅前端或仅后端 → subagent-driven-development
    │
    └── 前后端都需要 → team-driven-development
```

**有子代理支持（Claude Code 等）：**
- **仅前端或仅后端**：使用 `subagent-driven-development`
  - 每个任务派发独立子代理 + 双阶段审查
- **前后端都需要**：使用 `team-driven-development`
  - 派发 frontend-developer 和 backend-developer 子代理
  - team-coordinator 协调工作

**无子代理支持：**
- 在当前会话使用 `executing-plans`
- 分批执行，每批后设置检查点

---

## 三、任务编写规范

### 3.1 标准任务模板

```markdown
### Task N: [功能名称]

**Files:**
- Create: `src/main/java/com/example/module/user/controller/UserController.java`
- Create: `src/main/java/com/example/module/user/dto/UserCreateDTO.java`
- Create: `src/main/java/com/example/module/user/vo/UserVO.java`
- Create: `src/main/java/com/example/module/user/service/UserService.java`
- Create: `src/main/java/com/example/module/user/service/impl/UserServiceImpl.java`
- Create: `src/main/java/com/example/module/user/mapper/UserMapper.java`
- Create: `src/main/java/com/example/module/user/entity/User.java`
- Create: `src/test/java/com/example/module/user/service/UserServiceTest.java`

- [ ] **Step 1: Write the failing test**

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void shouldCreateUser_whenValidInput() {
        // Given
        UserCreateDTO dto = new UserCreateDTO();
        dto.setUsername("testuser");
        dto.setEmail("test@example.com");

        // When
        UserVO result = userService.create(dto);

        // Then
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        verify(userMapper).insert(any(User.class));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mvn test -Dtest=UserServiceTest#shouldCreateUser_whenValidInput`
Expected: FAIL with "Cannot resolve symbol 'UserService'"

- [ ] **Step 3: Write minimal implementation**

```java
// UserService.java
public interface UserService {
    UserVO create(UserCreateDTO dto);
}

// UserServiceImpl.java
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    @Override
    public UserVO create(UserCreateDTO dto) {
        User user = new User();
        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        userMapper.insert(user);
        return toVO(user);
    }

    private UserVO toVO(User user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setEmail(user.getEmail());
        return vo;
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn test -Dtest=UserServiceTest#shouldCreateUser_whenValidInput`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add src/main/java/com/example/module/user/
git add src/test/java/com/example/module/user/
git commit -m "feat(user): add user creation service"
```
```

### 3.2 Entity 任务模板（含审计字段验证）

```markdown
### Task N: Create User Entity

**Files:**
- Create: `src/main/java/com/example/module/user/entity/User.java`

- [ ] **Step 1: Write the failing test**

```java
@Test
void shouldHaveAuditFields_whenCreatingEntity() {
    User user = new User();

    // 验证审计字段存在
    assertDoesNotThrow(() -> user.getClass().getDeclaredField("id"));
    assertDoesNotThrow(() -> user.getClass().getDeclaredField("createBy"));
    assertDoesNotThrow(() -> user.getClass().getDeclaredField("createTime"));
    assertDoesNotThrow(() -> user.getClass().getDeclaredField("updateBy"));
    assertDoesNotThrow(() -> user.getClass().getDeclaredField("updateTime"));
    assertDoesNotThrow(() -> user.getClass().getDeclaredField("isDel"));
}
```

- [ ] **Step 2: Create Entity with audit fields**

```java
@Data
@TableName("t_user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String email;

    private String password;

    private Integer status;

    // 审计字段
    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer isDel;
}
```

- [ ] **Step 3: Verify audit fields in Entity**

Check that Entity includes:
- [x] `@TableName("t_user")` annotation
- [x] `@TableId(type = IdType.AUTO)` for id field
- [x] `@TableField(fill = FieldFill.INSERT)` for createBy, createTime
- [x] `@TableField(fill = FieldFill.INSERT_UPDATE)` for updateBy, updateTime
- [x] `@TableLogic` for isDel field

- [ ] **Step 4: Commit**

```bash
git add src/main/java/com/example/module/user/entity/User.java
git commit -m "feat(user): add User entity with audit fields"
```
```

### 3.3 Controller 任务模板

```markdown
### Task N: Create User Controller

**Files:**
- Create: `src/main/java/com/example/module/user/controller/UserController.java`
- Create: `src/test/java/com/example/module/user/controller/UserControllerTest.java`

- [ ] **Step 1: Write the failing test**

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void shouldReturn201_whenCreateUser() throws Exception {
        // Given
        UserCreateDTO dto = new UserCreateDTO();
        dto.setUsername("testuser");
        dto.setEmail("test@example.com");

        UserVO vo = new UserVO();
        vo.setId(1L);
        vo.setUsername("testuser");
        vo.setEmail("test@example.com");

        when(userService.create(any())).thenReturn(vo);

        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value(200))
            .andExpect(jsonPath("$.data.username").value("testuser"));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mvn test -Dtest=UserControllerTest#shouldReturn201_whenCreateUser`
Expected: FAIL with "Cannot resolve symbol 'UserController'"

- [ ] **Step 3: Write minimal implementation**

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public Result<UserVO> create(@RequestBody @Valid UserCreateDTO dto) {
        return Result.success(userService.create(dto));
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn test -Dtest=UserControllerTest#shouldReturn201_whenCreateUser`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add src/main/java/com/example/module/user/controller/
git add src/test/java/com/example/module/user/controller/
git commit -m "feat(user): add UserController with create endpoint"
```
```

---

## 四、完整计划示例

```markdown
# User Management Implementation Plan

> **For agentic workers:** REQUIRED: Use subagent-driven-development (if subagents available) or executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement user CRUD operations with validation, error handling, and unified response format.

**Architecture:** Layered architecture with Controller-Service-Mapper pattern. RESTful API design with unified Result<T> response format. MyBatis-Plus for data access with logical delete support.

**Tech Stack:** Spring Boot 2.7.18, MyBatis-Plus 3.5.7, MySQL 8.0, JUnit 5, Mockito, H2 (test)

---

## Chunk 1: Data Models and Entity

### Task 1: Create DTOs and VOs

**Files:**
- Create: `src/main/java/com/example/module/user/dto/UserCreateDTO.java`
- Create: `src/main/java/com/example/module/user/dto/UserUpdateDTO.java`
- Create: `src/main/java/com/example/module/user/dto/UserQueryDTO.java`
- Create: `src/main/java/com/example/module/user/vo/UserVO.java`

- [ ] **Step 1: Create UserCreateDTO**

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

- [ ] **Step 2: Create UserUpdateDTO**

```java
@Data
public class UserUpdateDTO {
    @Size(min = 2, max = 50, message = "用户名长度2-50字符")
    private String username;

    @Email(message = "邮箱格式不正确")
    private String email;
}
```

- [ ] **Step 3: Create UserQueryDTO**

```java
@Data
public class UserQueryDTO {
    private String username;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
```

- [ ] **Step 4: Create UserVO**

```java
@Data
public class UserVO {
    private Long id;
    private String username;
    private String email;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
```

- [ ] **Step 5: Commit**

```bash
git add src/main/java/com/example/module/user/dto/
git add src/main/java/com/example/module/user/vo/
git commit -m "feat(user): add DTOs and VOs"
```

### Task 2: Create User Entity with Audit Fields

**Files:**
- Create: `src/main/java/com/example/module/user/entity/User.java`
- Create: `src/test/java/com/example/module/user/entity/UserTest.java`

- [ ] **Step 1: Write the failing test**

```java
class UserTest {
    @Test
    void shouldHaveAuditFields() {
        User user = new User();

        assertDoesNotThrow(() -> user.getClass().getDeclaredField("id"));
        assertDoesNotThrow(() -> user.getClass().getDeclaredField("createBy"));
        assertDoesNotThrow(() -> user.getClass().getDeclaredField("createTime"));
        assertDoesNotThrow(() -> user.getClass().getDeclaredField("updateBy"));
        assertDoesNotThrow(() -> user.getClass().getDeclaredField("updateTime"));
        assertDoesNotThrow(() -> user.getClass().getDeclaredField("isDel"));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mvn test -Dtest=UserTest`
Expected: FAIL with "Cannot resolve symbol 'User'"

- [ ] **Step 3: Create User Entity**

```java
@Data
@TableName("t_user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String email;

    private String password;

    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer isDel;
}
```

- [ ] **Step 4: Verify audit fields in Entity**

Check that Entity includes:
- [x] `@TableName("t_user")` annotation
- [x] `@TableId(type = IdType.AUTO)` for id field
- [x] `@TableField(fill = FieldFill.INSERT)` for createBy, createTime
- [x] `@TableField(fill = FieldFill.INSERT_UPDATE)` for updateBy, updateTime
- [x] `@TableLogic` for isDel field

- [ ] **Step 5: Run test to verify it passes**

Run: `mvn test -Dtest=UserTest`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add src/main/java/com/example/module/user/entity/
git add src/test/java/com/example/module/user/entity/
git commit -m "feat(user): add User entity with audit fields"
```

---

## Chunk 2: Service Layer

### Task 3: Create UserMapper

**Files:**
- Create: `src/main/java/com/example/module/user/mapper/UserMapper.java`

- [ ] **Step 1: Create UserMapper**

```java
@Mapper
public interface UserMapper extends BaseMapper<User> {
    // BaseMapper provides:
    // - insert(User entity)
    // - deleteById(Serializable id)
    // - updateById(User entity)
    // - selectById(Serializable id)
    // - selectList(Wrapper<User> wrapper)
    // - selectPage(Page<User> page, Wrapper<User> wrapper)
}
```

- [ ] **Step 2: Commit**

```bash
git add src/main/java/com/example/module/user/mapper/
git commit -m "feat(user): add UserMapper"
```

### Task 4: Create UserService

**Files:**
- Create: `src/main/java/com/example/module/user/service/UserService.java`
- Create: `src/main/java/com/example/module/user/service/impl/UserServiceImpl.java`
- Create: `src/test/java/com/example/module/user/service/UserServiceTest.java`

[... 详细步骤省略 ...]

---

## Chunk 3: Controller Layer

### Task 5: Create UserController

**Files:**
- Create: `src/main/java/com/example/module/user/controller/UserController.java`
- Create: `src/test/java/com/example/module/user/controller/UserControllerTest.java`

[... 详细步骤省略 ...]

---

## Chunk 4: Integration and Verification

### Task 6: Run Full Test Suite

- [ ] **Step 1: Run all tests**

Run: `mvn clean test`
Expected: All tests PASS

- [ ] **Step 2: Run compile verification**

Run: `mvn clean compile`
Expected: BUILD SUCCESS

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "feat(user): complete user management module"
```
```

---

## 五、关键原则总结

| 原则 | 说明 |
|------|------|
| **精确文件路径** | 始终提供完整的文件路径 |
| **完整代码** | 计划中包含完整代码，不是"添加验证"等描述 |
| **精确命令** | 提供完整的 Maven 命令和预期输出 |
| **TDD 流程** | 每个功能遵循 RED-GREEN-REFACTOR |
| **频繁提交** | 每个任务完成后提交 |
| **自顶向下** | Controller → DTO/VO → Service → Mapper → Entity |
| **审计字段验证** | Entity 创建时强制检查审计字段 |
| **分块编写** | 每块 ≤ 1000 行，便于审查 |

---

## 六、常见问题处理

### Q1: 任务之间有依赖怎么办？

**处理：** 确保任务顺序正确，前置任务先完成

```
Task 1: DTO/VO（无依赖）
Task 2: Entity（无依赖）
Task 3: Mapper（依赖 Task 2）
Task 4: Service（依赖 Task 1, 2, 3）
Task 5: Controller（依赖 Task 4）
```

### Q2: 代码示例太长怎么办？

**处理：** 可以简化但必须完整可编译

```
✅ 正确：提供完整但简化的代码
❌ 错误："添加验证逻辑"
```

### Q3: 审计字段不需要怎么办？

**处理：** 在计划中明确说明原因

```markdown
- [ ] **Verify audit fields in Entity**

> Note: This entity does not include standard audit fields because it's a read-only reference table that doesn't require tracking.
```

### Q4: 计划审查超过 5 次迭代？

**处理：**
1. 停止自动审查
2. 向用户报告问题
3. 请求用户介入指导