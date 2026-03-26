# 用户管理功能设计文档

> 创建日期：2026-03-26

## 一、功能概述

实现用户管理的基本 CRUD 功能，包括用户的创建、查询、更新和删除操作。

## 二、需求分析

### 2.1 功能需求

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 创建用户 | 通过 API 创建新用户 | P0 |
| 查询用户列表 | 分页查询所有用户 | P0 |
| 查询用户详情 | 根据 ID 查询单个用户 | P0 |
| 更新用户 | 修改用户信息 | P0 |
| 删除用户 | 逻辑删除用户 | P0 |

### 2.2 非功能需求

- API 响应时间 < 200ms
- 支持分页查询
- 统一响应格式
- 统一异常处理

## 三、API 设计

### 3.1 创建用户

```
POST /api/users

Request:
{
  "username": "string (2-50字符)",
  "email": "string (邮箱格式)",
  "phone": "string (可选)",
  "status": "integer (默认1)"
}

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "phone": "13800138000",
    "status": 1,
    "createTime": "2026-03-26 10:00:00",
    "updateTime": "2026-03-26 10:00:00"
  }
}
```

### 3.2 查询用户列表

```
GET /api/users?pageNum=1&pageSize=10&username=xxx&status=1

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "list": [...]
  }
}
```

### 3.3 查询用户详情

```
GET /api/users/{id}

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "phone": "13800138000",
    "status": 1,
    "createTime": "2026-03-26 10:00:00",
    "updateTime": "2026-03-26 10:00:00"
  }
}
```

### 3.4 更新用户

```
PUT /api/users/{id}

Request:
{
  "username": "string",
  "email": "string",
  "phone": "string",
  "status": "integer"
}

Response:
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

### 3.5 删除用户

```
DELETE /api/users/{id}

Response:
{
  "code": 200,
  "message": "success"
}
```

## 四、数据库设计

### 4.1 用户表 (t_user)

| 字段 | 类型 | 是否必填 | 默认值 | 说明 |
|------|------|----------|--------|------|
| id | BIGINT | 是 | 自增 | 主键 |
| username | VARCHAR(50) | 是 | - | 用户名 |
| email | VARCHAR(100) | 是 | - | 邮箱 |
| phone | VARCHAR(20) | 否 | NULL | 手机号 |
| status | TINYINT | 是 | 1 | 状态：1-正常，0-禁用 |
| create_by | VARCHAR(30) | 否 | NULL | 创建人 |
| create_time | DATETIME | 是 | CURRENT_TIMESTAMP | 创建时间 |
| update_by | VARCHAR(30) | 否 | NULL | 更新人 |
| update_time | DATETIME | 是 | CURRENT_TIMESTAMP | 更新时间 |
| is_del | TINYINT(1) | 是 | 0 | 逻辑删除：0-未删除，1-已删除 |

### 4.2 索引设计

- `idx_username`: 用户名索引
- `idx_email`: 邮箱索引
- `idx_status`: 状态索引

## 五、架构设计

### 5.1 分层架构

```
Controller (UserController)
    ↓
Service (UserService → UserServiceImpl)
    ↓
Mapper (UserMapper)
    ↓
Database (t_user)
```

### 5.2 文件结构

```
src/main/java/com/example/module/user/
├── controller/
│   └── UserController.java
├── service/
│   ├── UserService.java
│   └── impl/
│       └── UserServiceImpl.java
├── mapper/
│   └── UserMapper.java
├── entity/
│   └── User.java
├── dto/
│   ├── UserCreateDTO.java
│   ├── UserUpdateDTO.java
│   └── UserQueryDTO.java
├── vo/
│   └── UserVO.java
└── constants/
    └── UserConstants.java
```

## 六、测试计划

### 6.1 单元测试

- UserServiceTest: 测试业务逻辑
- UserControllerTest: 测试 API 端点

### 6.2 集成测试

- 完整 CRUD 流程测试
- 异常情况测试

## 七、验收标准

- [ ] 所有 API 端点正常工作
- [ ] 所有单元测试通过
- [ ] 响应格式符合统一规范
- [ ] Entity 包含审计字段
- [ ] 使用逻辑删除
