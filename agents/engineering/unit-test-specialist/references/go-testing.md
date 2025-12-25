# Go Unit Testing

Quick reference for Go unit testing with the standard testing package and testify.

## Setup

```bash
go get github.com/stretchr/testify
```

## Basic Test Structure

```go
package user

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestCreateUser(t *testing.T) {
    // Arrange
    email := "test@example.com"
    
    // Act
    user, err := CreateUser(email)
    
    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, email, user.Email)
}
```

## Table-Driven Tests

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid email", "test@example.com", false},
        {"missing @", "invalid.com", true},
        {"empty", "", true},
        {"only @", "@", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

## Mocking with Interfaces

```go
// Define interface
type UserRepository interface {
    FindByID(id int) (*User, error)
    Save(user *User) error
}

// Mock implementation
type MockUserRepository struct {
    FindByIDFunc func(id int) (*User, error)
    SaveFunc     func(user *User) error
}

func (m *MockUserRepository) FindByID(id int) (*User, error) {
    return m.FindByIDFunc(id)
}

func (m *MockUserRepository) Save(user *User) error {
    return m.SaveFunc(user)
}

// Test
func TestUserService(t *testing.T) {
    mockRepo := &MockUserRepository{
        FindByIDFunc: func(id int) (*User, error) {
            return &User{ID: id, Email: "test@example.com"}, nil
        },
    }

    service := NewUserService(mockRepo)
    user, err := service.GetUser(1)

    assert.NoError(t, err)
    assert.Equal(t, 1, user.ID)
}
```

## Subtests

```go
func TestUser(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        user := CreateUser("test@example.com")
        assert.NotNil(t, user)
    })

    t.Run("Validate", func(t *testing.T) {
        err := ValidateUser(&User{Email: ""})
        assert.Error(t, err)
    })
}
```

## Test Fixtures

```go
type UserTestFixture struct {
    db      *sql.DB
    service *UserService
}

func setupTest(t *testing.T) *UserTestFixture {
    db, _ := sql.Open("sqlite3", ":memory:")
    return &UserTestFixture{
        db:      db,
        service: NewUserService(db),
    }
}

func (f *UserTestFixture) teardown() {
    f.db.Close()
}

func TestWithFixture(t *testing.T) {
    f := setupTest(t)
    defer f.teardown()

    user, err := f.service.CreateUser("test@example.com")
    assert.NoError(t, err)
    assert.NotNil(t, user)
}
```

## Testing Concurrent Code

```go
func TestConcurrentAccess(t *testing.T) {
    counter := NewSafeCounter()
    var wg sync.WaitGroup

    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }

    wg.Wait()
    assert.Equal(t, 100, counter.Value())
}
```

## Benchmarks

```go
func BenchmarkCreateUser(b *testing.B) {
    for i := 0; i < b.N; i++ {
        CreateUser("test@example.com")
    }
}
```
