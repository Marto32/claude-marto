# Timeline Diagrams: Gantt, Timeline, and Git Graph

## Gantt Chart Syntax

### Basic Structure

Gantt charts start with `gantt` and show project schedules:

```mermaid
gantt
    title Project Schedule
    dateFormat YYYY-MM-DD
    section Planning
    Define requirements :a1, 2024-01-01, 7d
    Design architecture :a2, after a1, 5d
    section Development
    Implement features :a3, after a2, 14d
```

### Date Formats

**Common date formats:**
- `YYYY-MM-DD` : 2024-01-15
- `YYYY-MM-DD HH:mm` : 2024-01-15 09:00
- `DD-MM-YYYY` : 15-01-2024

Set format with `dateFormat` directive.

### Task Definition

**Basic task:** `Task name :id, start, duration`

**Duration formats:**
- `5d` : 5 days
- `3w` : 3 weeks
- `2h` : 2 hours
- `30m` : 30 minutes

**Start date options:**
- Absolute: `2024-01-01`
- Relative: `after taskId`
- Multiple dependencies: `after task1 task2`

### Task States

**Active task:**
```mermaid
gantt
    title Task States
    dateFormat YYYY-MM-DD
    Task 1 :active, a1, 2024-01-01, 5d
```

**Done task:**
```mermaid
gantt
    title Task States
    dateFormat YYYY-MM-DD
    Task 1 :done, a1, 2024-01-01, 5d
```

**Critical task:**
```mermaid
gantt
    title Task States
    dateFormat YYYY-MM-DD
    Task 1 :crit, a1, 2024-01-01, 5d
```

**Milestone:**
```mermaid
gantt
    title Milestones
    dateFormat YYYY-MM-DD
    Complete planning :milestone, m1, 2024-01-15, 0d
```

### Sections

Organize tasks into sections:

```mermaid
gantt
    title Development Phases
    dateFormat YYYY-MM-DD

    section Phase 1
    Task 1 :2024-01-01, 5d
    Task 2 :2024-01-06, 3d

    section Phase 2
    Task 3 :2024-01-09, 7d
    Task 4 :2024-01-16, 4d
```

### Excluding Days

Exclude weekends or holidays:

```mermaid
gantt
    title Project with Weekends Excluded
    dateFormat YYYY-MM-DD
    excludes weekends
    Task 1 :2024-01-01, 5d
```

**Exclude specific dates:**
```mermaid
gantt
    dateFormat YYYY-MM-DD
    excludes 2024-01-15, 2024-01-16
    Task 1 :2024-01-01, 10d
```

## Timeline Syntax

### Basic Structure

Timelines show events chronologically:

```mermaid
timeline
    title History of Programming Languages
    1950s : FORTRAN
          : LISP
    1960s : COBOL
          : BASIC
    1970s : C
          : SQL
    1980s : C++
          : Objective-C
    1990s : Python
          : Java
          : JavaScript
    2000s : C#
          : Go
    2010s : Rust
          : Swift
          : Kotlin
```

### Multiple Events per Period

```mermaid
timeline
    title Product Roadmap
    Q1 2024 : Feature A Launch
            : Beta Testing B
            : Bug Fixes
    Q2 2024 : Feature B Launch
            : Feature C Development
    Q3 2024 : Feature C Launch
            : Infrastructure Upgrade
    Q4 2024 : Year-end Review
            : Planning 2025
```

### Sections in Timeline

```mermaid
timeline
    title Company Milestones
    section Founding
        2015 : Company Founded
             : First Product
    section Growth
        2017 : Series A Funding
             : 50 Employees
        2019 : Series B Funding
             : International Expansion
    section Maturity
        2021 : IPO
             : 500 Employees
        2023 : Acquired CompetitorCo
```

## Git Graph Syntax

### Basic Structure

Git graphs show version control branching:

```mermaid
gitGraph
    commit
    commit
    branch develop
    checkout develop
    commit
    commit
    checkout main
    merge develop
    commit
```

### Branches

