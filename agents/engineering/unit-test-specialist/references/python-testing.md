# Python Unit Testing with pytest

This guide covers comprehensive unit testing in Python using pytest and its ecosystem.

## Framework Overview

**pytest** is the recommended testing framework for Python. It offers:
- Simple, Pythonic syntax
- Powerful fixture system
- Excellent plugin ecosystem
- Clear assertion introspection
- Parallel execution support

### Installation
```bash
pip install pytest pytest-cov pytest-mock pytest-asyncio factory-boy faker
```

## Test Structure

### File Organization
```
src/
  myapp/
    __init__.py
    models.py
    services.py
    utils.py
tests/
  __init__.py
  conftest.py          # Shared fixtures
  test_models.py
  test_services.py
  test_utils.py
```

### Test Discovery
- Test files: `test_*.py` or `*_test.py`
- Test functions: `test_*`
- Test classes: `Test*` (optional, for grouping)
- Test methods: `test_*`

### Basic Test Structure
```python
def test_function_name():
    # Arrange
    input_data = "test"

    # Act
    result = function_under_test(input_data)

    # Assert
    assert result == expected_output
```

## Assertions

### Simple Assertions
```python
def test_equality():
    assert 1 + 1 == 2
    assert "hello" == "hello"
    assert [1, 2, 3] == [1, 2, 3]

def test_truthiness():
    assert True
    assert not False
    assert "non-empty string"

def test_membership():
    assert 1 in [1, 2, 3]
    assert "key" in {"key": "value"}

def test_type_checking():
    assert isinstance(result, int)
    assert issubclass(MyClass, BaseClass)
```

### pytest.raises for Exceptions
```python
import pytest

def test_exception_raised():
    with pytest.raises(ValueError):
        int("not a number")

def test_exception_message():
    with pytest.raises(ValueError, match="invalid literal"):
        int("not a number")

def test_exception_attributes():
    with pytest.raises(ValidationError) as exc_info:
        validate_user(invalid_data)

    assert exc_info.value.field == "email"
    assert "required" in str(exc_info.value)
```

### pytest.warns for Warnings
```python
def test_deprecation_warning():
    with pytest.warns(DeprecationWarning):
        old_function()
```

### Approximate Comparisons
```python
def test_float_comparison():
    assert 0.1 + 0.2 == pytest.approx(0.3)
    assert {"a": 0.1 + 0.2} == pytest.approx({"a": 0.3})
```

## Fixtures

### Basic Fixtures
```python
import pytest

@pytest.fixture
def sample_user():
    """Create a sample user for testing."""
    return {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com"
    }

def test_user_creation(sample_user):
    assert sample_user["username"] == "testuser"
```

### Fixture Scopes
```python
@pytest.fixture(scope="function")  # Default: new for each test
def function_fixture():
    return "function scope"

@pytest.fixture(scope="class")  # Shared within test class
def class_fixture():
    return "class scope"

@pytest.fixture(scope="module")  # Shared within module
def module_fixture():
    return "module scope"

@pytest.fixture(scope="session")  # Shared across entire test session
def session_fixture():
    return "session scope"
```

### Fixture Teardown
```python
@pytest.fixture
def database_connection():
    # Setup
    conn = create_connection()

    yield conn  # Provide fixture value

    # Teardown
    conn.close()

# Alternative with context manager
@pytest.fixture
def temp_file():
    with open("temp.txt", "w") as f:
        f.write("test data")
        yield f
    # File automatically closed and can be deleted
    os.remove("temp.txt")
```

### Fixture Composition
```python
@pytest.fixture
def database():
    return Database(url="sqlite:///:memory:")

@pytest.fixture
def user_repository(database):
    return UserRepository(database)

@pytest.fixture
def user_service(user_repository):
    return UserService(user_repository)

def test_user_service(user_service):
    # All dependencies automatically created and injected
    user = user_service.create_user(username="test")
    assert user.username == "test"
```

### Parameterized Fixtures
```python
@pytest.fixture(params=["sqlite", "postgres"])
def database(request):
    if request.param == "sqlite":
        return SQLiteDatabase(":memory:")
    else:
        return PostgresDatabase("test_db")
```

