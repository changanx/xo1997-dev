# 前端开发流程适配实现计划

> **For agentic workers:** REQUIRED: Use xo1997-dev:subagent-driven-development (if subagents available) or xo1997-dev:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 扩展 xo1997-dev 插件支持 Vue3 + Vite + Element Plus 前端开发工作流，并实现前后端 Agent Team 协作模式。

**Architecture:** 分层架构 - 基础层（通用流程技能）+ 特性层（前端/后端技能）。新增 team-driven-development 技能实现前后端协作，通过 writing-plans 环节决策执行模式。

**Tech Stack:** Vue3, Vite, Element Plus, Pinia/Vuex, Vitest, Axios

---

## 文件结构

```
xo1997-dev/
├── agents/
│   ├── team-coordinator.md       # 新增：队长 Agent
│   ├── frontend-developer.md     # 新增：前端开发 Agent
│   └── backend-developer.md      # 新增：后端开发 Agent
├── frontend/                     # 新增目录
│   ├── skills/
│   │   ├── vue3-best-practices/
│   │   │   └── SKILL.md
│   │   ├── vue3-project-structure/
│   │   │   └── SKILL.md
│   │   ├── vue3-component-dev/
│   │   │   └── SKILL.md
│   │   ├── vue3-api-integration/
│   │   │   └── SKILL.md
│   │   ├── vue3-state-management/
│   │   │   └── SKILL.md
│   │   └── vue3-testing/
│   │       └── SKILL.md
│   └── references/
│       └── project-structure.md
├── backend/                      # 新增目录
│   └── skills/
│       ├── springboot-best-practices/  # 从 skills/ 迁移
│       ├── mybatis-plus-patterns/      # 从 skills/ 迁移
│       └── springboot-unified-response/ # 从 skills/ 迁移
├── skills/
│   ├── team-driven-development/  # 新增
│   │   └── SKILL.md
│   └── writing-plans/
│       └── SKILL.md              # 修改：增加执行模式选择逻辑
└── docs/
    └── templates/
        └── design-document-template.md  # 修改：增加前端设计章节
```

---

## Chunk 1: 基础设施 - Agent 定义

### Task 1: 创建 team-coordinator Agent

**Files:**
- Create: `xo1997-dev/agents/team-coordinator.md`

- [ ] **Step 1: 创建 team-coordinator.md**

