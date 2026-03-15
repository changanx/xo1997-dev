---
name: springboot-best-practices
description: Use when building Spring Boot REST APIs that need consistent response format and centralized exception handling. Triggers when starting new API development or refactoring existing controllers with inconsistent response structures.
---

# Spring Boot Best Practices

## Overview

This skill provides best practices for Spring Boot application development, including layered architecture, dependency injection, configuration management, exception handling, and parameter validation.

## Layered Architecture

### Project Structure

```
src/main/java/com/example/
├── common/                          # Common components
│   ├── exception/                   # Exception handling
│   │   ├── GlobalExceptionHandler.java
│   │   └── BusinessException.java
│   └── result/                      # Unified response
│       └── Result.java
├── schedule/                        # Scheduled tasks
│   └── ScheduleTask.java
├── module/                          # Business modules
│   ├── user/                        # User module
│   │   ├── controller/
│   │   ├── service/
│   │   ├── mapper/
│   │   ├── entity/
│   │   ├── dto/
│   │   ├── vo/
│   │   ├── constants/
│   │   └── enums/
│   └── video/                       # Video module
└── Application.java
```

### Layer Responsibilities

| Layer | Responsibility | Forbidden |
|-------|---------------|-----------|
| **Controller** | Receive requests, validate params, call Service, wrap response | Business logic, direct DB operations |
| **Service** | Business logic, transaction control, call Mapper or other Services | HTTP-related code (ResponseEntity) |
| **Mapper** | Data access, SQL definition | Business logic |

### File Creation Order (Top-Down)

1. **Controller** - Define API endpoints
2. **DTO/VO** - Define request/response objects
3. **Service Interface** - Define business methods
4. **Service Implementation** - Implement business logic
5. **Mapper** - Define data access
6. **Entity** - Define database mapping
7. **Test** - Write tests

## Core Annotations

| Annotation | Usage | Standard |
|------------|-------|----------|
| `@RestController` | Controller layer class | Combined annotation (@Controller + @ResponseBody), for RESTful APIs |
| `@Service` | Service layer class | Mark business service class, for Spring scanning and transaction management |
| `@Autowired` | Dependency injection | Prefer constructor injection, avoid field injection |
| `@Valid` / `@Validated` | Parameter validation | Controller method param validation, with Bean Validation annotations |
| `@Transactional` | Transaction management | Only for Service layer, forbidden in Controller/Mapper |

### Dependency Injection

```java
// ✅ Correct: Constructor injection (recommended)
@Service
@RequiredArgsConstructor  // Lombok generates constructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final OrderService orderService;

    // No @Autowired needed, Spring 4.3+ single constructor auto-injects
}

// ✅ Correct: Multiple constructors with @Autowired
@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    @Autowired
    public UserServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }
}

// ❌ Wrong: Field injection (not recommended)
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;  // Hard to test, hides dependencies
}
```

### Annotation Anti-Patterns

```java
// ❌ Forbidden: @Transactional in Controller
@RestController
public class UserController {
    @Transactional  // Wrong: Transaction should be in Service layer
    @PostMapping("/users")
    public Result<UserVO> create(@RequestBody UserCreateDTO dto) { }
}

// ❌ Forbidden: Abusing @Autowired on optional dependencies
// If dependency is optional, use @Autowired(required = false)

// ❌ Forbidden: @Service or @Component on Mapper interface
@Mapper
@Service  // Wrong: Mapper is managed by MyBatis
public interface UserMapper extends BaseMapper<User> { }
```

## Configuration Management

### Multi-Environment Configuration

```yaml
# application.yml - Common config
spring:
  profiles:
    active: dev

# application-dev.yml - Development
server:
  port: 8080

# application-prod.yml - Production
server:
  port: 80
```

**Start with specific profile:**
```bash
java -jar app.jar --spring.profiles.active=prod
```

## Parameter Validation

### Bean Validation Annotations

| Annotation | Description |
|------------|-------------|
| `@NotNull` | Cannot be null |
| `@NotBlank` | String cannot be empty (at least one non-whitespace char) |
| `@Size(min, max)` | String/collection length range |
| `@Min(value)` / `@Max(value)` | Numeric min/max value |
| `@Pattern(regexp)` | Regex pattern match |
| `@Email` | Email format |

### Validation Example

```java
@Data
public class UserCreateDTO {
    @NotBlank(message = "Username cannot be empty")
    @Size(min = 2, max = 20, message = "Username length 2-20 chars")
    private String name;

    @NotNull(message = "Age cannot be null")
    @Min(value = 0, message = "Age cannot be less than 0")
    private Integer age;

    @Email(message = "Invalid email format")
    private String email;
}

// Controller usage
@PostMapping
public Result<UserVO> create(@RequestBody @Valid UserCreateDTO dto) {
    return Result.success(userService.create(dto));
}
```

## Exception Handling

### Categorized Business Exceptions

```java
// Base business exception
@Getter
public class BusinessException extends RuntimeException {
    private final int code;

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}

// 400 Bad Request
public class BadRequestException extends BusinessException {
    public BadRequestException(String message) {
        super(400, message);
    }
}

// 404 Not Found
public class NotFoundException extends BusinessException {
    public NotFoundException(String message) {
        super(404, message);
    }
}

// 403 Forbidden
public class ForbiddenException extends BusinessException {
    public ForbiddenException(String message) {
        super(403, message);
    }
}
```

### Global Exception Handler

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
        return Result.error(500, "Internal server error");
    }
}
```

## Transaction Management

### Basic Rules

- Place `@Transactional` on Service layer methods or classes
- Default only rolls back `RuntimeException` and `Error`
- Use `@Transactional(rollbackFor = Exception.class)` to roll back all exceptions
- Use `@Transactional(readOnly = true)` for query methods

### Transaction Anti-Patterns

```java
// ❌ Wrong: Large transaction with remote calls
@Transactional
public void createOrder(OrderCreateDTO dto) {
    orderMapper.insert(order);
    paymentService.remoteCall(dto);  // ❌ Should not be in transaction
    fileService.writeFile(file);      // ❌ Should not be in transaction
}

// ✅ Correct: Split transaction
public void createOrder(OrderCreateDTO dto) {
    saveOrderInTransaction(order);    // Transaction method

    paymentService.remoteCall(dto);   // Non-transaction
    fileService.writeFile(file);       // Non-transaction
}

@Transactional(rollbackFor = Exception.class)
public void saveOrderInTransaction(Order order) {
    orderMapper.insert(order);
}
```

## Checklist

Before completing a feature:

- [ ] Controller uses DTO/VO, not Entity directly
- [ ] Service handles business logic, no HTTP code
- [ ] Mapper only does data access, no business logic
- [ ] Constructor injection used (not field injection)
- [ ] Parameter validation with @Valid + Bean Validation
- [ ] Transaction on Service layer only
- [ ] Unified response format Result<T>
- [ ] Global exception handler configured