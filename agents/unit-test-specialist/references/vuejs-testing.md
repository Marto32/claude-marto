# Vue.js Component Unit Testing

This guide covers unit testing Vue.js components using Vue Test Utils and Vitest/Jest.

## Framework Overview

**Vue Test Utils** is the official testing library for Vue.js components. It provides utilities for:
- Mounting components in isolation
- Accessing component internals
- Triggering user events
- Testing props, emits, and slots

**Recommended Stack:**
- Vue Test Utils 2.x (for Vue 3)
- Vitest (recommended) or Jest
- @testing-library/vue (optional, for user-centric testing)

## Installation

```bash
npm install --save-dev @vue/test-utils vitest happy-dom
# Or for Testing Library approach
npm install --save-dev @testing-library/vue @testing-library/user-event
```

## Basic Component Testing

### Mounting Components
```typescript
import { mount } from '@vue/test-utils';
import UserProfile from '@/components/UserProfile.vue';

describe('UserProfile', () => {
  it('should render user name', () => {
    const wrapper = mount(UserProfile, {
      props: {
        user: { name: 'John Doe', email: 'john@example.com' },
      },
    });

    expect(wrapper.text()).toContain('John Doe');
  });
});
```

### Mount vs shallowMount
```typescript
// mount: Renders full component tree
const wrapper = mount(UserProfile);

// shallowMount: Stubs child components (faster, more isolated)
const wrapper = shallowMount(UserProfile);
```

## Testing Props

### Passing Props
```typescript
it('should display user information from props', () => {
  const wrapper = mount(UserCard, {
    props: {
      user: {
        name: 'Jane Doe',
        email: 'jane@example.com',
        avatar: 'avatar.jpg',
      },
    },
  });

  expect(wrapper.find('.user-name').text()).toBe('Jane Doe');
  expect(wrapper.find('.user-email').text()).toBe('jane@example.com');
  expect(wrapper.find('img').attributes('src')).toBe('avatar.jpg');
});
```

### Testing Prop Validation
```typescript
it('should validate required props', () => {
  const wrapper = mount(UserCard, {
    props: {
      // Missing required prop
    },
  });

  // Component won't render correctly
  expect(wrapper.find('.error-message').exists()).toBe(true);
});
```

## Testing Events

### Emitting Events
```typescript
it('should emit delete event when button clicked', async () => {
  const wrapper = mount(UserCard, {
    props: {
      user: { id: 1, name: 'Test' },
    },
  });

  await wrapper.find('.delete-button').trigger('click');

  expect(wrapper.emitted('delete')).toBeTruthy();
  expect(wrapper.emitted('delete')).toHaveLength(1);
  expect(wrapper.emitted('delete')?.[0]).toEqual([1]); // Event payload
});
```

### Testing v-model
```typescript
it('should update value on input', async () => {
  const wrapper = mount(InputField, {
    props: {
      modelValue: '',
      'onUpdate:modelValue': (value: string) => wrapper.setProps({ modelValue: value }),
    },
  });

  const input = wrapper.find('input');
  await input.setValue('test value');

  expect(wrapper.emitted('update:modelValue')).toBeTruthy();
  expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['test value']);
});
```

## Testing User Interactions

### Triggering Events
```typescript
it('should handle click events', async () => {
  const wrapper = mount(Button);

  await wrapper.trigger('click');
  await wrapper.trigger('dblclick');
  await wrapper.trigger('mouseenter');
});

it('should handle form submission', async () => {
  const wrapper = mount(LoginForm);

  await wrapper.find('input[name="username"]').setValue('user');
  await wrapper.find('input[name="password"]').setValue('pass');
  await wrapper.find('form').trigger('submit');

  expect(wrapper.emitted('submit')).toBeTruthy();
});
```

### Keyboard Events
```typescript
it('should handle keyboard input', async () => {
  const wrapper = mount(SearchInput);

  const input = wrapper.find('input');
  await input.trigger('keydown', { key: 'Enter' });
  await input.trigger('keyup', { key: 'Escape' });

  expect(wrapper.emitted('search')).toBeTruthy();
});
```

## Testing Slots

### Default Slots
```typescript
it('should render default slot content', () => {
  const wrapper = mount(Card, {
    slots: {
      default: '<p>Slot content</p>',
    },
  });

  expect(wrapper.html()).toContain('<p>Slot content</p>');
});
```

### Named Slots
```typescript
it('should render named slots', () => {
  const wrapper = mount(Modal, {
    slots: {
      header: '<h1>Modal Title</h1>',
      default: '<p>Modal body</p>',
      footer: '<button>Close</button>',
    },
  });

  expect(wrapper.find('h1').text()).toBe('Modal Title');
  expect(wrapper.find('p').text()).toBe('Modal body');
  expect(wrapper.find('button').text()).toBe('Close');
});
```

### Scoped Slots
```typescript
it('should render scoped slot with data', () => {
  const wrapper = mount(UserList, {
    slots: {
      default: `
        <template #default="{ user }">
          <span>{{ user.name }}</span>
        </template>
      `,
    },
  });

  expect(wrapper.html()).toContain('<span>John Doe</span>');
});
```

