# User CRUD Implementation Plan

> **For agentic workers:** REQUIRED: Use subagent-driven-development (if subagents available) or executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement user CRUD operations with validation, pagination, and unified response format.

**Architecture:** Layered architecture with Controller-Service-Mapper pattern. RESTful API design with unified Result<T> response format. MyBatis-Plus for data access with logical delete support.

**Tech Stack:** Spring Boot 2.7.18, MyBatis-Plus 3.5.7, MySQL 8.0, JUnit 5, Mockito

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
package com.example.module.user.dto;

import lombok.Data;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class UserCreateDTO {
    @NotBlank(message = "用户名不能为空")
    @Size(min = 2, max = 50, message = "用户名长度2-50字符")
    private String username;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    private String phone;

    private Integer status = 1;
}
```

- [ ] **Step 2: Create UserUpdateDTO**

```java
package com.example.module.user.dto;

import lombok.Data;
import javax.validation.constraints.Email;
import javax.validation.constraints.Size;

@Data
public class UserUpdateDTO {
    @Size(min = 2, max = 50, message = "用户名长度2-50字符")
    private String username;

    @Email(message = "邮箱格式不正确")
    private String email;

    private String phone;

    private Integer status;
}
```

- [ ] **Step 3: Create UserQueryDTO**

```java
package com.example.module.user.dto;

