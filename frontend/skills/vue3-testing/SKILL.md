---
name: vue3-testing
description: Use when testing Vue3 components and applications. Covers Vitest setup, component testing, and E2E testing patterns.
---

# Vue3 Testing

## Overview

Vue3 testing using Vitest for unit/component testing and Playwright or Cypress for E2E testing.

## Vitest Setup

### Installation

```bash
npm install -D vitest @vue/test-utils jsdom @vitest/coverage-v8
```

### Configuration

```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/**/*.spec.js',
        'src/**/*.test.js'
      ]
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

### Package Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

## Component Testing

### Basic Component Test

```javascript
// src/components/__tests__/Button.spec.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Button from '../Button.vue'

describe('Button', () => {
  it('renders with default props', () => {
    const wrapper = mount(Button)
    expect(wrapper.find('button').exists()).toBe(true)
  })

  it('displays label text', () => {
    const wrapper = mount(Button, {
      props: { label: 'Click Me' }
    })
    expect(wrapper.text()).toContain('Click Me')
  })

  it('applies variant class', () => {
    const wrapper = mount(Button, {
      props: { variant: 'primary' }
    })
    expect(wrapper.find('button').classes()).toContain('btn-primary')
  })

  it('emits click event', async () => {
    const wrapper = mount(Button)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })

  it('disables button when disabled prop is true', () => {
    const wrapper = mount(Button, {
      props: { disabled: true }
    })
    expect(wrapper.find('button').attributes('disabled')).toBeDefined()
  })
})
```

### Testing Props and Emits

```javascript
// src/components/__tests__/Input.spec.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Input from '../Input.vue'

describe('Input', () => {
  it('binds v-model correctly', async () => {
    const wrapper = mount(Input, {
      props: {
        modelValue: 'initial',
        'onUpdate:modelValue': (e) => wrapper.setProps({ modelValue: e })
      }
    })

    const input = wrapper.find('input')
    expect(input.element.value).toBe('initial')

    await input.setValue('new value')
    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')[0]).toEqual(['new value'])
  })

  it('validates required prop', async () => {
    const wrapper = mount(Input, {
      props: { required: true, modelValue: '' }
    })

    await wrapper.find('form').trigger('submit')
    expect(wrapper.find('.error-message').exists()).toBe(true)
  })
})
```

### Testing Slots

```javascript
// src/components/__tests__/Card.spec.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Card from '../Card.vue'

describe('Card', () => {
  it('renders default slot', () => {
    const wrapper = mount(Card, {
      slots: {
        default: 'Card content'
      }
    })
    expect(wrapper.text()).toContain('Card content')
  })

  it('renders named slots', () => {
    const wrapper = mount(Card, {
      slots: {
        header: '<h2>Title</h2>',
        default: '<p>Body</p>',
        footer: '<button>Action</button>'
      }
    })
    expect(wrapper.html()).toContain('<h2>Title</h2>')
    expect(wrapper.html()).toContain('<p>Body</p>')
    expect(wrapper.html()).toContain('<button>Action</button>')
  })

  it('receives scoped slot data', () => {
    const wrapper = mount(Card, {
      slots: {
        default: ({ item }) => `<span>${item.name}</span>`
      }
    })
    // Test scoped slot rendering
  })
})
```

### Testing with Pinia Store

```javascript
// src/components/__tests__/UserProfile.spec.js
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import UserProfile from '../UserProfile.vue'
import { useUserStore } from '@/stores/user'

// Mock the API
vi.mock('@/api', () => ({
  fetchUser: vi.fn(() => Promise.resolve({ id: 1, name: 'Test User' }))
}))

describe('UserProfile', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('displays user info from store', async () => {
    const wrapper = mount(UserProfile)
    const store = useUserStore()

    // Set store state
    store.userInfo = { id: 1, name: 'John Doe', email: 'john@example.com' }

    await wrapper.vm.$nextTick()

    expect(wrapper.text()).toContain('John Doe')
    expect(wrapper.text()).toContain('john@example.com')
  })
})
```

### Testing Vue Router

```javascript
// src/components/__tests__/Navigation.spec.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createWebHistory } from 'vue-router'
import Navigation from '../Navigation.vue'

