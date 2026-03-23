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
│   │   └── HomeIndex.vue
│   ├── user/
│   │   ├── UserList.vue
│   │   └── UserDetail.vue
│   └── error/
│       └── NotFound.vue
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