## Testing Composition API

### Testing Composables
```typescript
// composables/useCounter.ts
export function useCounter(initialValue = 0) {
  const count = ref(initialValue);
  const increment = () => count.value++;
  const decrement = () => count.value--;
  return { count, increment, decrement };
}

// tests/composables/useCounter.test.ts
import { useCounter } from '@/composables/useCounter';

describe('useCounter', () => {
  it('should initialize with default value', () => {
    const { count } = useCounter();
    expect(count.value).toBe(0);
  });

  it('should increment count', () => {
    const { count, increment } = useCounter();
    increment();
    expect(count.value).toBe(1);
  });

  it('should start with custom initial value', () => {
    const { count } = useCounter(10);
    expect(count.value).toBe(10);
  });
});
```

### Testing Components Using Composables
```typescript
it('should use counter composable', async () => {
  const wrapper = mount(CounterComponent);

  expect(wrapper.find('.count').text()).toBe('0');

  await wrapper.find('.increment').trigger('click');

  expect(wrapper.find('.count').text()).toBe('1');
});
```

## Mocking Dependencies

### Mocking Stores (Pinia)
```typescript
import { setActivePinia, createPinia } from 'pinia';
import { useUserStore } from '@/stores/user';

describe('UserProfile', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
  });

  it('should display user from store', () => {
    const userStore = useUserStore();
    userStore.currentUser = { id: 1, name: 'Test User' };

    const wrapper = mount(UserProfile, {
      global: {
        plugins: [createPinia()],
      },
    });

    expect(wrapper.text()).toContain('Test User');
  });
});
```

### Mocking Vue Router
```typescript
import { mount } from '@vue/test-utils';
import { createRouter, createMemoryHistory } from 'vue-router';

it('should navigate on button click', async () => {
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/', component: Home },
      { path: '/users', component: Users },
    ],
  });

  const wrapper = mount(Navigation, {
    global: {
      plugins: [router],
    },
  });

  await wrapper.find('.users-link').trigger('click');
  await router.isReady();

  expect(router.currentRoute.value.path).toBe('/users');
});

// Or mock the router
it('should call router push', async () => {
  const pushSpy = vi.fn();

  const wrapper = mount(Navigation, {
    global: {
      mocks: {
        $router: {
          push: pushSpy,
        },
      },
    },
  });

  await wrapper.find('.users-link').trigger('click');

  expect(pushSpy).toHaveBeenCalledWith('/users');
});
```

### Mocking API Calls
```typescript
import { vi } from 'vitest';

it('should load users from API', async () => {
  const mockFetch = vi.fn().mockResolvedValue({
    json: async () => [{ id: 1, name: 'User 1' }],
  });

  global.fetch = mockFetch;

  const wrapper = mount(UserList);
  await wrapper.vm.$nextTick();
  await flushPromises();

  expect(wrapper.findAll('.user-item')).toHaveLength(1);
  expect(mockFetch).toHaveBeenCalledWith('/api/users');
});
```

## Async Testing

### Waiting for Updates
```typescript
it('should update after async operation', async () => {
  const wrapper = mount(AsyncComponent);

  // Trigger async operation
  await wrapper.find('button').trigger('click');

  // Wait for DOM updates
  await wrapper.vm.$nextTick();

  // Or use flushPromises helper
  await flushPromises();

  expect(wrapper.find('.result').text()).toBe('Loaded');
});
```

### Testing Loading States
```typescript
it('should show loading state', async () => {
  const wrapper = mount(UserList);

  expect(wrapper.find('.loading').exists()).toBe(true);

  await flushPromises();

  expect(wrapper.find('.loading').exists()).toBe(false);
  expect(wrapper.find('.user-list').exists()).toBe(true);
});
```

## Testing Lifecycle Hooks

### onMounted
```typescript
it('should fetch data on mount', async () => {
  const fetchSpy = vi.fn().mockResolvedValue([]);

  const wrapper = mount(UserList, {
    global: {
      provide: {
        fetchUsers: fetchSpy,
      },
    },
  });

  await flushPromises();

  expect(fetchSpy).toHaveBeenCalled();
});
```

## Global Configuration

### Providing Global Properties
```typescript
const wrapper = mount(Component, {
  global: {
    plugins: [router, store],
    mocks: {
      $t: (key: string) => key, // Mock i18n
    },
    provide: {
      apiClient: mockApiClient,
    },
    stubs: {
      Teleport: true, // Stub Teleport component
    },
    directives: {
      focus: vi.fn(), // Mock custom directive
    },
  },
});
```

### Setup File for Tests
```typescript
// tests/setup.ts
import { config } from '@vue/test-utils';

// Mock global properties
config.global.mocks = {
  $t: (key: string) => key,
};

// Stub components globally
config.global.stubs = {
  Teleport: true,
  Transition: false,
};
```

## Testing Library Alternative