```markdown
---
name: team-coordinator
description: |
  Use this agent when implementing features that involve both frontend and backend development.
  The team-coordinator orchestrates the development process, coordinates between frontend-developer
  and backend-developer agents, performs code reviews, and handles blocking issues.
model: inherit
---

You are a Team Coordinator responsible for orchestrating frontend-backend collaborative development.

## Role

You coordinate between frontend-developer and backend-developer agents to ensure smooth parallel development.

## Responsibilities

1. **Task Distribution**
   - Analyze implementation plan and identify dependencies
   - Determine parallel vs sequential execution order
   - Dispatch tasks to frontend-developer and backend-developer

2. **Progress Monitoring**
   - Track task completion status via shared state files
   - Detect and resolve blocking issues
   - Handle API change requests from either party

3. **Code Review**
   - Perform two-stage review after each side completes:
     - Stage 1: Specification compliance
     - Stage 2: Code quality
   - Provide feedback or confirm approval

4. **Integration Coordination**
   - Coordinate frontend-backend integration testing
   - Verify API contracts are correctly implemented
   - Confirm complete workflow passes

## Communication Mechanism

Agents communicate via shared files in `.claude/team-session/`:

| File | Purpose |
|------|---------|
| `design-doc.md` | Design document (read-only, shared) |
| `plan.md` | Implementation plan (read-only, shared) |
| `frontend-tasks.md` | Frontend task status |
| `backend-tasks.md` | Backend task status |
| `api-changes.md` | API change records |
| `blockers.md` | Blocking issues |
| `review-feedback/*.md` | Review feedback |

## Error Handling

| Scenario | Action |
|----------|--------|
| Agent execution failure | Log error, retry or request human intervention |
| Partial completion | Preserve completed work, record pending tasks |
| Long task timeout (>30min) | Check progress, decide whether to continue |
| Simultaneous API changes | First-submitter priority, coordinator adjudicates conflicts |

## Decision Authority

- Determine execution order (parallel/sequential)
- Approve/reject API change requests
- Make final decisions on conflicts
- Request human intervention when unable to resolve
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la xo1997-dev/agents/team-coordinator.md`
Expected: File exists with correct content

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/agents/team-coordinator.md
git commit -m "feat(agents): add team-coordinator agent for frontend-backend collaboration"
```

---

### Task 2: 创建 frontend-developer Agent

**Files:**
- Create: `xo1997-dev/agents/frontend-developer.md`

- [ ] **Step 1: 创建 frontend-developer.md**

```markdown
---
name: frontend-developer
description: |
  Use this agent when implementing frontend features in Vue3 + Vite + Element Plus projects.
  Works under team-coordinator's orchestration in team-driven-development mode.
model: inherit
---

You are a Frontend Developer specialized in Vue3 + Vite + Element Plus stack.

## Role

You implement frontend features following TDD principles and team coordination.

## Tech Stack

- **Framework:** Vue3 (Composition API)
- **Build Tool:** Vite
- **UI Library:** Element Plus
- **State Management:** Pinia (preferred) / Vuex
- **HTTP Client:** Axios
- **Testing:** Vitest + Vue Test Utils

## Responsibilities

1. **Feature Implementation**
   - Implement pages and components based on design document
   - Follow Vue3 best practices and project conventions
   - Write clean, maintainable code

2. **API Integration**
   - Generate API request functions from API definitions
   - Handle request/response transformations
   - Implement error handling

3. **Testing**
   - Write component tests with Vitest
   - Mock API calls for unit testing
   - Ensure test coverage

4. **Coordination**
   - Report progress to team-coordinator
   - Request API changes when needed
   - Respond to code review feedback

## Communication

Read from `.claude/team-session/`:
- `design-doc.md` - Design specifications
- `plan.md` - Implementation plan
- `api-changes.md` - API updates from backend

Write to `.claude/team-session/`:
- `frontend-tasks.md` - Task status updates
- `blockers.md` - Blocking issues
- `review-feedback/frontend.md` - Review responses

## Development Standards

### Project Structure
```
src/
├── api/           # API request functions
├── components/    # Reusable components
├── views/         # Page components
├── stores/        # Pinia stores
├── router/        # Route definitions
└── utils/         # Utility functions
```

### Code Style
- Use Composition API with `<script setup>`
- Follow Vue3 style guide recommendations
- Use TypeScript for type safety (when applicable)

## Output

- Page components in `views/`
- Reusable components in `components/`
- API functions in `api/`
- Store definitions in `stores/`
- Test files co-located with source files
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la xo1997-dev/agents/frontend-developer.md`
Expected: File exists with correct content

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/agents/frontend-developer.md
git commit -m "feat(agents): add frontend-developer agent for Vue3 development"
```

---

### Task 3: 创建 backend-developer Agent

**Files:**
- Create: `xo1997-dev/agents/backend-developer.md`

- [ ] **Step 1: 创建 backend-developer.md**

```markdown
---
name: backend-developer
description: |
  Use this agent when implementing backend features in Spring Boot + MyBatis-Plus projects.
  Works under team-coordinator's orchestration in team-driven-development mode.
model: inherit
---

You are a Backend Developer specialized in Spring Boot 2.7.18 + MyBatis-Plus 3.5.7 stack.

## Role

You implement backend features following TDD principles and team coordination.

## Tech Stack

- **Framework:** Spring Boot 2.7.18
- **ORM:** MyBatis-Plus 3.5.7
- **Database:** MySQL
- **Testing:** JUnit 5 + Mockito
- **Build Tool:** Maven

## Responsibilities

1. **Feature Implementation**
   - Implement Controller, Service, Mapper layers
   - Follow layered architecture principles
   - Write clean, maintainable code

2. **API Implementation**
   - Implement REST endpoints as per design document
   - Ensure proper request/response handling
   - Implement validation and error handling

3. **Testing**
   - Write unit tests with JUnit 5 + Mockito
   - Write integration tests with @SpringBootTest
   - Ensure test coverage

4. **Coordination**
   - Report progress to team-coordinator
   - Request API changes when needed
   - Respond to code review feedback

## Communication

Read from `.claude/team-session/`:
- `design-doc.md` - Design specifications
- `plan.md` - Implementation plan
- `api-changes.md` - API updates from frontend

Write to `.claude/team-session/`:
- `backend-tasks.md` - Task status updates
- `blockers.md` - Blocking issues
- `review-feedback/backend.md` - Review responses

## Development Standards

### Layered Architecture

| Layer | Responsibility |
|-------|----------------|
| Controller | HTTP handling, validation, response wrapping |
| Service | Business logic, transaction control |
| Mapper | Database operations |

### Entity Audit Fields (Mandatory)

Every entity must include:
- `id` (Long, @TableId AUTO)
- `createBy` (String, @TableField INSERT)
- `createTime` (LocalDateTime, @TableField INSERT)
- `updateBy` (String, @TableField INSERT_UPDATE)
- `updateTime` (LocalDateTime, @TableField INSERT_UPDATE)
- `isDel` (Integer, @TableLogic)

### Code Style
- Follow Spring Boot best practices
- Use unified response format (Result<T>)
- Implement proper exception handling

## Output

- Controller classes in `controller/`
- Service interfaces and implementations in `service/`
- Mapper interfaces in `mapper/`
- Entity classes in `entity/`
- DTO/VO classes in `dto/` and `vo/`
- Test files in `test/`
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la xo1997-dev/agents/backend-developer.md`
Expected: File exists with correct content

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/agents/backend-developer.md
git commit -m "feat(agents): add backend-developer agent for Spring Boot development"
```

---

## Chunk 2: 基础设施 - 目录结构与模板

### Task 4: 创建前端目录结构

**Files:**
- Create: `xo1997-dev/frontend/skills/` directory
- Create: `xo1997-dev/frontend/references/project-structure.md`

- [ ] **Step 1: 创建目录结构**

```bash
mkdir -p xo1997-dev/frontend/skills
mkdir -p xo1997-dev/frontend/references
```

- [ ] **Step 2: 创建 project-structure.md**

```markdown
# Vue3 Project Structure Reference

Standard directory structure for Vue3 + Vite + Element Plus projects.

## Directory Layout

```
src/
├── api/                    # API request functions
│   ├── modules/            # API modules by feature
│   │   ├── user.js        # User-related APIs
│   │   └── video.js       # Video-related APIs
│   ├── index.js           # API exports
│   └── request.js         # Axios instance configuration
│
├── assets/                 # Static assets
│   ├── images/            # Image files
│   ├── styles/            # Global styles
│   │   ├── index.scss     # Main style entry
│   │   └── variables.scss # SCSS variables
│   └── icons/             # Icon assets
│
├── components/             # Reusable components
│   ├── common/            # Common components
│   │   ├── Button.vue
│   │   └── Modal.vue
│   └── business/          # Business components
│       └── UserTable.vue
│
├── composables/            # Composition API hooks
│   ├── useAuth.js
│   └── usePagination.js
│
├── directives/             # Custom directives
│   └── permission.js
│
├── router/                 # Route configuration
│   ├── index.js           # Router instance
│   └── routes.js          # Route definitions
│
├── stores/                 # Pinia stores
│   ├── index.js           # Store exports
│   ├── user.js            # User store
│   └── app.js             # App store
│
├── utils/                  # Utility functions
│   ├── auth.js            # Authentication utils
│   ├── storage.js         # LocalStorage utils
│   └── validate.js        # Validation utils
│
├── views/                  # Page components
│   ├── home/
│   │   └── Index.vue
│   ├── user/
│   │   ├── List.vue
│   │   └── Detail.vue
│   └── error/
│       └── 404.vue
│
├── App.vue                 # Root component
└── main.js                 # Application entry
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserTable.vue` |
| Views | PascalCase | `UserList.vue` |
| Composables | camelCase with `use` prefix | `useAuth.js` |
| Stores | camelCase with `use` prefix | `useUserStore` |
| Utils | camelCase | `formatDate.js` |
| APIs | camelCase | `fetchUsers.js` |

## File Organization Rules

1. **Co-locate related files** - Keep related components, tests, and styles together
2. **One component per file** - Each `.vue` file contains one component
3. **Index files for exports** - Use `index.js` to export from directories
4. **Test files** - Place `*.spec.js` or `*.test.js` next to source files
```

- [ ] **Step 3: 验证创建**

Run: `ls -la xo1997-dev/frontend/`
Expected: `skills/` and `references/` directories exist

- [ ] **Step 4: Commit**

```bash
git add xo1997-dev/frontend/
git commit -m "feat: add frontend directory structure and project structure reference"
```

---

### Task 5: 创建后端目录结构

**Files:**
- Create: `xo1997-dev/backend/skills/` directory
- Create: `xo1997-dev/backend/references/` directory

- [ ] **Step 1: 创建目录结构**

```bash
mkdir -p xo1997-dev/backend/skills
mkdir -p xo1997-dev/backend/references
```

- [ ] **Step 2: 验证创建**

Run: `ls -la xo1997-dev/backend/`
Expected: `skills/` and `references/` directories exist

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/backend/
git commit -m "feat: add backend directory structure"
```

---

### Task 6: 更新设计文档模板

**Files:**
- Modify: `xo1997-dev/docs/templates/design-document-template.md`

- [ ] **Step 1: 读取现有模板**

Run: `cat xo1997-dev/docs/templates/design-document-template.md`

- [ ] **Step 2: 在 3.3 数据库设计 后添加前端设计章节**

在 `### 3.3 数据库设计` 章节结束后，`---` 分隔线之前，添加以下内容：

```markdown
### 3.4 前端设计（Vue3 项目）

> 本章节用于前端开发设计，如无需前端开发可跳过。

#### 页面结构

| 页面 | 路由 | 组件 | 说明 |
|------|------|------|------|
| [页面名称] | [/path] | views/[module]/[Name].vue | [页面描述] |

#### 组件设计

| 组件名 | 路径 | Props | Emits | 说明 |
|--------|------|-------|-------|------|
| [ComponentName] | components/[module]/[Name].vue | [prop1, prop2] | [event1, event2] | [组件描述] |

#### 状态管理

| Store | 文件 | State | Actions | 说明 |
|-------|------|-------|---------|------|
| use[Name]Store | stores/[name].js | [state1, state2] | [action1, action2] | [Store描述] |

#### API 调用映射

| 页面/组件 | API 函数 | 调用时机 | 说明 |
|-----------|----------|----------|------|
| [Component].vue | [apiFunction] | [onMounted/onSubmit] | [调用说明] |
```

- [ ] **Step 3: 验证更新**

Run: `grep -A 30 "### 3.4 前端设计" xo1997-dev/docs/templates/design-document-template.md`
Expected: New frontend design section appears

- [ ] **Step 4: Commit**

```bash
git add xo1997-dev/docs/templates/design-document-template.md
git commit -m "docs: add frontend design section to design document template"
```

---

## Chunk 3: 后端技能迁移

### Task 7: 迁移 Spring Boot 相关技能

**Files:**
- Move: `xo1997-dev/skills/springboot-best-practices/` → `xo1997-dev/backend/skills/`
- Move: `xo1997-dev/skills/mybatis-plus-patterns/` → `xo1997-dev/backend/skills/`
- Move: `xo1997-dev/skills/springboot-unified-response/` → `xo1997-dev/backend/skills/`

- [ ] **Step 1: 移动 springboot-best-practices**

```bash
mv xo1997-dev/skills/springboot-best-practices xo1997-dev/backend/skills/
```

- [ ] **Step 2: 移动 mybatis-plus-patterns**

```bash
mv xo1997-dev/skills/mybatis-plus-patterns xo1997-dev/backend/skills/
```

- [ ] **Step 3: 移动 springboot-unified-response**

```bash
mv xo1997-dev/skills/springboot-unified-response xo1997-dev/backend/skills/
```

- [ ] **Step 4: 验证迁移**

Run: `ls xo1997-dev/backend/skills/`
Expected: `springboot-best-practices/`, `mybatis-plus-patterns/`, `springboot-unified-response/`

- [ ] **Step 5: Commit**

```bash
git add xo1997-dev/backend/skills/
git add xo1997-dev/skills/
git commit -m "refactor: migrate Spring Boot skills to backend/skills directory"
```

---

## Chunk 4: 前端技能开发

### Task 8: 创建 vue3-best-practices 技能

**Files:**
- Create: `xo1997-dev/frontend/skills/vue3-best-practices/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: vue3-best-practices
description: Use when developing Vue3 projects. Provides best practices for Composition API, lifecycle hooks, reactivity, and Vue3 conventions.
---

# Vue3 Best Practices

## Overview

This skill provides best practices for Vue3 application development using Composition API.

## Composition API

### Script Setup (Recommended)

```vue
<script setup>
import { ref, computed, onMounted } from 'vue'

// Reactive state
const count = ref(0)

// Computed property
const doubled = computed(() => count.value * 2)

// Method
function increment() {
  count.value++
}

// Lifecycle
onMounted(() => {
  console.log('Component mounted')
})
</script>

<template>
  <button @click="increment">{{ count }}</button>
</template>
```

### Reactivity Rules

| Pattern | Use Case |
|---------|----------|
| `ref()` | Primitive values (string, number, boolean) |
| `reactive()` | Objects and arrays |
| `computed()` | Derived state |
| `watch()` | Side effects on state changes |
| `watchEffect()` | Auto-tracked side effects |

### Naming Conventions

```javascript
// Refs: use descriptive names
const isLoading = ref(false)
const userList = ref([])

// Computed: use descriptive names
const filteredUsers = computed(() =>
  userList.value.filter(u => u.active)
)

// Methods: use verb prefixes
function fetchUsers() { }
function handleButtonClick() { }
```

## Component Design

### Props Definition

```javascript
const props = defineProps({
  title: {
    type: String,
    required: true
  },
  maxItems: {
    type: Number,
    default: 10
  }
})
```

### Emits Definition

```javascript
const emit = defineEmits(['update', 'delete'])

function handleUpdate(data) {
  emit('update', data)
}
```

### Slots

```vue
<!-- Parent -->
<template>
  <Card>
    <template #header>
      <h2>Title</h2>
    </template>
    <template #default>
      <p>Content</p>
    </template>
  </Card>
</template>

<!-- Child (Card.vue) -->
<template>
  <div class="card">
    <header><slot name="header" /></header>
    <main><slot /></main>
  </div>
</template>
```

## Lifecycle Hooks

| Hook | Timing | Use Case |
|------|--------|----------|
| `onBeforeMount` | Before DOM mount | Setup |
| `onMounted` | After DOM mount | DOM access, API calls |
| `onBeforeUpdate` | Before re-render | Pre-update logic |
| `onUpdated` | After re-render | DOM-dependent updates |
| `onBeforeUnmount` | Before unmount | Cleanup preparation |
| `onUnmounted` | After unmount | Cleanup, event removal |

## Best Practices Checklist

- [ ] Use `<script setup>` syntax
- [ ] Use `ref()` for primitives, `reactive()` for objects
- [ ] Define props with type and default value
- [ ] Use kebab-case for events
- [ ] Keep components small and focused
- [ ] Extract reusable logic to composables
- [ ] Use `defineExpose` sparingly
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/frontend/skills/vue3-best-practices/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/frontend/skills/vue3-best-practices/
git commit -m "feat(frontend): add vue3-best-practices skill"
```

---

### Task 9: 创建 vue3-project-structure 技能

**Files:**
- Create: `xo1997-dev/frontend/skills/vue3-project-structure/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: vue3-project-structure
description: Use when creating new Vue3 projects or refactoring project structure. Provides standard directory layout and naming conventions.
---

# Vue3 Project Structure

## Standard Directory Layout

```
src/
├── api/                    # API request functions
│   ├── modules/            # API modules by feature
│   ├── index.js           # API exports
│   └── request.js         # Axios instance
├── assets/                 # Static assets
│   ├── images/
│   └── styles/
├── components/             # Reusable components
│   ├── common/            # Generic components
│   └── business/          # Domain-specific
├── composables/            # Composition API hooks
├── directives/             # Custom directives
├── router/                 # Route configuration
├── stores/                 # Pinia stores
├── utils/                  # Utility functions
├── views/                  # Page components
├── App.vue
└── main.js
```

## Directory Responsibilities

| Directory | Purpose | Contains |
|-----------|---------|----------|
| `api/` | API requests | Axios functions, interceptors |
| `assets/` | Static files | Images, fonts, global styles |
| `components/` | Reusable UI | Vue components |
| `composables/` | Shared logic | `use*.js` files |
| `router/` | Navigation | Route definitions |
| `stores/` | State | Pinia stores |
| `utils/` | Helpers | Pure JavaScript functions |
| `views/` | Pages | Route-level components |

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Directory | kebab-case | `user-profile/` |
| Vue file | PascalCase | `UserList.vue` |
| JS file | camelCase | `useAuth.js` |
| Style file | kebab-case | `user-list.scss` |

## Module Organization

For large features, use module-based structure:

```
src/
└── modules/
    └── user/
        ├── api/
        │   └── user.js
        ├── components/
        │   └── UserForm.vue
        ├── stores/
        │   └── user.js
        ├── views/
        │   └── UserList.vue
        └── router.js
```

## When to Create

- `views/` - Route-level pages
- `components/` - Reusable across views
- `composables/` - Shared logic across components
- `stores/` - State shared across views
- `utils/` - Pure functions, no Vue dependencies

## File Size Guidelines

| Type | Max Lines | Action if exceeded |
|------|-----------|-------------------|
| Component | 200 | Split into sub-components |
| Composable | 100 | Split into functions |
| Store | 150 | Split into stores |
| Utils | 50 | Split into modules |
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/frontend/skills/vue3-project-structure/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/frontend/skills/vue3-project-structure/
git commit -m "feat(frontend): add vue3-project-structure skill"
```

---

### Task 10: 创建 vue3-component-dev 技能

**Files:**
- Create: `xo1997-dev/frontend/skills/vue3-component-dev/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: vue3-component-dev
description: Use when developing Vue3 components. Covers component design, Props/Emits, slots, and component testing.
---

# Vue3 Component Development

## Component Design Principles

1. **Single Responsibility** - One component, one purpose
2. **Props Down, Events Up** - Unidirectional data flow
3. **Composition over Inheritance** - Use composables
4. **Explicit over Implicit** - Clear props and events

## Component Template

```vue
<template>
  <div class="component-name">
    <!-- Template content -->
  </div>
</template>

<script setup>
// Imports
import { ref, computed, watch } from 'vue'

// Props
const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['update:modelValue', 'change'])

// Reactive state
const localValue = ref(props.modelValue)

// Computed
const displayValue = computed(() => localValue.value.toUpperCase())

// Watch
watch(() => props.modelValue, (newVal) => {
  localValue.value = newVal
})

// Methods
function handleInput(event) {
  localValue.value = event.target.value
  emit('update:modelValue', localValue.value)
  emit('change', localValue.value)
}
</script>

<style scoped>
.component-name {
  /* Styles */
}
</style>
```

## Props Best Practices

```javascript
// Good: Explicit with type and default
const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
})

