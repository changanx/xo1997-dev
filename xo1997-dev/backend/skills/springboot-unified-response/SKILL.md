---
name: springboot-unified-response
description: Use when building Spring Boot REST APIs that need consistent response format and centralized exception handling. Triggers when starting new API development or refactoring existing controllers with inconsistent response structures.
---

# Spring Boot Unified Response

## Overview

This skill provides a unified response format design for Spring Boot REST APIs, including Result<T> class, categorized business exceptions, global exception handler, and error code standards.

## Response Format

### Unified Response Structure

```json
{
  "code": 200,
  "message": "success",
  "data": { }
}
```

| Field | Type | Description |
|-------|------|-------------|
| code | int | Status code |
| message | String | Response message |
| data | T | Response data |

### Error Codes

| Code | Description | Exception Class |
|------|-------------|-----------------|
| 200 | Success | - |
| 400 | Bad Request | BadRequestException |
| 403 | Forbidden | ForbiddenException |
| 404 | Not Found | NotFoundException |
| 500 | Internal Server Error | Exception |

## Result Class

```java
package com.example.common.result;

import lombok.Data;

@Data
public class Result<T> {
    private int code;
    private String message;
    private T data;

    private Result() {}

    private Result(int code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    public static <T> Result<T> success(T data) {
        return new Result<>(200, "success", data);
    }

    public static <T> Result<T> success() {
        return new Result<>(200, "success", null);
    }

    public static <T> Result<T> error(int code, String message) {
        return new Result<>(code, message, null);
    }

    public static <T> Result<T> badRequest(String message) {
        return error(400, message);
    }

    public static <T> Result<T> notFound(String message) {
        return error(404, message);
    }

    public static <T> Result<T> forbidden(String message) {
        return error(403, message);
    }
}
```

## Business Exceptions

### Base Business Exception

```java
package com.example.common.exception;

import lombok.Getter;

@Getter
public class BusinessException extends RuntimeException {
    private final int code;

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}
```

### Categorized Exceptions

```java
// 400 Bad Request
package com.example.common.exception;

public class BadRequestException extends BusinessException {
    public BadRequestException(String message) {
        super(400, message);
    }
}

// 404 Not Found
package com.example.common.exception;

public class NotFoundException extends BusinessException {
    public NotFoundException(String message) {
        super(404, message);
    }
}

// 403 Forbidden
package com.example.common.exception;

public class ForbiddenException extends BusinessException {
    public ForbiddenException(String message) {
        super(403, message);
    }
}
```

## Global Exception Handler

```java
package com.example.common.exception;

import com.example.common.result.Result;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

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

    @ExceptionHandler(IllegalArgumentException.class)
    public Result<?> handleIllegalArgumentException(IllegalArgumentException e) {
        return Result.badRequest(e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        return Result.error(500, "Internal server error");
    }
}
```

## Controller Usage

### Correct Usage

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public Result<List<UserVO>> list() {
        return Result.success(userService.list());
    }

    @GetMapping("/{id}")
    public Result<UserVO> getById(@PathVariable Long id) {
        UserVO user = userService.getById(id);
        if (user == null) {
            throw new NotFoundException("User not found");
        }
        return Result.success(user);
    }

    @PostMapping
    public Result<UserVO> create(@RequestBody @Valid UserCreateDTO dto) {
        return Result.success(userService.create(dto));
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

### Service Layer Exception Usage

```java
@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    public UserServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Override
    public UserVO getById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new NotFoundException("User not found");
        }
        return new UserVO(user);
    }

    @Override
    public UserVO create(UserCreateDTO dto) {
        if (dto.getName() == null || dto.getName().trim().isEmpty()) {
            throw new BadRequestException("Username cannot be empty");
        }
        // ... business logic
    }
}
```

## Interfaces NOT to Wrap

Some interfaces should not use Result<T>:

- **Streaming endpoints** (video, file download) - Return `ResponseEntity<Resource>`
- **File download endpoints** - Return binary data directly

```java
// Stream endpoint - keep original format
@GetMapping("/videos/{id}/stream")
public ResponseEntity<Resource> streamVideo(@PathVariable Long id) {
    Resource resource = videoService.getVideoResource(id);
    return ResponseEntity.ok()
        .contentType(MediaType.parseMediaType("video/mp4"))
        .body(resource);
}

// File download endpoint - keep original format
@GetMapping("/files/{id}/download")
public ResponseEntity<Resource> downloadFile(@PathVariable Long id) {
    Resource resource = fileService.getFileResource(id);
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
        .body(resource);
}
```

## Frontend Integration

### Axios Interceptor

```javascript
// Response interceptor
api.interceptors.response.use(
  response => {
    // Unified response format: { code, message, data }
    const result = response.data
    if (result.code === 200) {
      return { data: result.data }
    } else {
      const error = new Error(result.message)
      error.code = result.code
      return Promise.reject(error)
    }
  },
  error => {
    if (error.response) {
      const result = error.response.data
      const message = result?.message || 'Request failed'
      console.error('API Error:', message)
      return Promise.reject(new Error(message))
    }
    return Promise.reject(error)
  }
)
```

## Directory Structure

```
src/main/java/com/example/
├── common/
│   ├── exception/
│   │   ├── GlobalExceptionHandler.java
│   │   ├── BusinessException.java
│   │   ├── BadRequestException.java
│   │   ├── NotFoundException.java
│   │   └── ForbiddenException.java
│   └── result/
│       └── Result.java
└── module/
    └── user/
        └── controller/
            └── UserController.java
```

## Checklist

Before completing API implementation:

- [ ] Result class created with success/error methods
- [ ] Business exceptions created (BadRequest, NotFound, Forbidden)
- [ ] GlobalExceptionHandler configured
- [ ] All controllers return Result<T> (except streaming/download endpoints)
- [ ] Service layer throws appropriate business exceptions
- [ ] Validation errors handled by GlobalExceptionHandler
- [ ] Frontend interceptor updated to handle Result format