**Create branch:**
```mermaid
gitGraph
    commit
    branch feature
    checkout feature
    commit
```

**Branch from specific branch:**
```mermaid
gitGraph
    commit
    branch develop
    checkout develop
    commit
    branch feature
    checkout feature
    commit
```

### Commits

**Simple commit:**
```mermaid
gitGraph
    commit
```

**Commit with ID:**
```mermaid
gitGraph
    commit id: "Initial commit"
    commit id: "Add feature"
```

**Commit with tag:**
```mermaid
gitGraph
    commit
    commit tag: "v1.0"
```

**Commit type:**
```mermaid
gitGraph
    commit type: NORMAL
    commit type: REVERSE
    commit type: HIGHLIGHT
```

### Merging

**Merge branch:**
```mermaid
gitGraph
    commit
    branch feature
    checkout feature
    commit
    commit
    checkout main
    merge feature
```

### Cherry-pick

```mermaid
gitGraph
    commit id: "A"
    branch feature
    checkout feature
    commit id: "B"
    commit id: "C"
    checkout main
    cherry-pick id: "C"
```

## Complete Examples

### Example 1: Software Development Sprint

```mermaid
gantt
    title Sprint 24 - Jan 2024
    dateFormat YYYY-MM-DD
    excludes weekends

    section Planning
    Sprint planning :done, plan, 2024-01-02, 1d
    Story refinement :done, refine, 2024-01-03, 1d

    section Development
    User auth :crit, active, auth, after refine, 5d
    Dashboard UI :active, dash, after refine, 4d
    API endpoints :api, after auth, 3d
    Database migration :done, db, after refine, 2d

    section Testing
    Unit tests :test1, after auth, 2d
    Integration tests :test2, after api, 2d

    section Release
    Code review :review, after test2, 1d
    Deploy to staging :milestone, stage, after review, 0d
    QA testing :qa, after stage, 2d
    Production deploy :milestone, prod, after qa, 0d

    section Retrospective
    Sprint retro :retro, 2024-01-19, 2h
```

### Example 2: Product Development Timeline

```mermaid
timeline
    title SaaS Product Development Journey
    section Research
        Q1 2023 : Market Research
                : Customer Interviews
                : Competitive Analysis
    section Design
        Q2 2023 : Product Specification
                : UI/UX Design
                : Technical Architecture
    section Development
        Q3 2023 : MVP Development
                : Alpha Testing
        Q4 2023 : Beta Launch
                : User Feedback
    section Launch
        Q1 2024 : Public Launch
                : Marketing Campaign
                : 1000 Users
        Q2 2024 : Feature Expansion
                : Mobile App Launch
                : 5000 Users
```

### Example 3: Git Workflow with Feature Branches

```mermaid
gitGraph
    commit id: "Initial commit"
    commit id: "Setup project structure"

    branch develop
    checkout develop
    commit id: "Add configuration"

    branch feature/auth
    checkout feature/auth
    commit id: "Add login page"
    commit id: "Implement JWT"

    checkout develop
    branch feature/dashboard
    checkout feature/dashboard
    commit id: "Dashboard layout"
    commit id: "Add widgets"

    checkout develop
    merge feature/auth
    commit id: "Update dependencies"

    merge feature/dashboard

    checkout main
    merge develop tag: "v1.0.0"

    checkout develop
    branch feature/notifications
    checkout feature/notifications
    commit id: "Add notification service"

    checkout main
    commit id: "Hotfix: security patch"

    checkout develop
    merge main
    merge feature/notifications

    checkout main
    merge develop tag: "v1.1.0"
```

### Example 4: Construction Project Schedule