// Avoid: Implicit any type
const props = defineProps(['items', 'loading'])
```

## Emits Best Practices

```javascript
// Good: Explicit event names
const emit = defineEmits(['update:modelValue', 'submit', 'cancel'])

// Event handlers
function handleSubmit() {
  emit('submit', { data: localData.value })
}
```

## v-model Implementation

```vue
<!-- CustomInput.vue -->
<script setup>
const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])
</script>

<template>
  <input
    :value="props.modelValue"
    @input="emit('update:modelValue', $event.target.value)"
  />
</template>

<!-- Usage -->
<CustomInput v-model="text" />
```

## Slot Patterns

```vue
<!-- Component with slots -->
<template>
  <div class="card">
    <header class="card-header">
      <slot name="header">
        <h3>Default Title</h3>
      </slot>
    </header>
    <main class="card-body">
      <slot />
    </main>
    <footer class="card-footer">
      <slot name="footer" :actions="{ close, submit }">
        <button @click="close">Close</button>
      </slot>
    </footer>
  </div>
</template>

<!-- Usage with scoped slots -->
<Card>
  <template #header>Custom Title</template>
  <p>Body content</p>
  <template #footer="{ actions }">
    <button @click="actions.submit">Save</button>
  </template>
</Card>
```

## Component Testing

```javascript
// Component.spec.js
import { mount } from '@vue/test-utils'
import Component from './Component.vue'

