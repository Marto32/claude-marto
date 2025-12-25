# JavaScript/TypeScript Unit Testing with Jest and Vitest

This guide covers unit testing in JavaScript and TypeScript using Jest and Vitest.

## Framework Overview

### Jest
- Most popular JavaScript testing framework
- Built-in mocking, assertions, and coverage
- Great for React and Node.js
- Slower than Vitest but more mature

### Vitest
- Modern, fast alternative to Jest
- Vite-native (instant HMR)
- Jest-compatible API
- Better TypeScript support
- Recommended for new projects using Vite

## Installation

### Jest
```bash
npm install --save-dev jest @types/jest
# For TypeScript
npm install --save-dev ts-jest @types/jest
```

### Vitest
```bash
npm install --save-dev vitest @vitest/ui
```

## Test Structure

### File Organization
```
src/
  users/
    user.service.ts
    user.repository.ts
    user.types.ts
tests/
  users/
    user.service.test.ts
    user.repository.test.ts
  setup.ts
```

### Test File Naming
- `*.test.ts` or `*.spec.ts`
- `*.test.js` or `*.spec.js`

### Basic Test Structure
```typescript
import { describe, it, expect } from 'vitest'; // or 'jest'

describe('UserService', () => {
  it('should create a user with valid data', () => {
    // Arrange
    const userData = { username: 'test', email: 'test@example.com' };

    // Act
    const user = createUser(userData);

    // Assert
    expect(user.username).toBe('test');
  });
});
```

## Assertions

### Basic Assertions
```typescript
// Equality
expect(value).toBe(expected);  // Strict equality (===)
expect(value).toEqual(expected);  // Deep equality
expect(value).not.toBe(other);

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeGreaterThanOrEqual(3);
expect(value).toBeLessThan(5);
expect(value).toBeLessThanOrEqual(5);
expect(0.1 + 0.2).toBeCloseTo(0.3);  // Floating point

// Strings
expect(string).toMatch(/pattern/);
expect(string).toContain('substring');

// Arrays and iterables
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(array).toEqual(expect.arrayContaining([1, 2]));

// Objects
expect(object).toHaveProperty('key');
expect(object).toHaveProperty('key', value);
expect(object).toMatchObject({ subset: 'of properties' });
expect(object).toEqual(expect.objectContaining({ key: value }));

// Functions
expect(fn).toThrow();
expect(fn).toThrow(Error);
expect(fn).toThrow('error message');
expect(fn).toThrow(/error pattern/);
```

### Custom Matchers
```typescript
expect.extend({
  toBeWithinRange(received: number, floor: number, ceiling: number) {
    const pass = received >= floor && received <= ceiling;
    return {
      pass,
      message: () =>
        `expected ${received} to be within range ${floor} - ${ceiling}`,
    };
  },
});

// Usage
expect(100).toBeWithinRange(90, 110);
```

## Mocking

### Mock Functions
```typescript
import { vi } from 'vitest'; // or jest.fn from 'jest'

// Create mock function
const mockFn = vi.fn();

// Mock with return value
const mockFn = vi.fn().mockReturnValue(42);

// Mock with implementation
const mockFn = vi.fn((x) => x * 2);

// Mock with multiple return values
const mockFn = vi.fn()
  .mockReturnValueOnce('first')
  .mockReturnValueOnce('second')
  .mockReturnValue('default');

// Mock with resolved promise
const mockFn = vi.fn().mockResolvedValue('async value');

// Mock with rejected promise
const mockFn = vi.fn().mockRejectedValue(new Error('async error'));
```

