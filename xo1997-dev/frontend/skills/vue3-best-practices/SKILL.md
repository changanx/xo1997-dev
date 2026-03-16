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