import lombok.Data;

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
package com.example.module.user.vo;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserVO {
    private Long id;
    private String username;
    private String email;
    private String phone;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
```

- [ ] **Step 5: Commit**

```bash
git add src/main/java/com/example/module/user/dto/
git add src/main/java/com/example/module/user/vo/
git commit -m "feat(user): add DTOs and VOs for user module"
```

### Task 2: Create User Entity with Audit Fields

**Files:**
- Create: `src/main/java/com/example/module/user/entity/User.java`
- Create: `src/test/java/com/example/module/user/entity/UserTest.java`

- [ ] **Step 1: Write the failing test**

```java
package com.example.module.user.entity;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class UserTest {
    @Test
    void shouldHaveAuditFields() {
        User user = new User();

        assertDoesNotThrow(() -> user.getClass().getDeclaredField("id"));
        assertDoesNotThrow(() -> user.getClass().getDeclaredField("createTime"));
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
package com.example.module.user.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("t_user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String email;

    private String phone;

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

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn test -Dtest=UserTest`
Expected: PASS

- [ ] **Step 5: Commit**

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
package com.example.module.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.module.user.entity.User;
import org.apache.ibatis.annotations.Mapper;

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

- [ ] **Step 1: Write test for create user**

```java
package com.example.module.user.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.module.user.dto.UserCreateDTO;
import com.example.module.user.dto.UserQueryDTO;
import com.example.module.user.dto.UserUpdateDTO;
import com.example.module.user.entity.User;
import com.example.module.user.mapper.UserMapper;
import com.example.module.user.service.impl.UserServiceImpl;
import com.example.module.user.vo.UserVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

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

        when(userMapper.insert(any(User.class))).thenReturn(1);

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
Expected: FAIL

- [ ] **Step 3: Create UserService interface**

```java
package com.example.module.user.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.module.user.dto.UserCreateDTO;
import com.example.module.user.dto.UserQueryDTO;
import com.example.module.user.dto.UserUpdateDTO;
import com.example.module.user.vo.UserVO;

public interface UserService {
    UserVO create(UserCreateDTO dto);
    UserVO getById(Long id);
    Page<UserVO> list(UserQueryDTO dto);
    UserVO update(Long id, UserUpdateDTO dto);
    void delete(Long id);
}
```

- [ ] **Step 4: Create UserServiceImpl**

```java
package com.example.module.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.module.user.dto.UserCreateDTO;
import com.example.module.user.dto.UserQueryDTO;
import com.example.module.user.dto.UserUpdateDTO;
import com.example.module.user.entity.User;
import com.example.module.user.mapper.UserMapper;
import com.example.module.user.service.UserService;
import com.example.module.user.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    @Override
    public UserVO create(UserCreateDTO dto) {
        User user = new User();
        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setPhone(dto.getPhone());
        user.setStatus(dto.getStatus() != null ? dto.getStatus() : 1);
        userMapper.insert(user);
        return toVO(user);
    }

    @Override
    public UserVO getById(Long id) {
        User user = userMapper.selectById(id);
        return user != null ? toVO(user) : null;
    }

    @Override
    public Page<UserVO> list(UserQueryDTO dto) {
        Page<User> page = new Page<>(dto.getPageNum(), dto.getPageSize());
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(dto.getUsername()), User::getUsername, dto.getUsername())
               .eq(dto.getStatus() != null, User::getStatus, dto.getStatus());
        userMapper.selectPage(page, wrapper);

        Page<UserVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(this::toVO).toList());
        return voPage;
    }

    @Override
    public UserVO update(Long id, UserUpdateDTO dto) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        if (dto.getUsername() != null) user.setUsername(dto.getUsername());
        if (dto.getEmail() != null) user.setEmail(dto.getEmail());
        if (dto.getPhone() != null) user.setPhone(dto.getPhone());
        if (dto.getStatus() != null) user.setStatus(dto.getStatus());
        userMapper.updateById(user);
        return toVO(user);
    }

    @Override
    public void delete(Long id) {
        userMapper.deleteById(id);
    }

    private UserVO toVO(User user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setEmail(user.getEmail());
        vo.setPhone(user.getPhone());
        vo.setStatus(user.getStatus());
        vo.setCreateTime(user.getCreateTime());
        vo.setUpdateTime(user.getUpdateTime());
        return vo;
    }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `mvn test -Dtest=UserServiceTest`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add src/main/java/com/example/module/user/service/
git add src/test/java/com/example/module/user/service/
git commit -m "feat(user): add UserService with create and query methods"
```

---

## Chunk 3: Controller Layer

### Task 5: Create UserController

**Files:**
- Create: `src/main/java/com/example/module/user/controller/UserController.java`
- Create: `src/test/java/com/example/module/user/controller/UserControllerTest.java`

- [ ] **Step 1: Write test for create endpoint**

```java
package com.example.module.user.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.module.user.dto.UserCreateDTO;
import com.example.module.user.dto.UserQueryDTO;
import com.example.module.user.service.UserService;
import com.example.module.user.vo.UserVO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldReturn200_whenCreateUser() throws Exception {
        UserCreateDTO dto = new UserCreateDTO();
        dto.setUsername("testuser");
        dto.setEmail("test@example.com");

        UserVO vo = new UserVO();
        vo.setId(1L);
        vo.setUsername("testuser");

        when(userService.create(any())).thenReturn(vo);

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

Run: `mvn test -Dtest=UserControllerTest`
Expected: FAIL

- [ ] **Step 3: Create UserController**

```java
package com.example.module.user.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.module.user.dto.UserCreateDTO;
import com.example.module.user.dto.UserQueryDTO;
import com.example.module.user.dto.UserUpdateDTO;
import com.example.module.user.service.UserService;
import com.example.module.user.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public Result<UserVO> create(@RequestBody @Valid UserCreateDTO dto) {
        return Result.success(userService.create(dto));
    }

    @GetMapping("/{id}")
    public Result<UserVO> getById(@PathVariable Long id) {
        return Result.success(userService.getById(id));
    }

    @GetMapping
    public Result<Page<UserVO>> list(UserQueryDTO dto) {
        return Result.success(userService.list(dto));
    }

    @PutMapping("/{id}")
    public Result<UserVO> update(@PathVariable Long id, @RequestBody @Valid UserUpdateDTO dto) {
        return Result.success(userService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return Result.success();
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn test -Dtest=UserControllerTest`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add src/main/java/com/example/module/user/controller/
git add src/test/java/com/example/module/user/controller/
git commit -m "feat(user): add UserController with CRUD endpoints"
```

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
git commit -m "feat(user): complete user CRUD module"
```