### User-Centric Testing
```typescript
import { render, fireEvent } from '@testing-library/vue';
import UserForm from '@/components/UserForm.vue';

it('should submit form with user data', async () => {
  const { getByLabelText, getByRole, emitted } = render(UserForm);

  const nameInput = getByLabelText('Name');
  const emailInput = getByLabelText('Email');
  const submitButton = getByRole('button', { name: /submit/i });

  await fireEvent.update(nameInput, 'John Doe');
  await fireEvent.update(emailInput, 'john@example.com');
  await fireEvent.click(submitButton);

  expect(emitted().submit).toBeTruthy();
});
```

## Best Practices

### 1. Test User Behavior, Not Implementation
```typescript
// Bad: Testing component internals
it('should update data property', () => {
  const wrapper = mount(Component);
  wrapper.vm.internalState = 'new value'; // Don't access vm directly
});

// Good: Test user interactions and visible outcomes
it('should show success message after submission', async () => {
  const wrapper = mount(Component);
  await wrapper.find('form').trigger('submit');
  expect(wrapper.find('.success-message').exists()).toBe(true);
});
```

### 2. Use shallowMount for Isolation
```typescript
// For unit tests, stub child components
const wrapper = shallowMount(ParentComponent, {
  props: { /* ... */ },
});

// Only use mount when you need to test component integration
const wrapper = mount(ParentComponent, {
  props: { /* ... */ },
});
```

### 3. Factories for Component Props
```typescript
const createUser = (overrides = {}) => ({
  id: 1,
  name: 'Test User',
  email: 'test@example.com',
  ...overrides,
});

it('should render user', () => {
  const user = createUser({ name: 'John' });
  const wrapper = mount(UserCard, {
    props: { user },
  });

  expect(wrapper.text()).toContain('John');
});
```

### 4. Clear Test Names for Components
```typescript
// Good component test names
it('should emit update:modelValue when input changes');
it('should display error message when validation fails');
it('should disable submit button when form is invalid');
it('should render loading spinner when data is fetching');
```

## Common Patterns

### Testing Conditional Rendering
```typescript
it('should show/hide elements based on prop', async () => {
  const wrapper = mount(Collapsible, {
    props: { isOpen: false },
  });

  expect(wrapper.find('.content').exists()).toBe(false);

  await wrapper.setProps({ isOpen: true });

  expect(wrapper.find('.content').exists()).toBe(true);
});
```

### Testing Lists
```typescript
it('should render list of items', () => {
  const items = [
    { id: 1, name: 'Item 1' },
    { id: 2, name: 'Item 2' },
  ];

  const wrapper = mount(ItemList, {
    props: { items },
  });

  const listItems = wrapper.findAll('.item');
  expect(listItems).toHaveLength(2);
  expect(listItems[0].text()).toContain('Item 1');
  expect(listItems[1].text()).toContain('Item 2');
});
```

### Testing Computed Properties
```typescript
// Component with computed
const Component = defineComponent({
  props: ['firstName', 'lastName'],
  computed: {
    fullName() {
      return `${this.firstName} ${this.lastName}`;
    },
  },
  template: '<div>{{ fullName }}</div>',
});

it('should compute full name', () => {
  const wrapper = mount(Component, {
    props: {
      firstName: 'John',
      lastName: 'Doe',
    },
  });

  expect(wrapper.text()).toBe('John Doe');
});
```

## Anti-Patterns

### ❌ Accessing Component Internals
```typescript
// Bad
it('should update data', () => {
  wrapper.vm.someData = 'new value';
  expect(wrapper.vm.someData).toBe('new value');
});

// Good
it('should update display on user interaction', async () => {
  await wrapper.find('button').trigger('click');
  expect(wrapper.find('.display').text()).toBe('new value');
});
```

### ❌ Testing Third-Party Components
```typescript
// Bad: Testing that Vue Router works
it('should have router-link', () => {
  const wrapper = mount(Component);
  expect(wrapper.findComponent({ name: 'RouterLink' }).exists()).toBe(true);
});

// Good: Test your component's behavior with routing
it('should navigate to user page when link clicked', async () => {
  const router = createRouter(/* ... */);
  const wrapper = mount(Component, {
    global: { plugins: [router] },
  });

  await wrapper.find('.user-link').trigger('click');
  expect(router.currentRoute.value.path).toBe('/users/1');
});
```

### ❌ Snapshot Testing for Everything
```typescript
// Overuse of snapshots
it('should render correctly', () => {
  const wrapper = mount(Component);
  expect(wrapper.html()).toMatchSnapshot(); // Fragile!
});

// Better: Test specific behavior
it('should display user name', () => {
  const wrapper = mount(UserCard, {
    props: { user: { name: 'John' } },
  });
  expect(wrapper.find('.name').text()).toBe('John');
});
```

## Helper Utilities

```typescript
// tests/utils.ts
import { mount, VueWrapper } from '@vue/test-utils';

export const flushPromises = () => {
  return new Promise((resolve) => setTimeout(resolve, 0));
};

export const findByTestId = (wrapper: VueWrapper, testId: string) => {
  return wrapper.find(`[data-testid="${testId}"]`);
};

// Usage in tests
it('should find element by test id', () => {
  const wrapper = mount(Component);
  const element = findByTestId(wrapper, 'submit-button');
  expect(element.exists()).toBe(true);
});
```