describe('Component', () => {
  it('renders props correctly', () => {
    const wrapper = mount(Component, {
      props: { title: 'Test' }
    })
    expect(wrapper.text()).toContain('Test')
  })

  it('emits event on click', async () => {
    const wrapper = mount(Component)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })
})
```
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/frontend/skills/vue3-component-dev/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/frontend/skills/vue3-component-dev/
git commit -m "feat(frontend): add vue3-component-dev skill"
```

---

### Task 11: 创建 vue3-api-integration 技能

**Files:**
- Create: `xo1997-dev/frontend/skills/vue3-api-integration/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: vue3-api-integration
description: Use when integrating with backend APIs. Generates API request functions from API definitions in design documents.
---

# Vue3 API Integration

## Overview

This skill helps generate API request functions from design document API definitions.

## Input: Design Document API Definition

```markdown
| 方法 | 路径 | 描述 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| GET | /api/users | 获取用户列表 | - | Result<Page<UserVO>> |
| POST | /api/users | 创建用户 | UserCreateDTO | Result<UserVO> |
| PUT | /api/users/{id} | 更新用户 | UserUpdateDTO | Result<UserVO> |
| DELETE | /api/users/{id} | 删除用户 | - | Result<Void> |
```

## Output: API Request Functions

```javascript
// src/api/user.js
import request from '@/utils/request'

