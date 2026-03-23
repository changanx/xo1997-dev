---
name: mybatis-plus-patterns
description: Use when working with MyBatis-Plus for database operations. Covers Entity design, Mapper interfaces, query wrappers, pagination, and custom SQL patterns.
---

# MyBatis-Plus Patterns

## Overview

This skill provides patterns and best practices for MyBatis-Plus development, including Entity design, Mapper interfaces, query wrappers, pagination, logical delete, and custom SQL methods.

## Entity Design

### Unified Database Fields

All tables should include these audit fields:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| create_by | VARCHAR(30) | - | Creator |
| create_time | DATETIME | CURRENT_TIMESTAMP | Create time |
| update_by | VARCHAR(30) | - | Updater |
| update_time | DATETIME | CURRENT_TIMESTAMP | Update time |
| is_del | TINYINT(1) | 0 | Logical delete (0: not deleted, 1: deleted) |

### Entity Example

```java
@TableName("t_order")
public class Order {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String orderNo;
    private Long userId;
    private BigDecimal totalAmount;

    // Audit fields - auto fill
    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    // Logical delete
    @TableLogic
    private Integer isDel;
}
```

### Enum Handling

Use `@EnumValue` for enum storage:

```java
public enum OrderStatus {
    PENDING(0, "Pending"),
    PAID(1, "Paid"),
    CANCELLED(2, "Cancelled");

    @EnumValue
    private final Integer code;
    private final String desc;

    OrderStatus(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }
}
```

## Mapper Interface

### Basic Usage

```java
// Extends BaseMapper<Entity>
public interface UserMapper extends BaseMapper<User> {
    // Inherits: insert, deleteById, updateById, selectById, selectList, selectPage, etc.
}
```

### Mapper Annotation

```java
@Mapper
public interface UserMapper extends BaseMapper<User> {
    // MyBatis-Plus manages this interface
}
```

## Query Wrappers

### Lambda Query Wrapper (Recommended)

```java
// ✅ Correct: Use Lambda to avoid hardcoding field names
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.eq(User::getName, "张三")
       .like(User::getEmail, "@gmail.com")
       .orderByDesc(User::getCreateTime);

List<User> users = userMapper.selectList(wrapper);
```

### Lambda Update Wrapper

```java
LambdaUpdateWrapper<User> wrapper = new LambdaUpdateWrapper<>();
wrapper.set(User::getName, "李四")
       .eq(User::getId, 1L);

userMapper.update(null, wrapper);
```

### Avoid Hardcoding

```java
// ❌ Wrong: Hardcoded field names
QueryWrapper<User> wrapper = new QueryWrapper<>();
wrapper.eq("name", "张三");  // Easy to make mistakes

// ✅ Correct: Use Lambda
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.eq(User::getName, "张三");
```

## Pagination

### Configuration

```java
@Configuration
public class MybatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
```

### Usage

```java
// Page query
Page<User> page = new Page<>(pageNum, pageSize);
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.like(User::getName, keyword);

Page<User> result = userMapper.selectPage(page, wrapper);
List<User> records = result.getRecords();
long total = result.getTotal();
```

## Logical Delete

### Global Configuration

```yaml
mybatis-plus:
  global-config:
    db-config:
      logic-delete-field: isDel
      logic-delete-value: 1
      logic-not-delete-value: 0
```

### Entity Configuration

```java
public class User {
    @TableLogic
    private Integer isDel;
}
```

### Usage

```java
// Logical delete (sets is_del = 1)
userMapper.deleteById(1L);

// Query automatically filters deleted records
List<User> users = userMapper.selectList(null);  // WHERE is_del = 0
```

## Custom SQL Methods

### Priority: XML > Annotation > Native

### 1. XML Custom SQL (Recommended)

**Mapper Interface:**
```java
public interface UserMapper extends BaseMapper<User> {

    List<UserVO> selectUsersByCondition(@Param("dto") UserQueryDTO dto);

    int batchInsert(@Param("list") List<User> users);
}
```

**XML File (resources/mapper/UserMapper.xml):**
```xml
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

### 2. Annotation SQL (Simple Cases Only)

```java
// Only for simple SQL, complex SQL should use XML
public interface UserMapper extends BaseMapper<User> {

    @Select("SELECT * FROM t_user WHERE email = #{email} AND is_del = 0")
    User selectByEmail(@Param("email") String email);

    @Update("UPDATE t_user SET status = #{status} WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
```

### 3. Coexistence with Native Methods

```java
// ✅ Correct: Extend BaseMapper for native methods + define custom methods
public interface UserMapper extends BaseMapper<User> {

    // Native methods (auto-generated):
    // - insert(User entity)
    // - deleteById(Serializable id)
    // - updateById(User entity)
    // - selectById(Serializable id)
    // - selectList(Wrapper<User> queryWrapper)
    // - selectPage(Page<User> page, Wrapper<User> queryWrapper)

    // Custom methods (XML or annotation):
    List<UserVO> selectUsersByCondition(@Param("dto") UserQueryDTO dto);
}

// ❌ Wrong: Custom method name conflicts with native method
public interface UserMapper extends BaseMapper<User> {

    // Wrong: insert is native method, cannot override
    int insert(User user);

    // Correct: Use different method name
    int insertBatch(@Param("list") List<User> users);
}
```

### Parameter Rules

```java
// ✅ Single parameter with @Param
User selectByEmail(@Param("email") String email);

// ✅ Multiple parameters must use @Param
List<User> selectByNameAndStatus(
    @Param("name") String name,
    @Param("status") Integer status
);

// ✅ DTO object as parameter
List<UserVO> selectUsersByCondition(@Param("dto") UserQueryDTO dto);

// ✅ Collection parameter
int batchInsert(@Param("list") List<User> users);

// ❌ Wrong: Multiple parameters without @Param
List<User> selectByNameAndStatus(String name, Integer status);  // MyBatis can't identify
```

### Return Type Rules

| Return Type | Use Case |
|-------------|----------|
| `Entity` / `VO` | Single record query |
| `List<Entity>` / `List<VO>` | Multiple records query |
| `int` / `Integer` | Insert/update/delete, returns affected rows |
| `boolean` / `Boolean` | Insert/update/delete, returns success |
| `Page<Entity>` | Pagination query |

## Configuration

```yaml
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.example.module.*.entity
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # SQL log
  global-config:
    db-config:
      logic-delete-field: isDel
      logic-delete-value: 1
      logic-not-delete-value: 0
```

## Directory Structure

```
src/main/resources/
└── mapper/
    └── module/
        └── user/
            └── UserMapper.xml
```

## Checklist

Before completing data access code:

- [ ] Entity has correct annotations (@TableName, @TableId, @TableLogic)
- [ ] Mapper extends BaseMapper<Entity>
- [ ] Use LambdaQueryWrapper, avoid hardcoding field names
- [ ] Pagination configured and used correctly
- [ ] Logical delete configured
- [ ] Custom SQL uses XML (preferred) or annotations
- [ ] Parameters use @Param annotation
- [ ] Return types match method purpose