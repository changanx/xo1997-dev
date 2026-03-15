# xo1997-dev 插件定制修改清单

> 目标：适配 Spring Boot 2.7.18 + MyBatis-Plus 3.5.7 后端项目

---

## 一、brainstorming 技能修改

### 1.1 新增：数据库表结构设计讨论
- **讨论阶段**：brainstorming 阶段进行表结构设计讨论
- **确认阶段**：writing-plans 阶段完成确认并写入文档
- **文档位置**：`docs/database/表结构设计.md`
- **优化方式**：开发过程中持续优化，考虑性能问题
- **状态**：✅ 已确认

**讨论内容：**

- 表名、字段、类型、约束
- 索引设计（查询优化）
- 表间关系（外键、关联关系）
- 统一审计字段：`create_by`, `create_time`, `update_by`, `update_time`, `is_del`

---

## 二、test-driven-development 技能修改

### 1.1 测试示例语言
- **当前**：TypeScript
- **修改为**：Java
- **状态**：✅ 已确认

### 1.2 测试框架
- **当前**：Jest
- **修改为**：JUnit 5 + Mockito
- **状态**：✅ 已确认

### 1.3 测试命令
- **当前**：`npm test path/to/test.test.ts`
- **修改为**：
  - 运行所有测试：`mvn test`
  - 运行单个测试类：`mvn test -Dtest=TestClassName`
  - 运行单个测试方法：`mvn test -Dtest=TestClassName#testMethodName`
- **状态**：✅ 已确认

### 1.4 代码示例替换
- **当前**：JavaScript async/await 示例
- **修改为**：Java + Spring Boot Test 示例（包含 Service 层和 Controller 层两种）
- **示例风格**：Given-When-Then (AAA) 模式
- **状态**：✅ 已确认

**Service 层单元测试示例：**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void shouldReturnUser_whenUserExists() {
        // Given
        User expected = new User(1L, "张三");
        when(userMapper.selectById(1L)).thenReturn(expected);

        // When
        User result = userService.getById(1L);

        // Then
        assertEquals("张三", result.getName());
        verify(userMapper).selectById(1L);
    }
}
```

**Controller 层测试示例：**
```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void shouldReturnUser_whenUserExists() throws Exception {
        // Given
        User user = new User(1L, "张三");
        when(userService.getById(1L)).thenReturn(user);

        // When & Then
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.name").value("张三"));
    }
}
```

### 1.5 Mock 示例
- **当前**：`jest.fn()`
- **修改为**：Mockito `@Mock`, `@InjectMocks`, `@Spy`
- **初始化方式**：统一使用 `@ExtendWith(MockitoExtension.class)`
- **状态**：✅ 已确认

**Mockito 常用模式：**

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void shouldReturnUser_whenUserExists() {
        // 定义 Mock 行为
        when(userMapper.selectById(1L)).thenReturn(new User(1L, "张三"));

        // 验证调用
        verify(userMapper).selectById(1L);
    }
}
```

**@Spy 部分模拟示例：**

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Spy
    @InjectMocks
    private UserServiceImpl userService;

    @Mock
    private UserMapper userMapper;

    @Test
    void shouldCallRealMethod_andMockDependency() {
        // 真实方法调用
        when(userService.generateUserId()).thenCallRealMethod();

        // 部分方法 Mock
        doReturn(new User(1L, "张三")).when(userMapper).selectById(1L);

        // 测试部分真实逻辑 + 部分 Mock 依赖
        User result = userService.createUser("张三");
        assertNotNull(result);
    }
}
```

**Mockito 常用方法速查：**

```java
// 返回值
when(mock.method()).thenReturn(value);
when(mock.method()).thenReturn(value1, value2); // 多次调用返回不同值
when(mock.method()).thenThrow(new RuntimeException());

// 无返回值方法
doNothing().when(mock).voidMethod();
doThrow(new RuntimeException()).when(mock).voidMethod();

// 参数匹配
when(mock.method(any())).thenReturn(value);
when(mock.method(eq("specific"))).thenReturn(value);
when(mock.method(anyString())).thenReturn(value);

// 验证
verify(mock).method();
verify(mock, times(2)).method();
verify(mock, never()).method();
verify(mock, atLeast(1)).method();
```

### 1.6 新增：Spring Boot Test 注解说明
- **新增内容**：
  - `@SpringBootTest` - 集成测试，加载完整 Spring 上下文
  - `@WebMvcTest` - Controller 层测试，只加载 Web 层组件
  - `@DataJpaTest` - JPA 测试（如使用 JPA 可选）
- **MyBatis-Plus 测试方式**：使用 `@SpringBootTest` + H2 内存数据库（不使用 @MybatisTest）
- **状态**：✅ 已确认

**测试注解使用示例：**

```java
// Controller 层测试
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;
}

// 集成测试（MyBatis-Plus）
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class UserMapperIntegrationTest {
    @Autowired
    private UserMapper userMapper;
}
```

**H2 内存数据库配置（test/resources/application.yml）：**
```yaml
spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=MySQL
    username: sa
    password:
  h2:
    console:
      enabled: false
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

### 1.7 新增：MyBatis-Plus 测试模式
- **测试方式**：`@SpringBootTest` + H2 内存数据库
- **数据初始化**：SQL 脚本 + 代码构建结合
- **H2 配置**：开启 `MODE=MySQL` 兼容模式
- **状态**：✅ 已确认

**集成测试示例：**