### Mocking Modules
```typescript
// Mock entire module
vi.mock('./user.service');

// Mock with custom implementation
vi.mock('./user.service', () => ({
  UserService: vi.fn().mockImplementation(() => ({
    getUser: vi.fn().mockResolvedValue({ id: 1, name: 'Test' }),
    createUser: vi.fn(),
  })),
}));

// Partial mock (keep some real implementations)
vi.mock('./user.service', async () => {
  const actual = await vi.importActual('./user.service');
  return {
    ...actual,
    getUserById: vi.fn().mockResolvedValue({ id: 1 }),
  };
});

// Mock specific exports
vi.mock('./config', () => ({
  API_URL: 'http://test.api',
  TIMEOUT: 5000,
}));
```

### Mocking External Libraries
```typescript
// Mock axios
vi.mock('axios');
import axios from 'axios';

it('should fetch data', async () => {
  const mockedAxios = axios as jest.Mocked<typeof axios>;
  mockedAxios.get.mockResolvedValue({ data: { users: [] } });

  const users = await fetchUsers();

  expect(users).toEqual([]);
  expect(mockedAxios.get).toHaveBeenCalledWith('/api/users');
});
```

### Spying on Functions
```typescript
import { vi } from 'vitest';

const obj = {
  method: () => 'original',
};

// Spy on existing method
const spy = vi.spyOn(obj, 'method');

// Call original implementation
obj.method();
expect(spy).toHaveBeenCalled();

// Mock implementation
spy.mockImplementation(() => 'mocked');
expect(obj.method()).toBe('mocked');

// Restore original
spy.mockRestore();
```

### Mock Assertions
```typescript
const mock = vi.fn();

// Call assertions
expect(mock).toHaveBeenCalled();
expect(mock).toHaveBeenCalledTimes(2);
expect(mock).toHaveBeenCalledWith(arg1, arg2);
expect(mock).toHaveBeenLastCalledWith(arg1);
expect(mock).toHaveBeenNthCalledWith(1, arg1);
expect(mock).not.toHaveBeenCalled();

// Return value assertions
expect(mock).toHaveReturned();
expect(mock).toHaveReturnedTimes(2);
expect(mock).toHaveReturnedWith(value);
expect(mock).toHaveLastReturnedWith(value);

// Access call information
expect(mock.mock.calls).toHaveLength(2);
expect(mock.mock.calls[0]).toEqual([arg1, arg2]);
expect(mock.mock.results[0].value).toBe(returnValue);
```

## Async Testing

### Promises
```typescript
it('should resolve promise', async () => {
  const result = await asyncFunction();
  expect(result).toBe('value');
});

it('should reject promise', async () => {
  await expect(asyncFunction()).rejects.toThrow('error');
});

// Alternative syntax
it('should handle promise', () => {
  return asyncFunction().then(result => {
    expect(result).toBe('value');
  });
});
```

### Async/Await with Error Handling
```typescript
it('should handle async errors', async () => {
  try {
    await asyncFunction();
    fail('Should have thrown error');
  } catch (error) {
    expect(error).toBeInstanceOf(Error);
    expect(error.message).toBe('expected error');
  }
});

// Better approach
it('should handle async errors', async () => {
  await expect(asyncFunction()).rejects.toThrow('expected error');
});
```

### Testing Timeouts
```typescript
it('should timeout', async () => {
  vi.useFakeTimers();

  const promise = delayedFunction(1000);
  vi.advanceTimersByTime(1000);

  await expect(promise).resolves.toBe('done');

  vi.useRealTimers();
});
```

## Setup and Teardown

### Test Hooks
```typescript
describe('UserService', () => {
  let service: UserService;

  // Run before all tests in suite
  beforeAll(() => {
    // Setup database connection, etc.
  });

  // Run after all tests in suite
  afterAll(() => {
    // Cleanup database connection, etc.
  });

  // Run before each test
  beforeEach(() => {
    service = new UserService();
  });

  // Run after each test
  afterEach(() => {
    service = null;
    vi.clearAllMocks();
  });

  it('test 1', () => {
    // Test with fresh service instance
  });

  it('test 2', () => {
    // Test with fresh service instance
  });
});
```