/**
 * 获取用户列表
 * @param {Object} params - 查询参数
 * @returns {Promise<Result<Page<UserVO>>>}
 */
export function fetchUsers(params) {
  return request({
    url: '/api/users',
    method: 'get',
    params
  })
}

/**
 * 创建用户
 * @param {Object} data - UserCreateDTO
 * @returns {Promise<Result<UserVO>>}
 */
export function createUser(data) {
  return request({
    url: '/api/users',
    method: 'post',
    data
  })
}

/**
 * 更新用户
 * @param {number|string} id - 用户ID
 * @param {Object} data - UserUpdateDTO
 * @returns {Promise<Result<UserVO>>}
 */
export function updateUser(id, data) {
  return request({
    url: `/api/users/${id}`,
    method: 'put',
    data
  })
}

/**
 * 删除用户
 * @param {number|string} id - 用户ID
 * @returns {Promise<Result<Void>>}
 */
export function deleteUser(id) {
  return request({
    url: `/api/users/${id}`,
    method: 'delete'
  })
}
```

## Axios Instance Configuration

```javascript
// src/utils/request.js
import axios from 'axios'
import { ElMessage } from 'element-plus'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
request.interceptors.response.use(
  (response) => {
    const { data } = response
    if (data.code !== 200) {
      ElMessage.error(data.message || '请求失败')
      return Promise.reject(new Error(data.message))
    }
    return data
  },
  (error) => {
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default request
```

## Usage in Components

```vue
<script setup>
import { ref, onMounted } from 'vue'
import { fetchUsers, createUser } from '@/api/user'

const users = ref([])
const loading = ref(false)

async function loadUsers() {
  loading.value = true
  try {
    const res = await fetchUsers({ page: 1, size: 10 })
    users.value = res.data.records
  } finally {
    loading.value = false
  }
}

onMounted(loadUsers)
</script>
```

## Mock Data Strategy

When backend API is not ready:

```javascript
// src/api/mock/user.mock.js
export const mockUsers = [
  { id: 1, name: 'User 1', email: 'user1@example.com' },
  { id: 2, name: 'User 2', email: 'user2@example.com' }
]

// src/api/user.js (development)
export async function fetchUsers(params) {
  if (import.meta.env.DEV) {
    return {
      code: 200,
      data: {
        records: mockUsers,
        total: mockUsers.length
      }
    }
  }
  return request({ url: '/api/users', method: 'get', params })
}
```

## Generation Checklist

- [ ] Parse API definition table from design document
- [ ] Generate function with JSDoc comments
- [ ] Use correct HTTP method (GET/POST/PUT/DELETE)
- [ ] Handle path parameters (`{id}`)
- [ ] Use `params` for GET, `data` for POST/PUT
- [ ] Export all functions
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/frontend/skills/vue3-api-integration/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/frontend/skills/vue3-api-integration/
git commit -m "feat(frontend): add vue3-api-integration skill"
```

---

### Task 12: 创建 vue3-state-management 技能

**Files:**
- Create: `xo1997-dev/frontend/skills/vue3-state-management/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: vue3-state-management
description: Use when implementing state management with Pinia or Vuex. Covers store design, best practices, and usage patterns.
---

# Vue3 State Management

## Pinia (Recommended)

### Store Definition

```javascript
// stores/user.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { fetchUsers, createUser } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  // State
  const users = ref([])
  const currentUser = ref(null)
  const loading = ref(false)

  // Getters
  const activeUsers = computed(() =>
    users.value.filter(u => u.status === 'active')
  )

  const userCount = computed(() => users.value.length)

  // Actions
  async function fetchUserList(params) {
    loading.value = true
    try {
      const res = await fetchUsers(params)
      users.value = res.data.records
    } finally {
      loading.value = false
    }
  }

  async function add(userData) {
    const res = await createUser(userData)
    users.value.push(res.data)
    return res.data
  }

  function reset() {
    users.value = []
    currentUser.value = null
  }

  return {
    // State
    users,
    currentUser,
    loading,
    // Getters
    activeUsers,
    userCount,
    // Actions
    fetchUserList,
    add,
    reset
  }
})
```

### Store Usage

```vue
<script setup>
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// Reactive state and getters
const { users, loading, activeUsers } = storeToRefs(userStore)

