# Sequence and User Journey Diagrams

## Sequence Diagram Syntax

### Basic Structure

Sequence diagrams start with `sequenceDiagram` and show interactions between participants:

```mermaid
sequenceDiagram
    Alice->>Bob: Hello Bob!
    Bob->>Alice: Hello Alice!
```

### Participants

**Explicit declaration:**
```mermaid
sequenceDiagram
    participant A as Alice
    participant B as Bob
    A->>B: Message
```

**Actor (stick figure):**
```mermaid
sequenceDiagram
    actor User
    participant Server
    User->>Server: Request
```

**Aliases:**
```mermaid
sequenceDiagram
    participant C as Client App
    participant S as API Server
    C->>S: GET /data
```

### Message Types

**Solid arrow:**
```mermaid
sequenceDiagram
    A->>B: Synchronous message
```

**Dotted arrow:**
```mermaid
sequenceDiagram
    A-->>B: Response message
```

**Solid line without arrow:**
```mermaid
sequenceDiagram
    A->B: Async message
```

**Dotted line without arrow:**
```mermaid
sequenceDiagram
    A-->B: Async response
```

**Cross (X) for message loss:**
```mermaid
sequenceDiagram
    A-xB: Lost message
    A--xB: Lost response
```

**Open arrow:**
```mermaid
sequenceDiagram
    A-)B: Async message
    A--)B: Async response
```

### Activation Boxes

Show when a participant is active:

```mermaid
sequenceDiagram
    Alice->>+Bob: Request
    Bob->>+Database: Query
    Database-->>-Bob: Results
    Bob-->>-Alice: Response
```

**Manual activation:**
```mermaid
sequenceDiagram
    Alice->>Bob: Message
    activate Bob
    Bob->>Database: Query
    activate Database
    Database-->>Bob: Results
    deactivate Database
    Bob-->>Alice: Response
    deactivate Bob
```

### Notes

**Note on one side:**
```mermaid
sequenceDiagram
    Alice->>Bob: Message
    Note right of Bob: Bob thinks about it
    Bob-->>Alice: Response
```

**Note over participants:**
```mermaid
sequenceDiagram
    Alice->>Bob: Message
    Note over Alice,Bob: Secure connection established
```

**Positions:**
- `right of [participant]`
- `left of [participant]`
- `over [participant1],[participant2]`

### Loops

**Loop with condition:**
```mermaid
sequenceDiagram
    Alice->>Bob: Start
    loop Every minute
        Bob->>Bob: Check status
    end
    Bob-->>Alice: Complete
```

### Alternative Paths

**Alt (if/else):**
```mermaid
sequenceDiagram
    Alice->>Bob: Request
    alt Success
        Bob-->>Alice: OK
    else Failure
        Bob-->>Alice: Error
    end
```

**Opt (optional):**
```mermaid
sequenceDiagram
    Alice->>Bob: Request
    opt Extra validation
        Bob->>Database: Verify
        Database-->>Bob: Valid
    end
    Bob-->>Alice: Response
```

### Parallel Execution

```mermaid
sequenceDiagram
    Alice->>Bob: Start process
    par Task 1
        Bob->>Charlie: Sub-task 1
    and Task 2
        Bob->>David: Sub-task 2
    end
    Charlie-->>Bob: Done 1
    David-->>Bob: Done 2
    Bob-->>Alice: All complete
```

### Critical Region

```mermaid
sequenceDiagram
    Alice->>Bob: Request
    critical Atomic operation
        Bob->>Database: Lock
        Bob->>Database: Update
        Bob->>Database: Unlock
    option Failure
        Bob->>Database: Rollback
    end
    Bob-->>Alice: Result
```

### Break (Early Return)

```mermaid
sequenceDiagram
    Alice->>Bob: Request
    Bob->>Database: Query
    break Error occurred
        Database-->>Bob: Error
        Bob-->>Alice: Failed
    end
    Database-->>Bob: Data
    Bob-->>Alice: Success
```

### Background Highlighting

