# C++ Unit Testing

Quick reference for C++ unit testing with Google Test and Google Mock.

## Setup

```cmake
# CMakeLists.txt
find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})

add_executable(tests test_user.cpp)
target_link_libraries(tests ${GTEST_LIBRARIES} pthread)
```

## Basic Test Structure

```cpp
#include <gtest/gtest.h>
#include "user.h"

class UserTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup before each test
    }

    void TearDown() override {
        // Cleanup after each test
    }

    UserService userService;
};

TEST_F(UserTest, ShouldCreateUserWithValidData) {
    // Arrange
    std::string email = "test@example.com";

    // Act
    User user = userService.createUser(email);

    // Assert
    EXPECT_NE(user.getId(), 0);
    EXPECT_EQ(user.getEmail(), email);
}
```

## Assertions

```cpp
// Basic
EXPECT_EQ(actual, expected);
EXPECT_NE(actual, other);
EXPECT_TRUE(condition);
EXPECT_FALSE(condition);
EXPECT_LT(val1, val2);  // Less than
EXPECT_GT(val1, val2);  // Greater than

// Strings
EXPECT_STREQ(str1, str2);
EXPECT_STRNE(str1, str2);

// Floating point
EXPECT_DOUBLE_EQ(val1, val2);
EXPECT_NEAR(val1, val2, abs_error);

// Exceptions
EXPECT_THROW(statement, exception_type);
EXPECT_NO_THROW(statement);
```

## Parameterized Tests

```cpp
class AdditionTest : public ::testing::TestWithParam<std::tuple<int, int, int>> {};

TEST_P(AdditionTest, ShouldAddNumbers) {
    auto [a, b, expected] = GetParam();
    EXPECT_EQ(calculator.add(a, b), expected);
}

INSTANTIATE_TEST_SUITE_P(
    AdditionTests,
    AdditionTest,
    ::testing::Values(
        std::make_tuple(1, 2, 3),
        std::make_tuple(10, 20, 30),
        std::make_tuple(-1, 1, 0)
    )
);
```

## Mocking with Google Mock

```cpp
#include <gmock/gmock.h>

class MockUserRepository : public UserRepository {
public:
    MOCK_METHOD(User, findById, (int id), (override));
    MOCK_METHOD(void, save, (const User& user), (override));
};

TEST(UserServiceTest, ShouldFetchUser) {
    MockUserRepository mockRepo;
    UserService service(&mockRepo);

    User expectedUser(1, "test@example.com");
    EXPECT_CALL(mockRepo, findById(1))
        .WillOnce(::testing::Return(expectedUser));

    User user = service.getUserById(1);

    EXPECT_EQ(user.getId(), 1);
}
```

## Test Fixtures

```cpp
class UserFixture : public ::testing::Test {
protected:
    void SetUp() override {
        user = new User(1, "test@example.com");
    }

    void TearDown() override {
        delete user;
    }

    User* user;
};

TEST_F(UserFixture, ShouldHaveId) {
    EXPECT_NE(user->getId(), 0);
}
```
