---
name: vue3-state-management
description: Use when developing state management with Pinia or Vuex. Covers store design, actions, getters, and persistence patterns.
---

# Vue3 State Management

## Overview

Vue3 state management using Pinia (recommended) or Vuex. Pinia is the official recommendation for Vue3 projects.

## Directory Structure

```
src/stores/
├── index.js              # Store exports
├── user.js               # User store
├── app.js                # App-level store
└── modules/              # Feature-specific stores
    └── permission.js
```

## Pinia Setup

### Install Pinia

```bash
npm install pinia
# or
yarn add pinia
```

### Main Entry Configuration

```javascript
// src/main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.mount('#app')
```

## Store Template

```javascript
// src/stores/user.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { fetchUsers, fetchUserById, updateUser } from '@/api'
import { getToken, setToken, removeToken } from '@/utils/auth'

// Composition API style (recommended)
export const useUserStore = defineStore('user', () => {
  // State
  const token = ref(getToken() || '')
  const userInfo = ref(null)
  const users = ref([])
  const loading = ref(false)

  // Getters
  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => userInfo.value?.username || 'Guest')
  const userCount = computed(() => users.value.length)

  // Actions
  async function login(credentials) {
    loading.value = true
    try {
      const result = await fetch('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify(credentials)
      }).then(r => r.json())

      token.value = result.token
      userInfo.value = result.user
      setToken(result.token)
    } finally {
      loading.value = false
    }
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    removeToken()
  }

  async function fetchUserList(params) {
    loading.value = true
    try {
      const result = await fetchUsers(params)
      users.value = result.list
      return result
    } finally {
      loading.value = false
    }
  }

  async function updateUserInfo(id, data) {
    loading.value = true
    try {
      const result = await updateUser(id, data)
      userInfo.value = result
      return result
    } finally {
      loading.value = false
    }
  }

  // Reset state
  function $reset() {
    token.value = ''
    userInfo.value = null
    users.value = []
    loading.value = false
  }

  return {
    // State
    token,
    userInfo,
    users,
    loading,
    // Getters
    isLoggedIn,
    userName,
    userCount,
    // Actions
    login,
    logout,
    fetchUserList,
    updateUserInfo,
    $reset
  }
})
```

## Using Store in Components

```vue
<script setup>
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// Destructure state and getters (must use storeToRefs for reactivity)
const { userInfo, users, loading, isLoggedIn } = storeToRefs(userStore)

// Destructure actions directly (no storeToRefs needed)
const { login, logout, fetchUserList } = userStore

// Usage
onMounted(() => {
  fetchUserList({ pageNum: 1, pageSize: 10 })
})
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else>
    <p v-if="isLoggedIn">Welcome, {{ userInfo.username }}</p>
    <button @click="logout">Logout</button>
  </div>
</template>
```

## Store Best Practices

### 1. Use Composition API Style

```javascript
// Good: Composition API (recommended)
export const useUserStore = defineStore('user', () => {
  const count = ref(0)
  const double = computed(() => count.value * 2)
  function increment() { count.value++ }
  return { count, double, increment }
})

// Acceptable: Options API
export const useUserStore = defineStore('user', {
  state: () => ({ count: 0 }),
  getters: {
    double: (state) => state.count * 2
  },
  actions: {
    increment() { this.count++ }
  }
})
```

### 2. Keep Stores Focused

```javascript
// Good: Single responsibility
// stores/user.js - User authentication and profile
// stores/permission.js - User permissions and roles
// stores/app.js - App-level state (sidebar, theme)

// Avoid: God store
// stores/global.js - Everything mixed together
```

### 3. Handle Async in Actions, Not Getters

```javascript
// Good: Async in actions
async function fetchUser() {
  const result = await fetchUserApi()
  userInfo.value = result
}

// Avoid: Async in getters (not supported)
const userInfo = computed(async () => {
  return await fetchUserApi() // Wrong!
})
```

### 4. Use storeToRefs for Destructuring

```javascript
// Good: Use storeToRefs for state/getters
import { storeToRefs } from 'pinia'
const { users, loading } = storeToRefs(userStore)

// Wrong: Direct destructuring loses reactivity
const { users, loading } = userStore // Not reactive!
```

## State Persistence

Using `pinia-plugin-persistedstate`:

```javascript
// src/main.js
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)
```

```javascript
// stores/user.js
export const useUserStore = defineStore('user', () => {
  // ... store definition
}, {
  persist: {
    key: 'user-store',
    storage: localStorage,
    paths: ['token', 'userInfo'] // Only persist these
  }
})
```

## Cross-Store Communication

```javascript
// stores/permission.js
import { useUserStore } from './user'

export const usePermissionStore = defineStore('permission', () => {
  const permissions = ref([])

  async function fetchPermissions() {
    const userStore = useUserStore()
    // Use data from user store
    const userId = userStore.userInfo.id

    const result = await fetchPermissionsApi(userId)
    permissions.value = result
  }

  return { permissions, fetchPermissions }
})
```

## Testing Stores

```javascript
// stores/__tests__/user.spec.js
import { setActivePinia, createPinia } from 'pinia'
import { describe, beforeEach, it, expect } from 'vitest'
import { useUserStore } from '../user'

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('initializes with empty state', () => {
    const store = useUserStore()
    expect(store.token).toBe('')
    expect(store.isLoggedIn).toBe(false)
  })

  it('updates token on login', async () => {
    const store = useUserStore()
    await store.login({ username: 'test', password: '123' })
    expect(store.isLoggedIn).toBe(true)
  })

  it('clears state on logout', () => {
    const store = useUserStore()
    store.token = 'test-token'
    store.logout()
    expect(store.token).toBe('')
  })
})
```