```mermaid
sequenceDiagram
    Alice->>Bob: Start
    rect rgb(200, 220, 250)
    note right of Bob: Critical section
    Bob->>Charlie: Process
    Charlie-->>Bob: Done
    end
    Bob-->>Alice: Complete
```

## User Journey Syntax

### Basic Structure

User journeys show user experience over time with emotional states:

```mermaid
journey
    title My Working Day
    section Go to work
      Make tea: 5: Me
      Go upstairs: 3: Me
      Do work: 1: Me, Cat
    section Go home
      Go downstairs: 5: Me
      Sit down: 5: Me
```

**Format:** `Task: Score: Actor(s)`
- Score: 1-5 (1 = worst, 5 = best experience)

### Multiple Actors

```mermaid
journey
    title Online Shopping Experience
    section Browse
      Search products: 4: Customer
      View details: 5: Customer
    section Purchase
      Add to cart: 5: Customer
      Checkout: 3: Customer
      Process payment: 2: Customer, System
    section Delivery
      Pack order: 4: Warehouse
      Ship order: 5: Warehouse
      Deliver: 5: Customer, Driver
```

## Complete Examples

### Example 1: RESTful API Call

```mermaid
sequenceDiagram
    participant C as Client
    participant API as API Gateway
    participant Auth as Auth Service
    participant DB as Database

    C->>+API: POST /api/users
    API->>+Auth: Validate Token
    Auth-->>-API: Token Valid

    alt Token Valid
        API->>+DB: INSERT user
        DB-->>-API: Success
        API-->>C: 201 Created
    else Token Invalid
        API-->>C: 401 Unauthorized
    end
    deactivate API
```

### Example 2: Microservices Communication

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant Gateway as API Gateway
    participant Order as Order Service
    participant Payment as Payment Service
    participant Email as Email Service
    participant Queue as Message Queue

    User->>+Frontend: Place Order
    Frontend->>+Gateway: POST /orders

    Gateway->>+Order: Create Order
    Order->>Order: Generate Order ID
    Order-->>-Gateway: Order Created

    Gateway->>+Payment: Process Payment
    Payment->>Payment: Validate Card

    alt Payment Success
        Payment-->>Gateway: Payment OK
        Gateway->>+Queue: Order Confirmed Event
        Queue-->>-Gateway: Queued

        par Email Notification
            Queue->>+Email: Send Confirmation
            Email->>User: Email Sent
            deactivate Email
        and Update Order Status
            Queue->>Order: Update Status
            Order->>Order: Mark as Confirmed
        end

        Gateway-->>Frontend: 200 OK
        Frontend-->>-User: Order Confirmed!
    else Payment Failed
        Payment-->>Gateway: Payment Failed
        Gateway->>Order: Cancel Order
        Order-->>Gateway: Cancelled
        Gateway-->>Frontend: 402 Payment Required
        Frontend-->>User: Payment Failed
    end
    deactivate Payment
    deactivate Gateway
```

### Example 3: Authentication Flow

```mermaid
sequenceDiagram
    actor User
    participant App
    participant Backend
    participant DB

    User->>+App: Enter credentials
    App->>+Backend: POST /login

    Backend->>+DB: Query user
    DB-->>-Backend: User data

    alt Valid Credentials
        Backend->>Backend: Generate JWT
        Backend-->>App: 200 OK + Token
        App->>App: Store token
        App-->>User: Logged in

        Note over User,App: User is authenticated

        User->>App: Access protected resource
        App->>+Backend: GET /profile (with token)
        Backend->>Backend: Verify JWT
        Backend->>DB: Get profile data
        DB-->>Backend: Profile
        Backend-->>-App: 200 OK + Data
        App-->>User: Show profile
    else Invalid Credentials
        Backend-->>App: 401 Unauthorized
        App-->>-User: Login failed
    end
    deactivate Backend
