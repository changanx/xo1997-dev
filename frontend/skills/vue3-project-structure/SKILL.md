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