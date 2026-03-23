---
name: vue3-api-integration
description: Use when frontend needs to integrate with backend APIs. Covers API function generation, Axios configuration, and type definitions.
---

# Vue3 API Integration

## Overview

This skill guides API integration for Vue3 + Vite + Element Plus projects, generating API request functions from backend API definitions.

## API Directory Structure

```
src/api/
├── modules/               # API modules by feature
│   ├── user.js           # User-related APIs
│   └── video.js          # Video-related APIs
├── request.js            # Axios instance configuration
└── index.js              # API exports
```

## Axios Instance Configuration

```javascript
// src/api/request.js
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'

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
    const token = getToken()
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
request.interceptors.response.use(
  (response) => {
    const { data } = response
    // Assuming backend returns Result<T> format
    if (data.code === 200 || data.code === 0) {
      return data.data
    }
    // Business error
    ElMessage.error(data.message || 'Request failed')
    return Promise.reject(new Error(data.message || 'Request failed'))
  },
  (error) => {
    const { response } = error
    let message = 'Network error'

    if (response) {
      switch (response.status) {
        case 401:
          message = 'Unauthorized, please login'
          // Redirect to login
          break
        case 403:
          message = 'Access denied'
          break
        case 404:
          message = 'Resource not found'
          break
        case 500:
          message = 'Server error'
          break
        default:
          message = response.data?.message || 'Request failed'
      }
    }

    ElMessage.error(message)
    return Promise.reject(error)
  }
)

export default request
```

## API Function Template

Based on backend API definitions, generate corresponding API functions:

```javascript
// src/api/modules/user.js
import request from '../request'

/**
 * Get user list with pagination
 * @param {Object} params - Query parameters
 * @param {number} params.pageNum - Page number
 * @param {number} params.pageSize - Page size
 * @param {string} params.keyword - Search keyword
 * @returns {Promise<{list: UserVO[], total: number}>}
 */
export function fetchUsers(params) {
  return request({
    url: '/users',
    method: 'get',
    params
  })
}

/**
 * Get user by ID
 * @param {number} id - User ID
 * @returns {Promise<UserVO>}
 */
export function fetchUserById(id) {
  return request({
    url: `/users/${id}`,
    method: 'get'
  })
}

/**
 * Create user
 * @param {Object} data - UserCreateDTO
 * @param {string} data.username - Username
 * @param {string} data.email - Email
 * @param {string} data.phone - Phone number
 * @returns {Promise<UserVO>}
 */
export function createUser(data) {
  return request({
    url: '/users',
    method: 'post',
    data
  })
}

/**
 * Update user
 * @param {number} id - User ID
 * @param {Object} data - UserUpdateDTO
 * @returns {Promise<UserVO>}
 */
export function updateUser(id, data) {
  return request({
    url: `/users/${id}`,
    method: 'put',
    data
  })
}

/**
 * Delete user
 * @param {number} id - User ID
 * @returns {Promise<void>}
 */
export function deleteUser(id) {
  return request({
    url: `/users/${id}`,
    method: 'delete'
  })
}
```

## API Index Exports

```javascript
// src/api/index.js
export * from './modules/user'
export * from './modules/video'
// Add more module exports as needed
```

## Using APIs in Components

```vue
<script setup>
import { ref, onMounted } from 'vue'
import { fetchUsers, createUser } from '@/api'

const users = ref([])
const loading = ref(false)
const total = ref(0)

const queryParams = {
  pageNum: 1,
  pageSize: 10
}

async function loadUsers() {
  loading.value = true
  try {
    const result = await fetchUsers(queryParams)
    users.value = result.list
    total.value = result.total
  } catch (error) {
    console.error('Failed to load users:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadUsers()
})
</script>
```

## TypeScript Type Definitions (Optional)

If using TypeScript, create type definition files:

```typescript
// src/api/types/user.ts

export interface UserVO {
  id: number
  username: string
  email: string
  phone: string
  status: number
  createTime: string
}

export interface UserCreateDTO {
  username: string
  email: string
  phone: string
  password: string
}

export interface UserUpdateDTO {
  username?: string
  email?: string
  phone?: string
  status?: number
}

export interface PageResult<T> {
  list: T[]
  total: number
}

// API function types
export type FetchUsersParams = {
  pageNum: number
  pageSize: number
  keyword?: string
}

export type FetchUsersResult = PageResult<UserVO>
```

## API Generation from Backend Spec

When given backend API definitions like:

```
| POST | /api/users | Create user | UserCreateDTO | Result<UserVO> |
| GET | /api/users | Get user list | - | Result<Page<UserVO>> |
| PUT | /api/users/{id} | Update user | UserUpdateDTO | Result<UserVO> |
| DELETE | /api/users/{id} | Delete user | - | Result<Void> |
```

Generate:
1. API function with JSDoc comments
2. Request/response type definitions (if TS)
3. Error handling via interceptor

## Best Practices

1. **Naming Convention**
   - `fetch*` for GET requests
   - `create*` for POST requests
   - `update*` for PUT requests
   - `delete*` for DELETE requests

2. **Error Handling**
   - Let interceptor handle common errors
   - Handle business-specific errors in component
   - Use try-catch in async functions

3. **Loading State**
   - Always show loading state during API calls
   - Use Element Plus `v-loading` directive

4. **Request Cancellation**
   - Use AbortController for cancellable requests
   - Cancel pending requests when component unmounts