```

### Example 4: File Upload Process

```mermaid
sequenceDiagram
    actor User
    participant Browser
    participant Server
    participant Storage as Cloud Storage
    participant DB

    User->>+Browser: Select file
    Browser->>Browser: Validate file size & type

    alt File Valid
        Browser->>+Server: Upload file
        activate Server
        Server->>+Storage: Store file
        Storage-->>-Server: File URL

        Server->>+DB: Save metadata
        DB-->>-Server: Success

        Server-->>-Browser: 200 OK
        Browser-->>User: Upload complete!
    else File Invalid
        Browser-->>User: Invalid file
    end
    deactivate Browser
```

### Example 5: WebSocket Real-time Chat

```mermaid
sequenceDiagram
    participant Alice
    participant Server
    participant Bob

    Alice->>+Server: Connect WebSocket
    Server-->>-Alice: Connected

    Bob->>+Server: Connect WebSocket
    Server-->>-Bob: Connected

    loop Keep-alive
        Alice->>Server: Ping
        Server-->>Alice: Pong
    end

    Alice->>+Server: Send message
    Note over Server: Broadcast to all clients
    Server-->>Alice: Message delivered
    Server-->>-Bob: New message from Alice

    Bob->>+Server: Send reply
    Server-->>Bob: Message delivered
    Server-->>-Alice: New message from Bob

    Alice->>Server: Disconnect
    Server-->>Bob: Alice left the chat
```

### Example 6: E-commerce Checkout Journey

```mermaid
journey
    title Customer Checkout Experience
    section Product Selection
      Browse catalog: 5: Customer
      Search for item: 4: Customer
      View product: 5: Customer
      Read reviews: 4: Customer
      Add to cart: 5: Customer
    section Checkout
      Review cart: 4: Customer
      Enter shipping: 3: Customer
      Select shipping method: 4: Customer
      Enter payment: 2: Customer
      Apply coupon: 5: Customer
      Confirm order: 3: Customer
    section Post-Purchase
      Receive confirmation: 4: Customer, System
      Track shipment: 5: Customer
      Receive package: 5: Customer, Delivery
      Leave review: 4: Customer
```

### Example 7: SaaS Onboarding Journey

```mermaid
journey
    title New User Onboarding
    section Discovery
      Visit website: 4: User
      Watch demo video: 5: User
      Read features: 4: User
    section Sign Up
      Click sign up: 5: User
      Fill form: 3: User
      Verify email: 2: User, System
      Set password: 3: User
    section First Use
      Complete tutorial: 4: User, System
      Create first project: 5: User
      Invite team member: 4: User
      Configure settings: 3: User
    section Engagement
      Use core feature: 5: User
      Get support: 4: User, Support
      Upgrade plan: 5: User
```

### Example 8: Database Transaction

```mermaid
sequenceDiagram
    participant App
    participant DB as Database
    participant Cache

    App->>+DB: BEGIN TRANSACTION

    critical Update Operations
        App->>DB: UPDATE accounts SET balance = balance - 100 WHERE id = 1
        DB-->>App: OK

        App->>DB: UPDATE accounts SET balance = balance + 100 WHERE id = 2
        DB-->>App: OK

        App->>DB: INSERT INTO transactions (from, to, amount)
        DB-->>App: OK
    option Constraint Violation
        DB-->>App: ERROR
        App->>DB: ROLLBACK
        DB-->>App: Transaction rolled back
        Note over App,DB: Changes reverted
    end

    App->>DB: COMMIT
    DB-->>-App: Transaction committed

    App->>+Cache: Invalidate cache for accounts 1,2
    Cache-->>-App: Cache cleared

    Note over App,DB: All changes persisted
```

## Tips and Best Practices

1. **Use activation boxes**: Show when components are actively processing
2. **Group related interactions**: Use rect/note to highlight important sections
3. **Show error paths**: Use alt/opt to document failure scenarios
4. **Keep participants manageable**: < 6 participants for clarity
5. **Order participants logically**: Left to right by architectural layer or call order
6. **Use meaningful aliases**: Short but descriptive participant names
7. **Document async operations**: Use dotted arrows for responses
8. **Add notes for context**: Explain complex business logic or security checks