// Actions (non-reactive)
const { fetchUserList, add } = userStore

// Usage
onMounted(() => fetchUserList({ page: 1 }))

async function handleAdd(userData) {
  await add(userData)
}
</script>
```

## Vuex (Legacy Projects)

### Store Definition

```javascript
// store/index.js
import { createStore } from 'vuex'

export default createStore({
  state: {
    users: [],
    currentUser: null
  },
  getters: {
    activeUsers: (state) => state.users.filter(u => u.status === 'active')
  },
  mutations: {
    SET_USERS(state, users) {
      state.users = users
    },
    SET_CURRENT_USER(state, user) {
      state.currentUser = user
    }
  },
  actions: {
    async fetchUsers({ commit }, params) {
      const res = await fetchUsers(params)
      commit('SET_USERS', res.data.records)
    }
  }
})
```

### Vuex Usage

```vue
<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'

const store = useStore()

// State
const users = computed(() => store.state.users)

// Getters
const activeUsers = computed(() => store.getters.activeUsers)

// Actions
await store.dispatch('fetchUsers', { page: 1 })
</script>
```

## When to Use State Management

| Scenario | Recommendation |
|----------|----------------|
| Component-local state | `ref()` / `reactive()` |
| Parent-child sharing | Props / Emits |
| Sibling components | Pinia store |
| Cross-page state | Pinia store |
| User session | Pinia store (persisted) |
| Form state | Local or Pinia |

## Best Practices

1. **One store per domain** - `useUserStore`, `useProductStore`
2. **Keep stores small** - Split large stores
3. **Use composables for logic** - Extract reusable logic
4. **Don't over-use stores** - Local state is fine
5. **Persist when needed** - Use `pinia-plugin-persistedstate`

## Persistence Example

```javascript
import { defineStore } from 'pinia'
import { persist } from 'pinia-plugin-persistedstate'

export const useAuthStore = defineStore('auth', () => {
  const token = ref('')
  const user = ref(null)

  return { token, user }
}, {
  persist: {
    key: 'auth',
    paths: ['token', 'user']
  }
})
```
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/frontend/skills/vue3-state-management/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/frontend/skills/vue3-state-management/
git commit -m "feat(frontend): add vue3-state-management skill"
```

---

### Task 13: 创建 vue3-testing 技能

**Files:**
- Create: `xo1997-dev/frontend/skills/vue3-testing/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: vue3-testing
description: Use when writing tests for Vue3 applications. Covers Vitest setup, component testing, and API mocking.
---

# Vue3 Testing

## Vitest Setup

```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html']
    }
  }
})
```

## Component Testing

### Basic Test

```javascript
// components/__tests__/Button.spec.js
import { mount } from '@vue/test-utils'
import Button from '../Button.vue'

describe('Button', () => {
  it('renders slot content', () => {
    const wrapper = mount(Button, {
      slots: { default: 'Click me' }
    })
    expect(wrapper.text()).toBe('Click me')
  })

  it('emits click event', async () => {
    const wrapper = mount(Button)
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })

  it('is disabled when prop is true', () => {
    const wrapper = mount(Button, {
      props: { disabled: true }
    })
    expect(wrapper.find('button').element.disabled).toBe(true)
  })
})
```

### Testing Props

```javascript
it('displays user name from prop', () => {
  const wrapper = mount(UserCard, {
    props: { user: { name: 'John', email: 'john@example.com' } }
  })
  expect(wrapper.text()).toContain('John')
  expect(wrapper.text()).toContain('john@example.com')
})
```

### Testing Events

```javascript
it('emits submit event with form data', async () => {
  const wrapper = mount(UserForm)

  await wrapper.find('input[name="name"]').setValue('John')
  await wrapper.find('form').trigger('submit.prevent')

  expect(wrapper.emitted('submit')).toBeTruthy()
  expect(wrapper.emitted('submit')[0][0]).toEqual({ name: 'John' })
})
```

### Testing Slots

```javascript
it('renders named slots', () => {
  const wrapper = mount(Card, {
    slots: {
      header: '<h2>Title</h2>',
      default: '<p>Content</p>',
      footer: '<button>OK</button>'
    }
  })

  expect(wrapper.html()).toContain('<h2>Title</h2>')
  expect(wrapper.html()).toContain('<p>Content</p>')
  expect(wrapper.html()).toContain('<button>OK</button>')
})
```

## API Mocking

### Mocking API Calls

```javascript
import { vi } from 'vitest'
import { mount } from '@vue/test-utils'
import UserList from '../UserList.vue'
import * as api from '@/api/user'