describe('Navigation', () => {
  it('navigates to correct route on click', async () => {
    const router = createRouter({
      history: createWebHistory(),
      routes: [
        { path: '/', component: { template: '<div>Home</div>' } },
        { path: '/about', component: { template: '<div>About</div>' } }
      ]
    })

    const wrapper = mount(Navigation, {
      global: {
        plugins: [router]
      }
    })

    await router.push('/about')
    await router.isReady()

    expect(wrapper.find('a.active').text()).toBe('About')
  })
})
```

### Testing Async Components

```javascript
// src/components/__tests__/AsyncList.spec.js
import { describe, it, expect, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import AsyncList from '../AsyncList.vue'

describe('AsyncList', () => {
  it('shows loading state', async () => {
    vi.useFakeTimers()

    const wrapper = mount(AsyncList)

    expect(wrapper.find('.loading').exists()).toBe(true)

    vi.advanceTimersByTime(1000)
    await flushPromises()

    expect(wrapper.find('.loading').exists()).toBe(false)
    expect(wrapper.findAll('.list-item').length).toBeGreaterThan(0)

    vi.useRealTimers()
  })
})
```

## Testing Composables

```javascript
// src/composables/__tests__/useCounter.spec.js
import { describe, it, expect } from 'vitest'
import { useCounter } from '../useCounter'

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { count } = useCounter()
    expect(count.value).toBe(0)
  })

  it('initializes with custom value', () => {
    const { count } = useCounter(10)
    expect(count.value).toBe(10)
  })

  it('increments count', () => {
    const { count, increment } = useCounter()
    increment()
    expect(count.value).toBe(1)
  })

  it('decrements count', () => {
    const { count, decrement } = useCounter(5)
    decrement()
    expect(count.value).toBe(4)
  })
})
```

## E2E Testing (Playwright)

### Setup

```bash
npm install -D @playwright/test
npx playwright install
```

### Configuration

```javascript
// playwright.config.js
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  baseURL: 'http://localhost:5173',
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    }
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI
  }
})
```

### E2E Test Example

```javascript
// e2e/login.spec.js
import { test, expect } from '@playwright/test'

test.describe('Login Flow', () => {
  test('user can login with valid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.fill('[data-testid="username"]', 'testuser')
    await page.fill('[data-testid="password"]', 'password123')
    await page.click('[data-testid="login-button"]')

    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('[data-testid="user-name"]')).toContainText('Test User')
  })

  test('shows error with invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.fill('[data-testid="username"]', 'wronguser')
    await page.fill('[data-testid="password"]', 'wrongpass')
    await page.click('[data-testid="login-button"]')

    await expect(page.locator('.el-message--error')).toBeVisible()
  })
})
```

## Test Best Practices

### 1. Use data-testid for E2E

```vue
<!-- Good: Use data-testid -->
<button data-testid="submit-button">Submit</button>
<input data-testid="email-input" type="email" />

<!-- Avoid: Relying on CSS classes -->
<button class="btn btn-primary">Submit</button>
```

### 2. Test User Behavior, Not Implementation

```javascript
// Good: Test behavior
it('submits form when button clicked', async () => {
  const wrapper = mount(Form)
  await wrapper.find('[data-testid="submit"]').trigger('click')
  expect(wrapper.emitted('submit')).toBeTruthy()
})

// Avoid: Test implementation details
it('calls internalSubmit method', async () => {
  const wrapper = mount(Form)
  const spy = vi.spyOn(wrapper.vm, 'internalSubmit')
  await wrapper.find('button').trigger('click')
  expect(spy).toHaveBeenCalled()
})
```

### 3. Use Descriptive Test Names

```javascript
// Good
it('displays error message when email is invalid', () => {})
it('redirects to dashboard after successful login', () => {})

// Avoid
it('works', () => {})
it('test1', () => {})
```

### 4. Keep Tests Isolated

```javascript
// Good: Fresh store per test
beforeEach(() => {
  setActivePinia(createPinia())
})

// Avoid: Shared state between tests
let store
beforeAll(() => {
  store = createPinia()
})
```

## Coverage Guidelines

| Type | Target |
|------|--------|
| Statements | 70%+ |
| Branches | 60%+ |
| Functions | 70%+ |
| Lines | 70%+ |

Focus coverage on:
- Business logic
- Utility functions
- Store actions
- Critical user flows