```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class UserMapperIntegrationTest {

    @Autowired
    private UserMapper userMapper;

    @Test
    @Order(1)
    void shouldInsertUser() {
        // Given - 代码构建数据
        User user = new User();
        user.setName("张三");

        // When
        int result = userMapper.insert(user);

        // Then
        assertEquals(1, result);
        assertNotNull(user.getId());
    }

    @Test
    @Order(2)
    void shouldSelectUserById() {
        // When
        User user = userMapper.selectById(1L);

        // Then
        assertNotNull(user);
        assertEquals("张三", user.getName());
    }
}
```

**H2 配置（test/resources/application.yml）：**
```yaml
spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=MySQL
    username: sa
    password:
  sql:
    init:
      mode: always
      schema-locations: classpath:schema.sql
      data-locations: classpath:data.sql
```

**SQL 脚本示例（test/resources/schema.sql）：**
```sql
CREATE TABLE IF NOT EXISTS user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**SQL 脚本示例（test/resources/data.sql）：**
```sql
INSERT INTO user (id, name) VALUES (1, '张三');
INSERT INTO user (id, name) VALUES (2, '李四');
```

### 1.8 保留内容
- **内容**：核心原则（RED-GREEN-REFACTOR）、测试反模式、验证清单
- **操作**：保持不变
- **状态**：确认保留

---

## 三、writing-plans 技能修改

### 2.1 任务文件结构模板
- **当前**：Python 文件示例
- **修改为**：Spring Boot 模块化分层结构示例
- **包结构规范**：按模块划分，每个模块下包含 controller/service/mapper/entity/dto/vo/constants/util/exception/enums
- **公共组件**：统一异常处理、统一响应格式放在 common 目录，定时任务放在 schedule 目录
- **状态**：✅ 已确认

**项目包结构示例：**
```
src/main/java/com/example/
├── common/                          # 公共组件
│   ├── exception/                   # 统一异常处理
│   │   ├── GlobalExceptionHandler.java
│   │   └── BusinessException.java
│   └── result/                      # 统一响应格式
│       └── Result.java
├── schedule/                        # 定时任务
│   └── ScheduleTask.java
├── module/                          # 业务模块
│   ├── user/                        # 用户模块
│   │   ├── controller/
│   │   │   └── UserController.java
│   │   ├── service/
│   │   │   ├── UserService.java
│   │   │   └── impl/
│   │   │       └── UserServiceImpl.java
│   │   ├── mapper/
│   │   │   └── UserMapper.java
│   │   ├── entity/
│   │   │   └── User.java
│   │   ├── dto/
│   │   │   └── UserCreateDTO.java
│   │   ├── vo/
│   │   │   └── UserVO.java
│   │   ├── constants/
│   │   │   └── UserConstants.java
│   │   └── enums/
│   │       └── UserStatus.java
│   └── video/                       # 视频模块
│       └── ...
└── Application.java
```

**计划任务模板示例：**

```markdown
### Task N: 新增用户查询接口

**Files:**
- Create: `src/main/java/com/example/module/user/entity/User.java`
- Create: `src/main/java/com/example/module/user/mapper/UserMapper.java`
- Create: `src/main/java/com/example/module/user/service/UserService.java`
- Create: `src/main/java/com/example/module/user/service/impl/UserServiceImpl.java`
- Create: `src/main/java/com/example/module/user/controller/UserController.java`
- Create: `src/main/java/com/example/module/user/dto/UserQueryDTO.java`
- Create: `src/main/java/com/example/module/user/vo/UserVO.java`
- Create: `src/test/java/com/example/module/user/service/UserServiceTest.java`
```

### 2.2 文件路径格式
- **当前**：`exact/path/to/file.py`
- **修改为**：`src/main/java/com/xxx/controller/XxxController.java`
- **状态**：待讨论

### 2.3 测试路径格式
- **当前**：`tests/path/to/test.py`
- **修改为**：`src/test/java/com/xxx/XxxTest.java`
- **状态**：待讨论

### 2.4 新增：Spring Boot 标准文件创建清单
- **创建顺序**：自顶向下（Controller -> DTO/VO -> Service -> Mapper -> Entity）
- **表结构设计**：
  - 讨论阶段：brainstorming 阶段讨论表结构设计
  - 确认阶段：writing-plans 阶段完成确认
  - 文档位置：`docs/database/表结构设计.md`
- **表结构优化**：开发过程中持续优化，需要考虑性能问题
- **状态**：✅ 已确认

**自顶向下创建顺序示例：**

```markdown
### Task N: 新增订单模块

**Files:**
- Create: `docs/database/表结构设计.md`（更新订单表设计）
- Create: `src/main/java/com/example/module/order/controller/OrderController.java`
- Create: `src/main/java/com/example/module/order/dto/OrderCreateDTO.java`
- Create: `src/main/java/com/example/module/order/dto/OrderQueryDTO.java`
- Create: `src/main/java/com/example/module/order/vo/OrderVO.java`
- Create: `src/main/java/com/example/module/order/service/OrderService.java`
- Create: `src/main/java/com/example/module/order/service/impl/OrderServiceImpl.java`
- Create: `src/main/java/com/example/module/order/mapper/OrderMapper.java`
- Create: `src/main/java/com/example/module/order/entity/Order.java`
- Create: `src/test/java/com/example/module/order/service/OrderServiceTest.java`
```

**表结构设计文档模板（docs/database/表结构设计.md）：**

```markdown
## 订单表 (t_order)

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
|--------|------|----------|--------|------|
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| order_no | VARCHAR(32) | NOT NULL | - | 订单编号 |
| user_id | BIGINT | NOT NULL | - | 用户ID |
| total_amount | DECIMAL(10,2) | NOT NULL | - | 订单总金额 |
| status | TINYINT | NOT NULL | 0 | 订单状态 |
| create_time | DATETIME | NOT NULL | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | NOT NULL | CURRENT_TIMESTAMP | 更新时间 |

