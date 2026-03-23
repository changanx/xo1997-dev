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
import { ref, computed } from 'vue'

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

// Computed with getter/setter for v-model pattern
const localValue = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})

// Computed
const displayValue = computed(() => localValue.value.toUpperCase())

// Methods
function handleInput(event) {
  localValue.value = event.target.value  // Uses computed setter
  emit('change', event.target.value)
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

### Vue 3.4+ with defineModel (Recommended)

```vue
<!-- CustomInput.vue - Vue 3.4+ -->
<script setup>
// defineModel() is a compile-time macro that automatically
// declares props and emits for v-model
const modelValue = defineModel({ type: String, default: '' })
</script>

<template>
  <input
    :value="modelValue"
    @input="modelValue = $event.target.value"
  />
</template>

<!-- Usage -->
<CustomInput v-model="text" />
```

### Vue 3.3 and below (Explicit Props)

```vue
<!-- CustomInput.vue - Vue 3.3 and below -->
<script setup>
const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  }
})
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