### conftest.py
Place shared fixtures in `conftest.py` at any level:
```python
# tests/conftest.py
import pytest

@pytest.fixture
def app():
    """Create application instance for testing."""
    app = create_app("testing")
    yield app
    app.cleanup()

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()
```

## Mocking

### Using pytest-mock
```python
def test_api_call(mocker):
    # Mock requests.get
    mock_get = mocker.patch("requests.get")
    mock_get.return_value.json.return_value = {"data": "test"}

    result = fetch_data("https://api.example.com")

    assert result == {"data": "test"}
    mock_get.assert_called_once_with("https://api.example.com")
```

### Mock Return Values
```python
def test_mock_return_value(mocker):
    mock_func = mocker.Mock(return_value=42)
    assert mock_func() == 42

def test_mock_side_effect(mocker):
    # Side effect with sequence
    mock_func = mocker.Mock(side_effect=[1, 2, 3])
    assert mock_func() == 1
    assert mock_func() == 2
    assert mock_func() == 3

    # Side effect with exception
    mock_func = mocker.Mock(side_effect=ValueError("error"))
    with pytest.raises(ValueError):
        mock_func()
```

### Mocking Class Methods
```python
def test_class_method(mocker):
    mock_method = mocker.patch.object(MyClass, "method")
    mock_method.return_value = "mocked"

    obj = MyClass()
    result = obj.method()

    assert result == "mocked"
    mock_method.assert_called_once()
```

### Mocking Context Managers
```python
def test_file_operation(mocker):
    mock_open = mocker.patch("builtins.open", mocker.mock_open(read_data="test data"))

    with open("file.txt") as f:
        content = f.read()

    assert content == "test data"
    mock_open.assert_called_once_with("file.txt")
```

### Mocking Environment Variables
```python
def test_env_variable(mocker):
    mocker.patch.dict(os.environ, {"API_KEY": "test_key"})

    result = get_api_key()

    assert result == "test_key"
```

### Spy on Real Functions
```python
def test_spy(mocker):
    spy = mocker.spy(math, "sqrt")

    result = calculate_distance(3, 4)  # Uses math.sqrt internally

    assert result == 5
    spy.assert_called_with(25)  # Verify sqrt was called with 25
```

### Mock Assertions
```python
mock.assert_called()
mock.assert_called_once()
mock.assert_called_with(arg1, arg2, kwarg=value)
mock.assert_called_once_with(arg1, arg2)
mock.assert_any_call(arg1, arg2)
mock.assert_has_calls([call(1), call(2)])
mock.assert_not_called()

# Check call count
assert mock.call_count == 3

# Access call arguments
args, kwargs = mock.call_args
all_calls = mock.call_args_list
```

## Parameterized Tests

### Basic Parametrization
```python
@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
    (0, 0),
])
def test_double(input, expected):
    assert double(input) == expected
```

### Multiple Parameters
```python
@pytest.mark.parametrize("x,y,expected", [
    (1, 1, 2),
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_addition(x, y, expected):
    assert add(x, y) == expected
```

### Named Test Cases
```python
@pytest.mark.parametrize("input,expected", [
    pytest.param(1, 2, id="positive"),
    pytest.param(0, 0, id="zero"),
    pytest.param(-1, -2, id="negative"),
])
def test_double(input, expected):
    assert double(input) == expected
```

### Parametrize with Fixtures
```python
@pytest.fixture(params=["sqlite", "postgres"])
def database(request):
    return create_db(request.param)

def test_database_operations(database):
    # Test runs once for each database type
    assert database.ping() == True
```

### Combining Parametrize Decorators
```python
@pytest.mark.parametrize("x", [1, 2])
@pytest.mark.parametrize("y", [3, 4])
def test_multiply(x, y):
    # Runs 4 times: (1,3), (1,4), (2,3), (2,4)
    assert multiply(x, y) == x * y
```

## Async Testing

### pytest-asyncio
```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await async_fetch_data()
    assert result == expected_data

@pytest.mark.asyncio
async def test_async_exception():
    with pytest.raises(TimeoutError):
        await async_operation(timeout=0.001)
```