**索引设计：**
- PRIMARY KEY (id)
- UNIQUE KEY uk_order_no (order_no)
- KEY idx_user_id (user_id)
- KEY idx_create_time (create_time)

**性能优化考虑：**
- 订单编号使用唯一索引，支持快速查询
- user_id 建立索引，支持用户订单列表查询
- create_time 建立索引，支持时间范围查询
```

### 2.5 新增：实体设计规范
- **Entity/DTO/VO 职责分离**：
  - Entity：数据库映射，不直接暴露给前端
  - DTO：接收请求参数
  - VO：返回响应数据
- **字段拷贝工具**：MapStruct
- **状态**：✅ 已确认

**统一数据库字段规范（表结构设计必须包含）：**

| 字段名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| create_by | VARCHAR(30) | - | 创建人 |
| create_time | DATETIME | CURRENT_TIMESTAMP | 创建时间 |
| update_by | VARCHAR(30) | - | 更新人 |
| update_time | DATETIME | CURRENT_TIMESTAMP | 更新时间 |
| is_del | TINYINT(1) | 0 | 逻辑删除(0:未删除,1:删除) |

**Entity 示例：**

```java
@TableName("t_order")
public class Order {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String orderNo;
    private Long userId;
    private BigDecimal totalAmount;

    // 统一审计字段 - 自动填充
    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    // 逻辑删除
    @TableLogic
    private Integer isDel;
}
```

**枚举处理示例：**

```java
public enum OrderStatus {
    PENDING(0, "待支付"),
    PAID(1, "已支付"),
    CANCELLED(2, "已取消");

    @EnumValue
    private final Integer code;
    private final String desc;
}
```

**MapStruct 使用示例：**

```java
@Mapper(componentModel = "spring")
public interface OrderMapper {
    OrderVO toVO(Order order);
    Order toEntity(OrderCreateDTO dto);
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity(OrderUpdateDTO dto, @MappingTarget Order order);
}
```

### 2.6 保留内容
- **内容**：任务粒度要求、计划文档头格式、评审循环流程
- **操作**：保持不变
- **状态**：确认保留

---

## 四、verification-before-completion 技能修改

### 3.1 验证命令
- **当前**：`npm test`, `npm run build`
- **修改为**：
  - 测试验证：`mvn clean test`
  - 编译验证：`mvn clean compile`
- **状态**：✅ 已确认

### 3.2 打包验证（可选）
- **命令**：`mvn clean package -DskipTests`
- **说明**：到达此步骤时询问用户选择：
  - A. 打包验证（自动执行 `mvn clean package -DskipTests`）
  - B. 自行验证（用户手动验证）
- **状态**：✅ 已确认

### 3.3 保留内容
- **内容**：验证原则、验证清单结构
- **操作**：保持不变
- **状态**：确认保留

---

## 五、systematic-debugging 技能修改

### 4.1 新增：Spring Boot 日志调试
- **区分项目类型**：
  - 新项目：补充完整日志输出格式配置
  - 存量项目（添加/修改模块）：提示用户检查当前日志配置是否有问题
- **状态**：✅ 已确认

**新项目日志配置（application.yml）：**

```yaml
logging:
  level:
    root: INFO
    com.example: DEBUG                    # 项目包日志级别
    org.springframework.web: DEBUG        # Spring Web 日志
    org.mybatis: DEBUG                    # MyBatis 日志
    com.baomidou.mybatisplus: DEBUG       # MyBatis-Plus 日志
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n"
  file:
    name: logs/application.log
    max-size: 10MB
    max-history: 30
```

**存量项目调试提示：**

在调试存量项目时，提示用户检查：
1. 当前日志级别是否足够输出调试信息？
2. 是否需要临时调整特定包的日志级别？
3. 调试完成后是否需要恢复日志配置？

```yaml
# 调试时临时调整（调试完成后记得恢复）
logging:
  level:
    com.example.module.xxx: DEBUG         # 仅针对调试模块
```

### 4.2 新增：常见问题排查
- **包含内容**：详细排查步骤说明
- **常见问题列表**：本次先列出基础问题，后续可补充
- **状态**：✅ 已确认

**常见问题排查手册：**

#### 问题1：Bean 注入失败 - `NoSuchBeanDefinitionException`

**排查步骤：**
1. 检查类是否添加了 Spring 注解（@Component, @Service, @Repository, @Controller）
2. 检查包扫描路径是否包含该类所在包（@ComponentScan 或 @SpringBootApplication scanBasePackages）
3. 检查是否使用了条件注解导致 Bean 未创建（@ConditionalOnProperty, @ConditionalOnClass 等）
4. 检查是否有循环依赖问题

```java
// 调试命令：查看所有已注册的 Bean
// Actuator 端点：/actuator/beans
```

#### 问题2：事务不生效

**排查步骤：**
1. 检查方法是否为 public（@Transactional 默认只对 public 生效）
2. 检查是否在同一个类内部调用（绕过了代理，事务失效）
3. 检查异常类型是否被回滚（默认只回滚 RuntimeException 和 Error）
4. 检查数据库引擎是否支持事务（MySQL 使用 InnoDB）
5. 检查是否有嵌套事务配置问题

```java
// 解决方案示例