### Setup Files
```typescript
// vitest.config.ts or jest.config.js
export default {
  setupFiles: ['./tests/setup.ts'],
  setupFilesAfterEnv: ['./tests/setupAfterEnv.ts'],
};

// tests/setup.ts
globalThis.API_URL = 'http://test.api';

// tests/setupAfterEnv.ts
expect.extend({
  // Custom matchers
});
```

## Test Utilities

### Test Factories
```typescript
// tests/factories/user.factory.ts
import { faker } from '@faker-js/faker';

export const createUser = (overrides = {}) => ({
  id: faker.number.int(),
  username: faker.internet.userName(),
  email: faker.internet.email(),
  createdAt: faker.date.past(),
  ...overrides,
});

// Usage in tests
it('should create user', () => {
  const user = createUser({ username: 'specific' });
  expect(user.username).toBe('specific');
});
```

### Test Builders
```typescript
class UserBuilder {
  private user: Partial<User> = {};

  withUsername(username: string) {
    this.user.username = username;
    return this;
  }

  withEmail(email: string) {
    this.user.email = email;
    return this;
  }

  asAdmin() {
    this.user.isAdmin = true;
    return this;
  }

  build(): User {
    return {
      id: faker.number.int(),
      username: faker.internet.userName(),
      email: faker.internet.email(),
      isAdmin: false,
      ...this.user,
    };
  }
}

// Usage
const admin = new UserBuilder()
  .withUsername('admin')
  .asAdmin()
  .build();
```

## Parameterized Tests

### Using test.each
```typescript
describe.each([
  { input: 1, expected: 2 },
  { input: 2, expected: 4 },
  { input: 3, expected: 6 },
])('double function', ({ input, expected }) => {
  it(`should double ${input} to ${expected}`, () => {
    expect(double(input)).toBe(expected);
  });
});

// Array syntax
test.each([
  [1, 2],
  [2, 4],
  [3, 6],
])('double(%i) = %i', (input, expected) => {
  expect(double(input)).toBe(expected);
});

// Template literal syntax
test.each`
  input | expected
  ${1}  | ${2}
  ${2}  | ${4}
  ${3}  | ${6}
`('double($input) = $expected', ({ input, expected }) => {
  expect(double(input)).toBe(expected);
});
```

## TypeScript-Specific Testing

### Type Safety
```typescript
// Ensure types are correct
const result = getUserById(1);
expectTypeOf(result).toEqualTypeOf<User>();

// Type-safe mocks
const mockService = vi.mocked(UserService);
mockService.getUser.mockResolvedValue(user); // Type-checked!
```

### Testing Type Guards
```typescript
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'id' in obj;
}

it('should identify user objects', () => {
  expect(isUser({ id: 1, name: 'Test' })).toBe(true);
  expect(isUser({ name: 'Test' })).toBe(false);
  expect(isUser(null)).toBe(false);
});
```

## Coverage

### Configuration
```typescript
// vitest.config.ts
export default {
  test: {
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'html', 'json'],
      exclude: [
        'node_modules/',
        'tests/',
        '**/*.config.*',
        '**/*.d.ts',
      ],
      all: true,
      lines: 95,
      functions: 95,
      branches: 95,
      statements: 95,
    },
  },
};
```

### Running Coverage
```bash
# Vitest
npm run vitest --coverage

# Jest
npm run jest --coverage
```

## Best Practices

### 1. Use Dependency Injection
```typescript
// Bad: Hard to test
class UserService {
  private api = new ApiClient();

  async getUser(id: number) {
    return this.api.get(`/users/${id}`);
  }
}

// Good: Easy to test
class UserService {
  constructor(private api: ApiClient) {}

  async getUser(id: number) {
    return this.api.get(`/users/${id}`);
  }
}

// Test
it('should fetch user', async () => {
  const mockApi = {
    get: vi.fn().mockResolvedValue({ id: 1 }),
  } as any;

  const service = new UserService(mockApi);
  const user = await service.getUser(1);

  expect(user.id).toBe(1);
});
```

