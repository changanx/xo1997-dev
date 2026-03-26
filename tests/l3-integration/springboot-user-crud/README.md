# Spring Boot User CRUD 集成测试

这是一个用于 L3 集成测试的示例项目，测试完整的 brainstorming → writing-plans → subagent-driven-development 工作流。

## 测试场景

实现一个简单的用户 CRUD 功能：
- 创建用户
- 查询用户
- 更新用户
- 删除用户

## 技术栈

- Spring Boot 2.7.18
- MyBatis-Plus 3.5.7
- MySQL 8.0
- JUnit 5

## 预期产出

1. 设计文档：`docs/specs/feature_user_crud/design.md`
2. 实现计划：`docs/plans/user-crud-plan.md`
3. 实现代码：
   - Controller: `src/main/java/com/example/module/user/controller/UserController.java`
   - Service: `src/main/java/com/example/module/user/service/UserService.java`
   - Mapper: `src/main/java/com/example/module/user/mapper/UserMapper.java`
   - Entity: `src/main/java/com/example/module/user/entity/User.java`