// 问题：类内部调用导致事务失效
@Service
public class OrderService {
    public void processOrder() {
        this.createOrder();  // 事务失效
    }

    @Transactional
    public void createOrder() { }
}

// 解决方案1：注入自己
@Service
public class OrderService {
    @Autowired
    private OrderService self;

    public void processOrder() {
        self.createOrder();  // 事务生效
    }
}

// 解决方案2：指定回滚异常类型
@Transactional(rollbackFor = Exception.class)
```

#### 问题3：MyBatis SQL 绑定失败 - `BindingException`

**排查步骤：**
1. 检查 Mapper 接口方法名与 XML 中 SQL id 是否一致
2. 检查 Mapper 接口包路径与 XML namespace 是否一致
3. 检查 XML 文件位置是否在 resources 目录下且路径正确
4. 检查 mybatis.mapper-locations 配置是否正确
5. 检查方法参数是否使用 @Param 注解

```yaml
# 配置检查
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
```

#### 问题4：MyBatis 参数映射错误 - `TypeException`

**排查步骤：**
1. 检查参数类型是否匹配
2. 检查多参数方法是否使用 @Param 注解
3. 检查实体类字段类型与数据库字段类型是否匹配
4. 检查是否使用了正确的参数引用方式（#{param} vs ${param}）

```java
// 正确的多参数写法
List<User> selectByNameAndAge(@Param("name") String name, @Param("age") Integer age);

// XML 中引用
// SELECT * FROM user WHERE name = #{name} AND age = #{age}
```

#### 问题5：数据库连接异常

**排查步骤：**
1. 检查数据库服务是否启动
2. 检查连接配置是否正确（url, username, password）
3. 检查网络连通性（防火墙、端口）
4. 检查连接池配置（最大连接数、超时时间）
5. 检查数据库用户权限

```yaml
# 连接池调试配置
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

**（后续可补充更多常见问题...）**

### 4.3 新增：Actuator 端点使用
- **启用情况**：部分项目已启用，部分项目未启用（不考虑启用）
- **常用端点**：health、beans、mappings、env
- **安全配置**：生产环境仅开放 health、info，保证安全性
- **状态**：✅ 已确认

**Actuator 安全配置：**

```yaml
# application.yml - 开发环境
management:
  endpoints:
    web:
      exposure:
        include: health,info,beans,mappings,env
  endpoint:
    health:
      show-details: always

---
# application-prod.yml - 生产环境
management:
  endpoints:
    web:
      exposure:
        include: health,info    # 仅开放 health 和 info
  endpoint:
    health:
      show-details: never       # 不显示详细信息
```

**常用端点说明：**

| 端点 | 用途 | 使用场景 |
|------|------|----------|
| `/actuator/health` | 健康检查 | 查看应用和组件健康状态，排查启动问题 |
| `/actuator/beans` | Bean 列表 | 排查 Bean 注入问题，查看已注册的 Bean |
| `/actuator/mappings` | 路由映射 | 排查接口映射问题，查看所有 URL 映射关系 |
| `/actuator/env` | 环境变量 | 排查配置问题，查看当前生效的配置属性 |
| `/actuator/info` | 应用信息 | 查看应用基本信息（生产环境可用） |

**调试时使用示例：**

```bash
# 查看 Bean 是否注册
curl http://localhost:8080/actuator/beans | grep userService

# 查看接口映射
curl http://localhost:8080/actuator/mappings | grep /api/users

# 查看配置属性
curl http://localhost:8080/actuator/env | grep datasource
```

**注意**：对于未启用 Actuator 的项目，使用日志和断点进行调试。

### 4.4 保留内容
- **内容**：根因追踪方法论、防御性调试、条件等待模式
- **操作**：保持不变
- **状态**：确认保留

---

## 六、code-reviewer agent 修改

### 5.1 新增：分层架构审查
- **审查维度**：业务逻辑、数据库操作、HTTP相关、参数校验、事务控制、实体对象使用、异常处理、接口日志、工具类调用
- **状态**：✅ 已确认

**分层架构审查清单：**

| 审查项 | Controller | Service | Mapper |
|--------|------------|---------|--------|
| 业务逻辑 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| 数据库操作 | ❌ 禁止 | ✅ 通过 Mapper | ✅ 允许 |
| HTTP 相关代码 | ✅ 允许 | ❌ 禁止 | ❌ 禁止 |
| 参数校验 | ✅ 允许（Validator） | ✅ 允许（业务校验） | ❌ 禁止 |
| 事务控制 | ❌ 禁止 | ✅ 允许 | ❌ 禁止 |
| **实体对象使用** | DTO/VO（禁止 Entity） | Entity（允许） | Entity（仅允许） |
| **异常处理** | 统一捕获封装响应 | 抛出业务异常 | 禁止处理和抛出 |
| **接口日志** | ✅ 允许 | ❌ 禁止 | ❌ 禁止 |
| **工具类调用** | 少量允许 | ✅ 允许 | ❌ 禁止 |

**详细说明：**