### Async Fixtures
```python
@pytest.fixture
async def async_client():
    client = AsyncClient()
    await client.connect()
    yield client
    await client.disconnect()

@pytest.mark.asyncio
async def test_with_async_fixture(async_client):
    result = await async_client.fetch()
    assert result is not None
```

### Mocking Async Functions
```python
@pytest.mark.asyncio
async def test_mock_async(mocker):
    mock_fetch = mocker.patch("myapp.fetch_data",
                              return_value=asyncio.Future())
    mock_fetch.return_value.set_result({"data": "test"})

    result = await fetch_data()

    assert result == {"data": "test"}
```

### Testing Timeouts
```python
@pytest.mark.asyncio
async def test_timeout():
    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(slow_operation(), timeout=0.1)
```

### Testing Concurrent Operations
```python
@pytest.mark.asyncio
async def test_concurrent_operations():
    results = await asyncio.gather(
        operation1(),
        operation2(),
        operation3()
    )

    assert len(results) == 3
    assert all(r is not None for r in results)
```

## Factories for Test Data

### factory_boy Basics
```python
import factory
from myapp.models import User, Post

class UserFactory(factory.Factory):
    class Meta:
        model = User

    id = factory.Sequence(lambda n: n)
    username = factory.Faker('user_name')
    email = factory.Faker('email')
    is_active = True

# Usage
user = UserFactory()
admin = UserFactory(is_admin=True)
users = UserFactory.create_batch(5)
```

### Factory Relationships
```python
class PostFactory(factory.Factory):
    class Meta:
        model = Post

    id = factory.Sequence(lambda n: n)
    title = factory.Faker('sentence')
    content = factory.Faker('text')
    author = factory.SubFactory(UserFactory)

# Creates both post and user
post = PostFactory()
assert post.author is not None
```

### Factory Traits
```python
class UserFactory(factory.Factory):
    class Meta:
        model = User

    username = factory.Faker('user_name')
    email = factory.Faker('email')
    is_active = True
    is_admin = False

    class Params:
        admin = factory.Trait(
            is_admin=True,
            is_active=True
        )
        inactive = factory.Trait(
            is_active=False
        )

# Usage
admin_user = UserFactory(admin=True)
inactive_user = UserFactory(inactive=True)
```

### Lazy Attributes
```python
class UserFactory(factory.Factory):
    class Meta:
        model = User

    first_name = factory.Faker('first_name')
    last_name = factory.Faker('last_name')
    email = factory.LazyAttribute(
        lambda obj: f"{obj.first_name.lower()}.{obj.last_name.lower()}@example.com"
    )
```

## Test Organization

### Test Classes for Grouping
```python
class TestUserService:
    """Group related tests for UserService."""

    def test_create_user(self, user_service):
        user = user_service.create_user(username="test")
        assert user.username == "test"

    def test_update_user(self, user_service):
        user = user_service.create_user(username="test")
        updated = user_service.update_user(user.id, username="updated")
        assert updated.username == "updated"

    def test_delete_user(self, user_service):
        user = user_service.create_user(username="test")
        result = user_service.delete_user(user.id)
        assert result is True
```

### Test Markers
```python
import pytest

@pytest.mark.slow
def test_slow_operation():
    # Test that takes > 1 second
    pass

@pytest.mark.smoke
def test_critical_feature():
    # Critical test that runs always
    pass

@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.platform == "win32", reason="Unix only")
def test_unix_feature():
    pass

@pytest.mark.xfail(reason="Known bug")
def test_buggy_feature():
    pass
```

### Running Specific Tests
```bash
# Run all tests
pytest

# Run specific file
pytest tests/test_users.py

# Run specific test
pytest tests/test_users.py::test_create_user

# Run tests matching pattern
pytest -k "user"

# Run tests with marker
pytest -m smoke
pytest -m "not slow"

# Run with coverage
pytest --cov=myapp --cov-report=html

# Run in parallel
pytest -n auto  # Requires pytest-xdist
```

## Coverage

### Configuration (.coveragerc)
```ini
[run]
source = src/myapp
omit =
    */tests/*
    */migrations/*
    */__init__.py

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod
```