```mermaid
gantt
    title Office Building Construction
    dateFormat YYYY-MM-DD

    section Planning
    Site survey :done, survey, 2024-01-01, 14d
    Permits :done, permits, after survey, 21d
    Final design :done, design, after survey, 28d

    section Foundation
    Excavation :crit, done, excav, after permits, 10d
    Foundation pour :crit, done, found, after excav, 7d
    Curing :done, cure, after found, 14d

    section Structure
    Steel framework :crit, active, steel, after cure, 35d
    Concrete floors :active, floors, after steel, 28d
    Roof structure :roof, after floors, 21d

    section Exterior
    Windows installation :windows, after steel, 14d
    Facade :facade, after windows, 21d

    section Interior
    Electrical :elect, after floors, 28d
    Plumbing :plumb, after floors, 28d
    HVAC :hvac, after floors, 35d
    Drywall :drywall, after elect plumb, 21d
    Interior finish :finish, after drywall, 28d

    section Completion
    Inspection :milestone, inspect, after finish, 0d
    Final walkthrough :walk, after inspect, 3d
    Handover :milestone, done, after walk, 0d
```

### Example 5: Company History Timeline

```mermaid
timeline
    title Tech Startup Evolution
    section Founding
        2015 : Founded in garage
             : 3 co-founders
             : First prototype
    section Seed Stage
        2016 : Seed funding $500K
             : First 5 employees
             : Beta launch
        2017 : 100 paying customers
             : Revenue $50K/month
    section Growth
        2018 : Series A $5M
             : Expanded to 30 employees
             : Product v2.0 launch
        2019 : Series B $20M
             : International expansion
             : 10,000 customers
        2020 : Acquired startup XYZ
             : 100 employees
             : Revenue $10M/year
    section Scale
        2021 : Series C $50M
             : IPO planning begins
             : 50,000 customers
        2022 : IPO on NASDAQ
             : Market cap $500M
             : 300 employees
        2023 : Expansion to APAC
             : Revenue $100M/year
             : 100,000 customers
```

### Example 6: Release Management Git Flow

```mermaid
gitGraph
    commit id: "v1.0.0"

    branch develop
    checkout develop

    branch feature/user-profile
    checkout feature/user-profile
    commit id: "Profile UI"
    commit id: "Profile API"

    checkout develop
    branch feature/search
    checkout feature/search
    commit id: "Search implementation"

    checkout develop
    merge feature/user-profile

    checkout feature/search
    commit id: "Search optimization"

    checkout develop
    merge feature/search

    branch release/1.1
    checkout release/1.1
    commit id: "Update version to 1.1"
    commit id: "Update changelog"

    checkout main
    merge release/1.1 tag: "v1.1.0"

    checkout develop
    merge release/1.1

    checkout main
    branch hotfix/security
    checkout hotfix/security
    commit id: "Security patch" type: HIGHLIGHT

    checkout main
    merge hotfix/security tag: "v1.1.1"

    checkout develop
    merge hotfix/security

    branch feature/analytics
    checkout feature/analytics
    commit id: "Add analytics"

    checkout develop
    merge feature/analytics

    checkout main
    merge develop tag: "v1.2.0"
```

## Tips and Best Practices

### Gantt Charts
1. **Set realistic durations**: Account for dependencies and resource availability
2. **Use milestones**: Mark important deliverables and decision points
3. **Show critical path**: Mark critical tasks that affect project completion
4. **Exclude non-working days**: Use `excludes` for accurate scheduling
5. **Group related tasks**: Use sections to organize work streams
6. **Dependencies matter**: Use `after` to show task dependencies
7. **Keep it readable**: Aim for < 20 tasks for clarity

### Timelines
1. **Consistent periods**: Use uniform time periods (quarters, years, etc.)
2. **Meaningful events**: Include significant milestones only
3. **Chronological order**: Always present events in time order
4. **Use sections**: Group related events for better organization
5. **Balance detail**: Too many events reduces readability

### Git Graphs
1. **Follow your workflow**: Match your actual git workflow (Git Flow, GitHub Flow, etc.)
2. **Use meaningful IDs**: Commit messages should be descriptive
3. **Tag releases**: Mark version releases with tags
4. **Show main branches**: Always show main/master and develop branches
5. **Limit complexity**: Show 10-15 commits max for readability
6. **Merge regularly**: Show integration points between branches
7. **Highlight important commits**: Use commit types to emphasize key changes