#### 1. 实体对象使用规范
- **Controller 层**：仅允许使用 DTO（接收请求参数）和 VO（返回响应数据），禁止直接使用 Entity
- **Service 层**：可接收和返回 Entity，用于业务逻辑处理
- **Mapper 层**：仅允许操作 Entity，实现与数据库的映射

```java
// ✅ 正确：Controller 使用 DTO/VO
@PostMapping
public Result<UserVO> create(@RequestBody @Valid UserCreateDTO dto) {
    return Result.success(userService.create(dto));
}

// ❌ 错误：Controller 直接使用 Entity
@PostMapping
public Result<User> create(@RequestBody User user) {
    return Result.success(userService.save(user));
}
```

#### 2. 异常处理规范
- **Controller 层**：负责统一捕获各类异常，封装成规范响应返回给前端，禁止直接抛出未处理异常
- **Service 层**：可根据业务逻辑抛出对应的业务异常，由 Controller 层统一处理
- **Mapper 层**：禁止处理和抛出异常，异常由上层 Service 或 Controller 统一捕获

```java
// ✅ 正确：Service 抛出业务异常
public void delete(Long id) {
    User user = userMapper.selectById(id);
    if (user == null) {
        throw new BusinessException("用户不存在");
    }
    userMapper.deleteById(id);
}

// ✅ 正确：Controller 统一异常处理（GlobalExceptionHandler）
@ExceptionHandler(BusinessException.class)
public Result<Void> handleBusinessException(BusinessException e) {
    return Result.fail(e.getCode(), e.getMessage());
}
```

#### 3. 接口日志规范
- **Controller 层**：允许打印接口相关日志（如请求路径、请求参数、响应结果等），方便接口调试和问题排查
- **Service 层和 Mapper 层**：禁止打印接口日志，避免日志冗余和业务逻辑与日志代码耦合

```java
// ✅ 正确：Controller 打印接口日志
@Slf4j
@RestController
public class UserController {
    @PostMapping("/users")
    public Result<UserVO> create(@RequestBody UserCreateDTO dto) {
        log.info("创建用户请求，参数：{}", dto);
        UserVO result = userService.create(dto);
        log.info("创建用户成功，结果：{}", result);
        return Result.success(result);
    }
}

// ❌ 错误：Service 打印接口日志
public UserVO create(UserCreateDTO dto) {
    log.info("创建用户请求，参数：{}", dto);  // 禁止
    // ...
}
```

#### 4. 工具类调用规范
- **Controller 层**：可少量调用工具类（如参数格式化、简单加密等），不可过多依赖工具类
- **Service 层**：允许正常调用各类工具类，支撑业务逻辑实现
- **Mapper 层**：禁止调用任何工具类，仅专注于数据库 CRUD 操作

```java
// ✅ 正确：Controller 少量调用工具类
@GetMapping("/users/{id}")
public Result<UserVO> getById(@PathVariable Long id) {
    return Result.success(userService.getById(id));
}

@PostMapping("/users/export")
public void export(HttpServletResponse response) {
    ExcelUtils.setResponseHeader(response, "用户列表");  // 少量允许
    userService.exportUsers(response);
}

// ❌ 错误：Mapper 调用工具类
public interface UserMapper extends BaseMapper<User> {
    default void customMethod() {
        String value = StringUtils.trim("test");  // 禁止
    }
}
```

### 5.2 新增：MyBatis-Plus 规范审查
- **审查维度**：Entity 注解、Mapper 接口、条件构造器、分页查询、逻辑删除
- **状态**：✅ 已确认

**MyBatis-Plus 规范审查清单：**

| 审查项 | 规范要求 |
|--------|----------|
| Entity 注解 | `@TableName`、`@TableId`、`@TableField`、`@TableLogic` 使用正确 |
| Mapper 接口 | 正确继承 `BaseMapper<T>`，泛型为对应 Entity |
| 条件构造器 | 使用 `LambdaQueryWrapper`/`LambdaUpdateWrapper`，避免硬编码字段名 |
| 分页查询 | 使用 `Page<T>` 对象，配置分页插件 |
| 逻辑删除 | Entity 配置 `@TableLogic`，全局配置逻辑删除值 |

**正确示例：**

```java
// ✅ Entity 注解使用正确
@TableName("t_user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    @TableField("email")
    private String userEmail;

    @TableLogic
    private Integer isDel;
}

// ✅ Mapper 接口正确继承
public interface UserMapper extends BaseMapper<User> {
    // 自定义方法（如需要）
}

// ✅ 条件构造器使用 Lambda（避免硬编码字段名）
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.eq(User::getName, "张三")
       .orderByDesc(User::getCreateTime);

// ❌ 错误：硬编码字段名
QueryWrapper<User> wrapper = new QueryWrapper<>();
wrapper.eq("name", "张三");  // 字段名硬编码，容易出错

// ✅ 分页查询
Page<User> page = new Page<>(pageNum, pageSize);
userMapper.selectPage(page, wrapper);

// ✅ 全局逻辑删除配置（application.yml）
mybatis-plus:
  global-config:
    db-config:
      logic-delete-field: isDel
      logic-delete-value: 1
      logic-not-delete-value: 0
```

### 5.3 新增：事务管理审查
- **审查维度**：@Transactional 位置、事务传播行为、避免大事务、只读事务、异常回滚
- **状态**：✅ 已确认

**事务管理审查清单：**

