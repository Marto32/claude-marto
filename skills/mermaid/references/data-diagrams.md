# Data Visualization Diagrams: Pie and Quadrant Charts

## Pie Chart Syntax

### Basic Structure

Pie charts start with `pie` and show proportional data:

```mermaid
pie title Pets Owned
    "Dogs" : 42
    "Cats" : 38
    "Fish" : 12
    "Birds" : 8
```

### With Title

```mermaid
pie title Browser Market Share 2024
    "Chrome" : 65
    "Safari" : 19
    "Firefox" : 7
    "Edge" : 5
    "Other" : 4
```

### Without Title

```mermaid
pie
    "Product A" : 450
    "Product B" : 320
    "Product C" : 180
    "Product D" : 50
```

### Data Format

**Syntax:** `"Label" : value`

- Labels must be in quotes
- Values are absolute numbers (converted to percentages automatically)
- No percentage calculations needed

## Quadrant Chart Syntax

### Basic Structure

Quadrant charts show items plotted on two axes:

```mermaid
quadrantChart
    title Product Priority Matrix
    x-axis Low Effort --> High Effort
    y-axis Low Impact --> High Impact
    quadrant-1 Quick Wins
    quadrant-2 Major Projects
    quadrant-3 Fill-ins
    quadrant-4 Hard Slogs
    Feature A: [0.2, 0.8]
    Feature B: [0.7, 0.9]
    Feature C: [0.3, 0.3]
    Feature D: [0.8, 0.4]
```

### Axes Definition

**X-axis:** `x-axis Label Left --> Label Right`
**Y-axis:** `y-axis Label Bottom --> Label Top`

### Quadrant Labels

Number quadrants 1-4 (clockwise from top-right):

```
quadrant-1 Top Right
quadrant-2 Top Left
quadrant-3 Bottom Left
quadrant-4 Bottom Right
```

### Data Points

**Syntax:** `Item Name: [x, y]`

- X and Y values range from 0.0 to 1.0
- 0.5 is the midpoint
- Values outside 0-1 will be clamped

## Complete Examples

### Example 1: Team Resource Allocation

```mermaid
pie title Q1 2024 Team Hours by Project
    "Customer Portal" : 480
    "Mobile App" : 360
    "API Refactor" : 280
    "Bug Fixes" : 160
    "Documentation" : 120
    "Tech Debt" : 200
```

### Example 2: Revenue by Product Line

```mermaid
pie title Annual Revenue Distribution
    "Enterprise Software" : 12500000
    "Cloud Services" : 8200000
    "Professional Services" : 4300000
    "Support Contracts" : 3100000
    "Training" : 900000
```

### Example 3: Customer Satisfaction

```mermaid
pie title Customer Feedback Ratings
    "Very Satisfied" : 156
    "Satisfied" : 234
    "Neutral" : 89
    "Dissatisfied" : 34
    "Very Dissatisfied" : 12
```

### Example 4: Eisenhower Matrix (Priority Quadrant)

```mermaid
quadrantChart
    title Task Priority Matrix
    x-axis Low Urgency --> High Urgency
    y-axis Low Importance --> High Importance
    quadrant-1 Do Now
    quadrant-2 Schedule
    quadrant-3 Delegate
    quadrant-4 Eliminate
    Security patch: [0.9, 0.95]
    New feature request: [0.3, 0.8]
    Code review: [0.6, 0.7]
    Team meeting: [0.7, 0.4]
    Update documentation: [0.2, 0.6]
    Refactor legacy code: [0.4, 0.5]
    Fix minor UI bug: [0.5, 0.3]
    Social media post: [0.3, 0.2]
```

### Example 5: Feature Evaluation Matrix

```mermaid
quadrantChart
    title Feature Prioritization
    x-axis Low Development Cost --> High Development Cost
    y-axis Low User Value --> High User Value
    quadrant-1 Low Priority
    quadrant-2 Costly but Valuable
    quadrant-3 Low-hanging Fruit
    quadrant-4 Reconsider
    Dark mode: [0.2, 0.9]
    AI chatbot: [0.9, 0.8]
    Export to PDF: [0.3, 0.7]
    Custom themes: [0.6, 0.5]
    Email templates: [0.4, 0.8]
    Advanced filters: [0.5, 0.6]
    Keyboard shortcuts: [0.2, 0.4]
    Video integration: [0.8, 0.3]
```

### Example 6: Market Positioning

```mermaid
quadrantChart
    title Competitive Analysis
    x-axis Low Price --> High Price
    y-axis Low Quality --> High Quality
    quadrant-1 Premium
    quadrant-2 High-end
    quadrant-3 Budget
    quadrant-4 Overpriced
    Our Product: [0.6, 0.8]
    Competitor A: [0.8, 0.7]
    Competitor B: [0.3, 0.5]
    Competitor C: [0.5, 0.4]
    Competitor D: [0.9, 0.9]
    Competitor E: [0.2, 0.3]
```

### Example 7: Budget Allocation

```mermaid
pie title IT Department Budget FY2024
    "Infrastructure" : 850000
    "Software Licenses" : 620000
    "Personnel Training" : 340000
    "Security" : 520000
    "R&D" : 890000
    "Support" : 380000
    "Hardware" : 400000
```

### Example 8: Risk Assessment Matrix

```mermaid
quadrantChart
    title Project Risk Analysis
    x-axis Low Probability --> High Probability
    y-axis Low Impact --> High Impact
    quadrant-1 Monitor
    quadrant-2 Mitigate
    quadrant-3 Accept
    quadrant-4 Transfer/Avoid
    Data breach: [0.3, 0.95]
    Scope creep: [0.7, 0.7]
    Team turnover: [0.5, 0.8]
    Budget overrun: [0.6, 0.6]
    Technology obsolescence: [0.4, 0.5]
    Vendor issues: [0.5, 0.4]
    Minor delays: [0.7, 0.3]
    Documentation gaps: [0.6, 0.2]
```

## Tips and Best Practices

### Pie Charts

1. **Limit slices**: Use 5-7 slices maximum for readability
2. **Order by size**: Largest to smallest provides better visual hierarchy
3. **Combine small values**: Group tiny slices into "Other" category
4. **Use descriptive labels**: Make categories clear and concise
5. **Show totals in title**: Include total count or sum if relevant
6. **Avoid 3D**: Stick to 2D pies for accuracy
7. **Consider alternatives**: For many categories, consider bar charts instead

### Quadrant Charts

1. **Choose axes wisely**: Select meaningful dimensions for comparison
2. **Clear quadrant labels**: Use action-oriented labels (Do, Schedule, Delegate)
3. **Meaningful positioning**: Ensure x,y coordinates accurately reflect data
4. **Avoid overcrowding**: 10-15 points maximum
5. **Use consistent scales**: Both axes should use 0.0-1.0 range
6. **Label clearly**: Item names should be concise but descriptive
7. **Context in title**: Include what's being evaluated

### When to Use Each

**Use Pie Charts when:**
- Showing parts of a whole
- Data adds up to 100%
- Comparing proportions
- Limited number of categories
- Exact percentages matter less than relative size

**Use Quadrant Charts when:**
- Comparing items on two dimensions
- Prioritizing tasks or features
- Evaluating trade-offs
- Making strategic decisions
- Showing distribution across categories
- Plotting competitors or options

**Avoid using:**
- Pie charts for time series (use line charts)
- Pie charts with many categories (use bar charts)
- Quadrant charts for simple yes/no decisions (use flowcharts)
- Quadrant charts when only one dimension matters (use bar charts)