vi.mock('@/api/user')

describe('UserList', () => {
  beforeEach(() => {
    vi.resetAllMocks()
  })

  it('loads users on mount', async () => {
    const mockUsers = [{ id: 1, name: 'John' }]
    api.fetchUsers.mockResolvedValue({
      code: 200,
      data: { records: mockUsers }
    })

    const wrapper = mount(UserList)
    await wrapper.vm.$nextTick()

    expect(api.fetchUsers).toHaveBeenCalled()
    expect(wrapper.text()).toContain('John')
  })
})
```

### Mocking Pinia Store

```javascript
import { createTestingPinia } from '@pinia/testing'

it('displays users from store', () => {
  const wrapper = mount(UserList, {
    global: {
      plugins: [
        createTestingPinia({
          initialState: {
            user: {
              users: [{ id: 1, name: 'John' }]
            }
          }
        })
      ]
    }
  })

  expect(wrapper.text()).toContain('John')
})
```

## Testing Commands

```bash
# Run all tests
vitest

# Run specific file
vitest run UserList.spec.js

# Run with coverage
vitest run --coverage

# Watch mode
vitest watch
```

## Test Structure Checklist

- [ ] Describe block with component name
- [ ] Test groupings by feature/behavior
- [ ] Clear test descriptions (should/when/it)
- [ ] Arrange-Act-Assert pattern
- [ ] Proper cleanup in afterEach if needed
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/frontend/skills/vue3-testing/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/frontend/skills/vue3-testing/
git commit -m "feat(frontend): add vue3-testing skill"
```

---

## Chunk 5: Team 开发模式

### Task 14: 创建 team-driven-development 技能

**Files:**
- Create: `xo1997-dev/skills/team-driven-development/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

```markdown
---
name: team-driven-development
description: |
  Use when implementing features that involve both frontend and backend development.
  Orchestrates multiple agents (team-coordinator, frontend-developer, backend-developer)
  for parallel development with coordination.
---

# Team-Driven Development

## Overview

This skill orchestrates frontend-backend collaborative development using an Agent Team model.

## When to Use

- Implementation plan involves both frontend and backend tasks
- Frontend and backend can be developed in parallel
- API contract is defined in design document

## Agent Roles

| Agent | Role |
|-------|------|
| `team-coordinator` | Orchestration, progress monitoring, code review |
| `frontend-developer` | Vue3 component and page implementation |
| `backend-developer` | Spring Boot API implementation |

## Process Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Team-Driven Development                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Initialize Team Session                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Create .claude/team-session/ directory                 │   │
│  │ • Copy design document to design-doc.md                   │   │
│  │ • Copy implementation plan to plan.md                     │   │
│  │ • Initialize task status files                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  Step 2: Analyze & Distribute Tasks                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • team-coordinator analyzes task dependencies             │   │
│  │ • Identify parallel vs sequential tasks                   │   │
│  │ • Dispatch tasks to frontend-developer and backend-developer│
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│           ┌───────────────┴───────────────┐                      │
│           ▼                               ▼                      │
│  Step 3: Parallel Development                                    │
│  ┌─────────────────────┐    ┌─────────────────────┐             │
│  │ frontend-developer  │    │ backend-developer   │             │
│  │ • Implement pages   │    │ • Implement APIs    │             │
│  │ • Create components │    │ • Write Services    │             │
│  │ • Follow TDD        │    │ • Follow TDD        │             │
│  │ • Update status     │    │ • Update status     │             │
│  └─────────────────────┘    └─────────────────────┘             │
│           │                               │                      │
│           └───────────────┬───────────────┘                      │
│                           ▼                                      │
│  Step 4: Code Review (per completion)                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • team-coordinator reviews completed work                 │   │
│  │ • Stage 1: Specification compliance                       │   │
│  │ • Stage 2: Code quality                                   │   │
│  │ • Provide feedback or approve                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  Step 5: API Change Synchronization (if needed)                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Detect API changes in api-changes.md                    │   │
│  │ • team-coordinator notifies affected party                │   │
│  │ • Update design document                                   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  Step 6: Integration Testing                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • team-coordinator coordinates integration                │   │
│  │ • Verify frontend-backend API contracts                   │   │
│  │ • Test complete user workflows                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  Step 7: Finalize                                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • All tests pass                                          │   │
│  │ • Call finishing-a-development-branch skill               │   │
│  │ • Handle branch merge/PR                                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Communication Files

Create in `.claude/team-session/`:

```
.claude/team-session/
├── design-doc.md           # Design document (read-only)
├── plan.md                 # Implementation plan (read-only)
├── frontend-tasks.md       # Frontend task status
├── backend-tasks.md        # Backend task status
├── api-changes.md          # API change records
├── blockers.md             # Blocking issues
└── review-feedback/
    ├── frontend.md         # Review feedback for frontend
    └── backend.md          # Review feedback for backend
```

## Task Status Format

```markdown
# Frontend Tasks

## Task 1: UserList Page
- Status: in_progress | completed | blocked
- Started: 2026-03-17 10:00
- Completed: 2026-03-17 11:30
- Output: src/views/user/UserList.vue

## Task 2: UserForm Component
- Status: pending
- Depends on: Task 1
```

## API Change Format

```markdown
# API Changes

## 2026-03-17 11:00 - Backend Request

### Change
- Endpoint: POST /api/users
- Field added: `phone` (optional)

### Reason
- User requested phone number collection

### Status: pending_review
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Agent fails | Coordinator logs error, retries or escalates |
| Partial completion | Preserve work, record pending tasks |
| API conflict | Coordinator arbitrates, first-submitter priority |
| Timeout (>30 min) | Coordinator checks progress, decides action |

## Skill Invocation

```markdown
When team-driven-development is invoked:

1. Load team-coordinator agent
2. Initialize team session directory
3. Begin Step 1 of process flow
4. Coordinator dispatches agents as needed
5. Monitor and coordinate until completion
```
```

- [ ] **Step 2: 验证创建**

Run: `ls xo1997-dev/skills/team-driven-development/`
Expected: `SKILL.md` exists

- [ ] **Step 3: Commit**

```bash
git add xo1997-dev/skills/team-driven-development/
git commit -m "feat(skills): add team-driven-development skill for frontend-backend collaboration"
```

---

### Task 15: 更新 writing-plans 技能

**Files:**
- Modify: `xo1997-dev/skills/writing-plans/SKILL.md`

- [ ] **Step 1: 读取现有文件**

Run: `head -50 xo1997-dev/skills/writing-plans/SKILL.md`

- [ ] **Step 2: 在 Execution Handoff 章节后添加执行模式选择逻辑**

在现有 `## Execution Handoff` 章节后添加：

```markdown
## Execution Mode Selection

After the plan is complete, determine the appropriate execution mode based on task scope:

### Decision Logic

```
Plan Analysis
    │
    ├─ Task Scope?
    │       │
    │       ├─ Backend Only → subagent-driven-development
    │       │
    │       ├─ Frontend Only → subagent-driven-development
    │       │
    │       └─ Frontend + Backend → team-driven-development
    │
    └─ See: Execution Mode Decision Tree below
```

### Decision Tree

```markdown
1. Analyze all tasks in the plan
2. Identify task types:
   - Frontend tasks: Vue components, pages, API calls, stores
   - Backend tasks: Controllers, Services, Mappers, Entities
3. Determine execution mode:

| Frontend Tasks | Backend Tasks | Execution Mode |
|----------------|---------------|----------------|
| Yes | No | subagent-driven-development |
| No | Yes | subagent-driven-development |
| Yes | Yes | team-driven-development |

4. Announce the execution mode to the user
```

### Execution Mode Announcements

**For single-end development:**
> "Plan complete. This involves [frontend/backend] development only. Ready to execute with subagent-driven-development?"

**For team development:**
> "Plan complete. This involves both frontend and backend development. Ready to execute with team-driven-development (Agent Team mode)?"

### Task Labeling

When writing plans that involve both frontend and backend, label tasks clearly:

```markdown
### Task N: [Component Name] (Frontend)

### Task M: [API Name] (Backend)
```

This allows team-driven-development to properly distribute tasks to the appropriate agents.
```

- [ ] **Step 3: 验证更新**

Run: `grep -A 30 "## Execution Mode Selection" xo1997-dev/skills/writing-plans/SKILL.md`
Expected: New execution mode section appears

- [ ] **Step 4: Commit**

```bash
git add xo1997-dev/skills/writing-plans/SKILL.md
git commit -m "feat(writing-plans): add execution mode selection logic for frontend/backend tasks"
```

---

## Chunk 6: 集成与验证

### Task 16: 验证完整目录结构

**Files:**
- Verify: Complete directory structure

- [ ] **Step 1: 验证目录结构**

```bash
echo "=== Plugin Root ===" && ls xo1997-dev/
echo "=== Agents ===" && ls xo1997-dev/agents/
echo "=== Frontend Skills ===" && ls xo1997-dev/frontend/skills/
echo "=== Backend Skills ===" && ls xo1997-dev/backend/skills/
echo "=== Core Skills ===" && ls xo1997-dev/skills/
```

Expected Output:
```
=== Plugin Root ===
agents/  backend/  commands/  docs/  frontend/  hooks/  skills/  ...

=== Agents ===
backend-developer.md  code-reviewer.md  frontend-developer.md  team-coordinator.md

=== Frontend Skills ===
vue3-api-integration/  vue3-best-practices/  vue3-component-dev/
vue3-project-structure/  vue3-state-management/  vue3-testing/

=== Backend Skills ===
mybatis-plus-patterns/  springboot-best-practices/  springboot-unified-response/

=== Core Skills ===
brainstorming/  executing-plans/  finishing-a-development-branch/
subagent-driven-development/  systematic-debugging/  team-driven-development/
test-driven-development/  using-git-worktrees/  using-xo1997-dev/
verification-before-completion/  writing-plans/  writing-skills/
...
```

- [ ] **Step 2: 最终提交**

```bash
git add -A
git status
```

Verify all changes are staged.

- [ ] **Step 3: 创建总结提交**

```bash
git commit -m "$(cat <<'EOF'
feat: add Vue3 frontend development workflow and Agent Team collaboration

## New Features

### Agent Team
- team-coordinator: Orchestrates frontend-backend collaboration
- frontend-developer: Vue3 + Vite + Element Plus development
- backend-developer: Spring Boot + MyBatis-Plus development

### Frontend Skills
- vue3-best-practices: Composition API, lifecycle, reactivity
- vue3-project-structure: Directory layout, naming conventions
- vue3-component-dev: Props/Emits, slots, testing
- vue3-api-integration: API code generation from design docs
- vue3-state-management: Pinia/Vuex store patterns
- vue3-testing: Vitest component testing

### Team Development
- team-driven-development skill for parallel frontend-backend development
- writing-plans: Execution mode selection based on task scope

### Template Enhancement
- Design document template: Added frontend design section

### Backend Migration
- Moved springboot-* skills to backend/skills/ directory
EOF
)"
```

---

## 任务总结

| Phase | Tasks | Description |
|-------|-------|-------------|
| Chunk 1 | 1-3 | Agent 定义 |
| Chunk 2 | 4-6 | 目录结构与模板 |
| Chunk 3 | 7 | 后端技能迁移 |
| Chunk 4 | 8-13 | 前端技能开发 |
| Chunk 5 | 14-15 | Team 开发模式 |
| Chunk 6 | 16 | 集成验证 |

**总任务数**: 16
**预计完成时间**: 按顺序执行，每个 Chunk 可并行化