| 审查项 | 规范要求 |
|--------|----------|
| @Transactional 位置 | 放在 Service 层方法或类上，不应放在 Controller 或 Mapper |
| 事务传播行为 | 默认 REQUIRED，了解其他传播行为的使用场景 |
| 避免大事务 | 单个事务方法不宜过长，避免包含远程调用、文件操作等耗时操作 |
| 只读事务 | 查询方法使用 `@Transactional(readOnly = true)` 优化性能 |
| 异常回滚 | 默认只回滚 RuntimeException，需回滚其他异常需配置 `rollbackFor` |

**正确示例：**

```java
// ✅ 写操作事务
@Service
public class OrderServiceImpl implements OrderService {

    @Transactional(rollbackFor = Exception.class)
    public void createOrder(OrderCreateDTO dto) {
        // 业务逻辑
    }
}

// ✅ 只读事务优化查询性能
@Transactional(readOnly = true)
public List<OrderVO> listOrders(Long userId) {
    return orderMapper.selectList(
        new LambdaQueryWrapper<Order>().eq(Order::getUserId, userId)
    );
}

// ❌ 错误：大事务包含远程调用
@Transactional
public void createOrder(OrderCreateDTO dto) {
    // 数据库操作
    orderMapper.insert(order);

    // ❌ 远程调用不应放在事务内
    paymentService.remoteCall(dto);

    // ❌ 文件操作不应放在事务内
    fileService.writeFile(file);
}

// ✅ 正确：拆分事务，避免大事务
public void createOrder(OrderCreateDTO dto) {
    // 事务方法：仅包含数据库操作
    saveOrderInTransaction(order);

    // 非事务操作：远程调用、文件操作
    paymentService.remoteCall(dto);
    fileService.writeFile(file);
}

@Transactional(rollbackFor = Exception.class)
public void saveOrderInTransaction(Order order) {
    orderMapper.insert(order);
}
```

**事务传播行为说明：**

| 传播行为 | 说明 | 使用场景 |
|----------|------|----------|
| REQUIRED（默认） | 有事务就加入，没有就新建 | 大多数场景 |
| REQUIRES_NEW | 总是新建事务，挂起当前事务 | 独立日志记录、独立子任务 |
| NESTED | 嵌套事务，可独立回滚 | 子任务可独立失败 |
| SUPPORTS | 有事务就加入，没有就非事务执行 | 查询方法 |
| NOT_SUPPORTED | 非事务执行，挂起当前事务 | 避免长事务 |
| NEVER | 非事务执行，有事务则抛异常 | 强制非事务 |
| MANDATORY | 必须在事务中执行，否则抛异常 | 强制事务 |

### 5.4 新增：API 规范审查
- **审查维度**：RESTful 风格、URL 命名、统一响应格式、异常处理、参数校验
- **参考技能**：springboot-unified-response（统一响应格式详细设计）
- **状态**：✅ 已确认

**API 规范审查清单：**

| 审查项 | 规范要求 |
|--------|----------|
| RESTful 风格 | 遵循 REST 规范，正确使用 HTTP 方法（GET 查询、POST 新增、PUT 修改、DELETE 删除） |
| URL 命名 | 使用小写字母、连字符分隔、名词复数形式（如 `/api/users`、`/api/order-items`） |
| 统一响应格式 | 所有接口返回统一的 `Result<T>` 格式 |
| 异常处理 | 使用全局异常处理 + 分类业务异常，不直接返回错误信息 |
| 参数校验 | 使用 `@Valid`/`@Validated` + Bean Validation 注解 |

**统一响应格式 Result<T>：**

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| code | int | 状态码 |
| message | String | 响应消息 |
| data | T | 响应数据 |

**错误码规范：**

| 错误码 | 说明 | 对应异常类 |
|--------|------|-----------|
| 200 | 成功 | - |
| 400 | 参数错误 | BadRequestException |
| 403 | 禁止访问 | ForbiddenException |
| 404 | 资源不存在 | NotFoundException |
| 500 | 服务器内部错误 | Exception |

**分类业务异常：**

```java
// 基础业务异常
public class BusinessException extends RuntimeException {
    private final int code;
    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}

// 400 参数错误
public class BadRequestException extends BusinessException {
    public BadRequestException(String message) {
        super(400, message);
    }
}

// 404 资源不存在
public class NotFoundException extends BusinessException {
    public NotFoundException(String message) {
        super(404, message);
    }
}

// 403 禁止访问
public class ForbiddenException extends BusinessException {
    public ForbiddenException(String message) {
        super(403, message);
    }
}
```

**全局异常处理：**

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        return Result.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<?> handleValidation(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return Result.badRequest(message);
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        return Result.error(500, "服务器内部错误");
    }
}
```

**RESTful API 示例：**

```java
// ✅ 正确：RESTful 风格
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public Result<List<UserVO>> list() { }

    @GetMapping("/{id}")
    public Result<UserVO> getById(@PathVariable Long id) { }

    @PostMapping
    public Result<UserVO> create(@RequestBody @Valid UserCreateDTO dto) { }

    @PutMapping("/{id}")
    public Result<UserVO> update(@PathVariable Long id, @RequestBody @Valid UserUpdateDTO dto) { }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) { }
}

// ❌ 错误：非 RESTful 风格
@GetMapping("/getUserById")
public User getUserById(@RequestParam Long id) { }