### 2. Mock at Module Boundaries
```typescript
// Mock HTTP library, not internal functions
vi.mock('axios');

it('should fetch data', async () => {
  const mockedAxios = axios as jest.Mocked<typeof axios>;
  mockedAxios.get.mockResolvedValue({ data: [] });

  await fetchData();

  expect(mockedAxios.get).toHaveBeenCalledWith('/api/data');
});
```

### 3. Clear Test Names
```typescript
// Bad
it('works', () => {});

// Good
it('should return user when valid ID is provided', () => {});
it('should throw ValidationError when email is invalid', () => {});
```

### 4. One Assertion Per Test (Guideline)
```typescript
// Prefer focused tests
it('should create user with correct username', () => {
  const user = createUser({ username: 'test' });
  expect(user.username).toBe('test');
});

it('should create user with correct email', () => {
  const user = createUser({ email: 'test@example.com' });
  expect(user.email).toBe('test@example.com');
});

// Multiple assertions OK if testing single behavior
it('should create user with all required fields', () => {
  const user = createUser();
  expect(user.id).toBeDefined();
  expect(user.username).toBeDefined();
  expect(user.email).toBeDefined();
  expect(user.createdAt).toBeInstanceOf(Date);
});
```

### 5. Avoid Testing Implementation Details
```typescript
// Bad: Testing private implementation
it('should call private method', () => {
  const service = new UserService();
  const spy = vi.spyOn(service as any, '_privateMethod');
  service.publicMethod();
  expect(spy).toHaveBeenCalled();
});

// Good: Test public behavior
it('should return formatted user', () => {
  const service = new UserService();
  const result = service.publicMethod();
  expect(result).toEqual(expectedOutput);
});
```

## Common Patterns

### Testing Error Handling
```typescript
it('should handle API errors gracefully', async () => {
  const mockApi = {
    get: vi.fn().mockRejectedValue(new Error('Network error')),
  };

  const service = new UserService(mockApi);

  await expect(service.getUser(1)).rejects.toThrow('Network error');
});
```

### Testing Callbacks
```typescript
it('should call callback with result', (done) => {
  asyncFunction((err, result) => {
    expect(err).toBeNull();
    expect(result).toBe('value');
    done();
  });
});

// Better: Promisify if possible
it('should call callback with result', async () => {
  const result = await promisify(asyncFunction)();
  expect(result).toBe('value');
});
```

### Testing Event Emitters
```typescript
it('should emit event when action completes', (done) => {
  const emitter = new EventEmitter();

  emitter.on('complete', (data) => {
    expect(data).toEqual({ status: 'success' });
    done();
  });

  emitter.emit('complete', { status: 'success' });
});
```

## Anti-Patterns

### ❌ Not Cleaning Up Mocks
```typescript
// Bad: Mocks leak between tests
it('test 1', () => {
  vi.fn().mockReturnValue('value');
});

it('test 2', () => {
  // Previous mocks still active!
});

// Good: Clean up after each test
afterEach(() => {
  vi.clearAllMocks();
  vi.restoreAllMocks();
});
```

### ❌ Testing External Libraries
```typescript
// Bad: Testing that axios works
it('should make HTTP request', () => {
  const response = axios.get('https://api.example.com');
  expect(response).toBeDefined();
});

// Good: Test your code that uses axios
it('should fetch users from API', async () => {
  const mockedAxios = axios as jest.Mocked<typeof axios>;
  mockedAxios.get.mockResolvedValue({ data: [] });

  const users = await fetchUsers();

  expect(users).toEqual([]);
});
```

### ❌ Overly Complex Setup
```typescript
// Bad: Hard to understand what's being tested
beforeEach(() => {
  setupDatabase();
  seedData();
  configureServices();
  initializeApp();
  // ... 20 more lines
});

// Good: Keep setup focused and clear
beforeEach(() => {
  service = new UserService(mockRepository);
});
```
