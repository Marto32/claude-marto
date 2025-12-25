# Kotlin Unit Testing

Quick reference for Kotlin unit testing with JUnit 5, MockK, and Kotest.

## Setup

```kotlin
// build.gradle.kts
dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("io.kotest:kotest-assertions-core:5.7.2")
}
```

## Basic Test with JUnit

```kotlin
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.BeforeEach
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe

class UserServiceTest {
    private lateinit var userService: UserService

    @BeforeEach
    fun setUp() {
        userService = UserService()
    }

    @Test
    fun `should create user with valid data`() {
        // Arrange
        val userData = UserDto("test@example.com", "password")

        // Act
        val user = userService.createUser(userData)

        // Assert
        user shouldNotBe null
        user.email shouldBe "test@example.com"
    }
}
```

## Mocking with MockK

```kotlin
import io.mockk.*

class UserServiceTest {
    private val userRepository = mockk<UserRepository>()
    private val userService = UserService(userRepository)

    @Test
    fun `should fetch user by id`() {
        // Arrange
        val expectedUser = User(1, "John")
        every { userRepository.findById(1) } returns expectedUser

        // Act
        val user = userService.getUserById(1)

        // Assert
        user shouldBe expectedUser
        verify { userRepository.findById(1) }
    }

    @Test
    fun `should handle exceptions`() {
        // Arrange
        every { userRepository.findById(any()) } throws NotFoundException()

        // Act & Assert
        shouldThrow<NotFoundException> {
            userService.getUserById(1)
        }
    }
}
```

## Kotest Assertions

```kotlin
import io.kotest.matchers.*
import io.kotest.matchers.collections.*
import io.kotest.matchers.string.*

// Basic
user shouldBe expectedUser
user shouldNotBe null
email shouldContain "@"
name shouldStartWith "John"
list shouldHaveSize 3

// Collections
list shouldContain item
list shouldContainExactly listOf(1, 2, 3)
map shouldContainKey "key"
set shouldBeEmpty()

// Exceptions
shouldThrow<ValidationException> {
    validator.validate("")
}
```

## Parameterized Tests

```kotlin
@ParameterizedTest
@ValueSource(strings = ["", "  ", "\t"])
fun `should reject blank emails`(email: String) {
    shouldThrow<ValidationException> {
        validator.validateEmail(email)
    }
}

@ParameterizedTest
@CsvSource(
    "1, 2, 3",
    "10, 20, 30"
)
fun `should add numbers`(a: Int, b: Int, expected: Int) {
    calculator.add(a, b) shouldBe expected
}
```

## Coroutine Testing

```kotlin
import kotlinx.coroutines.test.runTest

@Test
fun `should fetch data asynchronously`() = runTest {
    // Arrange
    coEvery { repository.fetchData() } returns data

    // Act
    val result = service.getData()

    // Assert
    result shouldBe data
    coVerify { repository.fetchData() }
}
```

## Data Class Testing

```kotlin
@Test
fun `should create user with correct properties`() {
    val user = User(
        id = 1,
        email = "test@example.com",
        name = "John"
    )

    user.id shouldBe 1
    user.email shouldBe "test@example.com"
}
```