@PostMapping("/deleteUser")
public void deleteUser(@RequestBody Map<String, Long> params) { }
```

### 5.5 保留内容
- **内容**：通用代码质量审查标准
- **操作**：保持不变
- **状态**：确认保留

---

## 七、新增技能文件

### 6.1 springboot-best-practices/SKILL.md
- **内容概要**：
  - 分层架构规范（引用 5.1 内容）
  - 核心注解使用规范
  - 依赖注入规范
  - 配置管理规范
  - 异常处理规范
  - 参数校验规范
- **状态**：✅ 已确认

**核心注解使用规范：**

| 注解 | 使用场景 | 规范要求 |
|------|----------|----------|
| `@RestController` | Controller 层类 | 组合注解（@Controller + @ResponseBody），用于 RESTful API |
| `@Service` | Service 层类 | 标注业务服务类，便于 Spring 扫描和事务管理 |
| `@Autowired` | 依赖注入 | 推荐使用构造器注入，避免字段注入 |
| `@Valid` / `@Validated` | 参数校验 | Controller 方法参数校验，配合 Bean Validation 注解 |
| `@Transactional` | 事务管理 | 仅用于 Service 层，禁止在 Controller/Mapper 使用 |

**注解使用示例：**

```java
// ✅ 正确：构造器注入（推荐）
@Service
@RequiredArgsConstructor  // Lombok 生成构造器
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final OrderService orderService;

    // 无需 @Autowired，Spring 4.3+ 单构造器自动注入
}

// ✅ 正确：多构造器时使用 @Autowired
@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    @Autowired
    public UserServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }
}

// ❌ 错误：字段注入（不推荐）
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;  // 难以测试，隐藏依赖关系
}
```

**注解使用禁止项：**

```java
// ❌ 禁止：在 Controller 使用 @Transactional
@RestController
public class UserController {
    @Transactional  // 错误：事务应在 Service 层
    @PostMapping("/users")
    public Result<UserVO> create(@RequestBody UserCreateDTO dto) { }
}

// ❌ 禁止：滥用 @Autowired 在非必需依赖上
// 如果依赖是可选的，使用 @Autowired(required = false)

// ❌ 禁止：在 Mapper 接口使用 @Service 或 @Component
@Mapper
@Service  // 错误：Mapper 已由 MyBatis 管理
public interface UserMapper extends BaseMapper<User> { }

// ❌ 禁止：嵌套过深的 @Valid
// DTO 中的嵌套对象校验使用 @Valid，但避免过度嵌套
```

**配置管理规范：**

```yaml
# 多环境配置
# application.yml - 公共配置
# application-dev.yml - 开发环境
# application-prod.yml - 生产环境

# 启动指定环境
# java -jar app.jar --spring.profiles.active=prod
```

**参数校验注解：**

| 注解 | 说明 |
|------|------|
| `@NotNull` | 不能为 null |
| `@NotBlank` | 字符串不能为空（至少一个非空白字符） |
| `@Size(min, max)` | 字符串/集合长度范围 |
| `@Min(value)` / `@Max(value)` | 数值最小/最大值 |
| `@Pattern(regexp)` | 正则表达式匹配 |
| `@Email` | 邮箱格式 |

```java
@Data
public class UserCreateDTO {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 2, max = 20, message = "用户名长度2-20字符")
    private String name;

    @NotNull(message = "年龄不能为空")
    @Min(value = 0, message = "年龄不能小于0")
    private Integer age;

    @Email(message = "邮箱格式不正确")
    private String email;
}
```

### 6.2 mybatis-plus-patterns/SKILL.md
- **内容概要**：
  - Entity 设计规范（引用 2.5 内容）
  - Mapper 接口规范（引用 5.2 内容）
  - 条件构造器使用（引用 5.2 内容）
  - 分页查询规范（引用 5.2 内容）
  - 逻辑删除配置（引用 2.5 内容）
  - 自定义 SQL 方法规范（新增）
- **状态**：✅ 已确认

**自定义 SQL 方法规范：**

**优先级**：XML 自定义 SQL > 注解 SQL > MyBatis-Plus 原生方法

#### 1. XML 自定义 SQL（推荐）

```java
// Mapper 接口
public interface UserMapper extends BaseMapper<User> {

    // 自定义方法
    List<UserVO> selectUsersByCondition(@Param("dto") UserQueryDTO dto);