### Running Coverage
```bash
# Run with coverage
pytest --cov=myapp

# Generate HTML report
pytest --cov=myapp --cov-report=html

# Show missing lines
pytest --cov=myapp --cov-report=term-missing

# Fail if coverage below threshold
pytest --cov=myapp --cov-fail-under=95
```

## pytest.ini Configuration
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Markers
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    smoke: critical tests that always run
    integration: integration tests (should be rare)

# Asyncio
asyncio_mode = auto

# Coverage
addopts =
    --strict-markers
    --cov=myapp
    --cov-report=term-missing
    --cov-fail-under=95
```

## Best Practices

### 1. Use Dependency Injection
```python
# Bad: Hard to test
class UserService:
    def __init__(self):
        self.repo = UserRepository()

# Good: Easy to test
class UserService:
    def __init__(self, repo: UserRepository):
        self.repo = repo

# Test
def test_user_service(mocker):
    mock_repo = mocker.Mock(spec=UserRepository)
    service = UserService(mock_repo)
    # ...
```

### 2. Use In-Memory Databases
```python
@pytest.fixture
def database():
    # Use SQLite in-memory for tests
    db = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(db)
    yield db
    db.dispose()
```

### 3. Mock at Boundaries
```python
# Mock external HTTP calls
def test_fetch_user(mocker):
    mock_get = mocker.patch("requests.get")
    mock_get.return_value.json.return_value = {"id": 1}

    user = fetch_user_from_api(1)

    assert user["id"] == 1
```

### 4. Test Edge Cases
```python
@pytest.mark.parametrize("email", [
    "",  # Empty
    "invalid",  # No @
    "@example.com",  # No local part
    "user@",  # No domain
    "a" * 300 + "@example.com",  # Too long
])
def test_invalid_email(email):
    with pytest.raises(ValidationError):
        validate_email(email)
```

### 5. Clear Test Names
```python
# Bad
def test_user():
    pass

# Good
def test_user_creation_with_valid_data_succeeds():
    pass

def test_user_creation_with_duplicate_email_raises_validation_error():
    pass
```

## Common Patterns

### Setup and Teardown
```python
def setup_module():
    """Run once before all tests in module."""
    pass

def teardown_module():
    """Run once after all tests in module."""
    pass

def setup_function():
    """Run before each test function."""
    pass

def teardown_function():
    """Run after each test function."""
    pass

class TestClass:
    def setup_class(cls):
        """Run once before all tests in class."""
        pass

    def teardown_class(cls):
        """Run once after all tests in class."""
        pass

    def setup_method(self):
        """Run before each test method."""
        pass

    def teardown_method(self):
        """Run after each test method."""
        pass
```

### Temporary Directories
```python
def test_file_creation(tmp_path):
    # tmp_path is a pytest fixture providing a temporary directory
    file = tmp_path / "test.txt"
    file.write_text("test content")

    assert file.read_text() == "test content"
    # Directory automatically cleaned up
```

### Monkeypatch
```python
def test_environment_variable(monkeypatch):
    monkeypatch.setenv("API_KEY", "test_key")

    result = get_api_key()

    assert result == "test_key"

def test_dict_modification(monkeypatch):
    monkeypatch.setitem(config, "debug", True)

    assert config["debug"] is True
```

## Anti-Patterns to Avoid

### ❌ Testing Implementation Details
```python
# Bad: Testing private methods
def test_private_method():
    obj = MyClass()
    assert obj._private_method() == "value"

# Good: Test public interface
def test_public_behavior():
    obj = MyClass()
    result = obj.public_method()
    assert result == expected_outcome
```

### ❌ Shared Mutable State
```python
# Bad: Global state
users = []

def test_create_user():
    users.append(User("test"))
    assert len(users) == 1

def test_list_users():
    assert len(users) == 1  # Fails if test order changes!

# Good: Use fixtures
@pytest.fixture
def users():
    return []

def test_create_user(users):
    users.append(User("test"))
    assert len(users) == 1
```

### ❌ Slow Tests
```python
# Bad: Real database
def test_user_creation():
    db = connect_to_postgres("production_db")  # Slow!
    user = create_user(db, "test")
    assert user.id is not None

# Good: In-memory database
def test_user_creation(in_memory_db):
    user = create_user(in_memory_db, "test")
    assert user.id is not None
```
