# Java Unit Testing with JUnit 5 and Mockito

Quick reference for Java unit testing using JUnit 5, Mockito, and AssertJ.

## Setup

```xml
<!-- Maven pom.xml -->
<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <version>5.5.0</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <version>3.24.2</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Basic Test Structure

```java
import org.junit.jupiter.api.*;
import static org.assertj.core.api.Assertions.*;

class UserServiceTest {
    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService();
    }

    @Test
    void shouldCreateUserWithValidData() {
        // Arrange
        UserDto userData = new UserDto("test@example.com", "password");

        // Act
        User user = userService.createUser(userData);

        // Assert
        assertThat(user).isNotNull();
        assertThat(user.getEmail()).isEqualTo("test@example.com");
    }
}
```

## Assertions (AssertJ)

```java
// Basic assertions
assertThat(actual).isEqualTo(expected);
assertThat(actual).isNotEqualTo(other);
assertThat(string).isNotNull();
assertThat(string).isNotEmpty();
assertThat(string).contains("substring");
assertThat(string).startsWith("prefix");
assertThat(number).isGreaterThan(5);
assertThat(number).isBetween(1, 10);

// Collections
assertThat(list).hasSize(3);
assertThat(list).contains(item);
assertThat(list).containsExactly(item1, item2, item3);
assertThat(list).containsOnly(item1, item2);
assertThat(map).containsKey("key");
assertThat(map).containsEntry("key", "value");

// Exceptions
assertThatThrownBy(() -> service.method())
    .isInstanceOf(ValidationException.class)
    .hasMessage("Invalid input");

assertThatCode(() -> service.method()).doesNotThrowAnyException();

// Objects
assertThat(user)
    .extracting("name", "email")
    .containsExactly("John", "john@example.com");
```

## Mocking with Mockito

```java
import org.mockito.Mock;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void shouldFetchUserById() {
        // Arrange
        User expectedUser = new User(1L, "John");
        when(userRepository.findById(1L)).thenReturn(Optional.of(expectedUser));

        // Act
        User user = userService.getUserById(1L);

        // Assert
        assertThat(user).isEqualTo(expectedUser);
        verify(userRepository).findById(1L);
    }
}
```

## Parameterized Tests

```java
@ParameterizedTest
@ValueSource(strings = {"", "  ", "\t", "\n"})
void shouldRejectBlankEmails(String email) {
    assertThatThrownBy(() -> validator.validateEmail(email))
        .isInstanceOf(ValidationException.class);
}

@ParameterizedTest
@CsvSource({
    "1, 2, 3",
    "10, 20, 30",
    "100, 200, 300"
})
void shouldAddNumbers(int a, int b, int expected) {
    assertThat(calculator.add(a, b)).isEqualTo(expected);
}

@ParameterizedTest
@MethodSource("provideUsers")
void shouldValidateUser(User user, boolean expected) {
    assertThat(validator.isValid(user)).isEqualTo(expected);
}

static Stream<Arguments> provideUsers() {
    return Stream.of(
        Arguments.of(new User("valid@example.com"), true),
        Arguments.of(new User(""), false),
        Arguments.of(null, false)
    );
}
```

## Lifecycle Hooks

```java
@BeforeAll
static void setUpClass() {
    // Run once before all tests
}

@BeforeEach
void setUp() {
    // Run before each test
}

@AfterEach
void tearDown() {
    // Run after each test
}

@AfterAll
static void tearDownClass() {
    // Run once after all tests
}
```

## Best Practices

```java
// 1. Use constructor injection for testability
public class UserService {
    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}

// 2. Use test builders
public class UserTestBuilder {
    private String email = "default@example.com";
    private String name = "Default Name";

    public UserTestBuilder withEmail(String email) {
        this.email = email;
        return this;
    }

    public User build() {
        return new User(email, name);
    }
}

// Usage
User user = new UserTestBuilder()
    .withEmail("test@example.com")
    .build();
```