    int batchInsert(@Param("list") List<User> users);
}
```

```xml
<!-- resources/mapper/UserMapper.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.example.module.user.mapper.UserMapper">

    <select id="selectUsersByCondition" resultType="com.example.module.user.vo.UserVO">
        SELECT id, name, email, create_time
        FROM t_user
        WHERE is_del = 0
        <if test="dto.name != null and dto.name != ''">
            AND name LIKE CONCAT('%', #{dto.name}, '%')
        </if>
        <if test="dto.status != null">
            AND status = #{dto.status}
        </if>
        ORDER BY create_time DESC
    </select>

    <insert id="batchInsert">
        INSERT INTO t_user (name, email, create_by, create_time)
        VALUES
        <foreach collection="list" item="user" separator=",">
            (#{user.name}, #{user.email}, #{user.createBy}, #{user.createTime})
        </foreach>
    </insert>
</mapper>
```

#### 2. 注解 SQL（简单场景可用）

```java
// 仅适用于简单 SQL，复杂 SQL 仍使用 XML
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM t_user WHERE email = #{email} AND is_del = 0")
    User selectByEmail(@Param("email") String email);

    @Update("UPDATE t_user SET status = #{status} WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
```

#### 3. 与原生方法共存规则

```java
// ✅ 正确：继承 BaseMapper 获得原生方法，同时定义自定义方法
public interface UserMapper extends BaseMapper<User> {

    // 原生方法（自动生成）：
    // - insert(User entity)
    // - deleteById(Serializable id)
    // - updateById(User entity)
    // - selectById(Serializable id)
    // - selectList(Wrapper<User> queryWrapper)
    // - selectPage(Page<User> page, Wrapper<User> queryWrapper)
    // ... 等

    // 自定义方法（XML 或注解）：
    List<UserVO> selectUsersByCondition(@Param("dto") UserQueryDTO dto);
}

// ❌ 错误：自定义方法名与原生方法冲突
public interface UserMapper extends BaseMapper<User> {

    // 错误：insert 是原生方法，不能覆盖
    int insert(User user);

    // 正确：使用不同的方法名
    int insertBatch(@Param("list") List<User> users);
}
```

#### 4. 参数规范

```java
// ✅ 单参数使用 @Param
User selectByEmail(@Param("email") String email);

// ✅ 多参数必须使用 @Param
List<User> selectByNameAndStatus(
    @Param("name") String name,
    @Param("status") Integer status
);

// ✅ DTO 对象作为参数
List<UserVO> selectUsersByCondition(@Param("dto") UserQueryDTO dto);

// ✅ 集合参数
int batchInsert(@Param("list") List<User> users);

// ❌ 错误：多参数未使用 @Param
List<User> selectByNameAndStatus(String name, Integer status);  // MyBatis 无法识别参数名
```

#### 5. 返回值规范

| 返回类型 | 使用场景 |
|----------|----------|
| `Entity` / `VO` | 单条记录查询 |
| `List<Entity>` / `List<VO>` | 多条记录查询 |
| `int` / `Integer` | 插入/更新/删除，返回影响行数 |
| `boolean` / `Boolean` | 插入/更新/删除，返回是否成功 |
| `Page<Entity>` | 分页查询 |

```java
// ✅ 正确：返回类型匹配
User selectById(Long id);                    // 单条
List<User> selectList(Wrapper<User> wrapper); // 多条
int insert(User user);                       // 影响行数
boolean deleteById(Long id);                 // 是否成功

// ✅ 分页查询
Page<User> selectPage(Page<User> page, @Param("dto") UserQueryDTO dto);
```

#### 6. 配置文件位置

```yaml
# application.yml
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml  # XML 文件位置
  type-aliases-package: com.example.module.*.entity  # 实体类别名包
```

```
# 目录结构
src/main/resources/
└── mapper/
    └── module/
        └── user/
            └── UserMapper.xml
```

### 6.3 springboot-unified-response/SKILL.md
- **内容概要**：
  - 统一响应格式 Result<T> 设计（引用 5.4 内容）
  - 分类业务异常设计（引用 5.4 内容）
  - 全局异常处理（引用 5.4 内容）
  - 错误码规范（引用 5.4 内容）
- **参考文档**：`docs/plans/2026-03-12-unified-response-design.md`
- **状态**：✅ 已确认

---

## 八、plugin.json 和 README.md 修改

### 7.1 添加 keywords
- **新增**：`springboot`, `java`, `mybatis-plus`
- **状态**：✅ 已确认

### 7.2 更新 README.md
- **新增**：Spring Boot 项目使用说明
- **项目兼容性说明**：Spring Boot 2.7.18 + MyBatis-Plus 3.5.7
- **状态**：✅ 已确认

**README.md 新增内容模板：**

```markdown
## Spring Boot 项目支持

本插件针对 Spring Boot + MyBatis-Plus 后端项目进行了深度定制。

### 兼容版本

- Spring Boot: 2.7.18
- MyBatis-Plus: 3.5.7
- Java: 17+

### 定制内容

1. **TDD 测试框架**：JUnit 5 + Mockito
2. **分层架构规范**：Controller / Service / Mapper 职责划分
3. **统一响应格式**：Result<T> 设计
4. **MyBatis-Plus 规范**：Entity、Mapper、条件构造器使用规范
5. **代码审查标准**：分层架构审查、事务管理审查、API 规范审查

### 项目结构规范

```
src/main/java/com/example/
├── common/          # 公共组件（统一异常处理、统一响应格式）
├── schedule/        # 定时任务
├── module/          # 业务模块
│   └── user/
│       ├── controller/
│       ├── service/
│       ├── mapper/
│       ├── entity/
│       ├── dto/
│       ├── vo/
│       └── enums/
└── Application.java
```

### 使用方式

在 Spring Boot 项目中直接使用本插件的工作流程，所有技能会自动适配 Java 语法和 Spring Boot 规范。
```

---

## 讨论进度

| 章节 | 状态 | 完成时间 |
|------|------|----------|
| 一、brainstorming | ✅ 已完成 | 2026-03-15 |
| 二、test-driven-development | ✅ 已完成 | 2026-03-15 |
| 三、writing-plans | ✅ 已完成 | 2026-03-15 |
| 四、verification-before-completion | ✅ 已完成 | 2026-03-15 |
| 五、systematic-debugging | ✅ 已完成 | 2026-03-15 |
| 六、code-reviewer agent | ✅ 已完成 | 2026-03-15 |
| 七、新增技能文件 | ✅ 已完成 | 2026-03-15 |
| 八、plugin.json 和 README.md | ✅ 已完成 | 2026-03-15 |

---

## 修改清单总结

所有修改点已讨论完成，下一步将根据此清单对 xo1997-dev 插件进行增量修改。