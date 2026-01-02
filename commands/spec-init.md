---
model: claude-opus-4-5
description: Bootstrap a project specification through AI-coached interview-style requirements gathering.
---

# Spec Init Command

Bootstrap a project specification from a general idea through AI coaching and interview-style requirements gathering.

## Input

$ARGUMENTS

## Purpose

This command helps transform a vague project idea into a comprehensive, well-structured specification through systematic interviewing. The output document can be:
- Fed to `/spec` for detailed architectural design
- Used to create design principles in the project's `/context` folder
- Shared with stakeholders for alignment

## Workflow

### Step 1: Initialize Spec Document

Create the spec output location:

```bash
mkdir -p docs/specs
```

Generate a unique spec ID and create the spec file:

```bash
SPEC_ID="spec-$(openssl rand -hex 4)"
SPEC_FILE="docs/specs/${SPEC_ID}-$(echo '$ARGUMENTS' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-30).md"
```

Initialize the spec document with header:

```markdown
# Project Specification: $ARGUMENTS

**Spec ID:** {SPEC_ID}
**Created:** {ISO date}
**Status:** In Progress

---

## Overview

{To be filled during interview}

## Interview Transcript

{Responses will be documented here}
```

### Step 2: Conduct Requirements Interview

Your task is to interview the user systematically to build a comprehensive specification for: **$ARGUMENTS**

Use the `AskUserQuestion` tool repeatedly to gather requirements. Interview across these dimensions, but adapt based on the project type:

#### Core Discovery Areas

1. **Problem & Goals**
   - What problem does this solve?
   - Who are the primary users/stakeholders?
   - What does success look like?
   - What are the non-goals (explicitly out of scope)?

2. **Functional Requirements**
   - What are the core features/capabilities?
   - What are the user workflows?
   - What inputs/outputs are expected?
   - What integrations are needed?

3. **Technical Context**
   - What's the target environment (web, mobile, CLI, API)?
   - What's the expected tech stack (or constraints)?
   - What existing systems must it integrate with?
   - What data needs to be stored/processed?

4. **Quality Attributes**
   - Performance requirements (latency, throughput)?
   - Scalability expectations (users, data volume)?
   - Security/compliance requirements?
   - Reliability/availability targets?

5. **User Experience**
   - Who are the different user personas?
   - What's the expected interaction model?
   - Accessibility requirements?
   - Branding/design system constraints?

6. **Constraints & Tradeoffs**
   - What are the hard constraints (budget, timeline, team size)?
   - What can be compromised vs. what's non-negotiable?
   - What are known risks or unknowns?
   - Build vs. buy decisions?

7. **Operational Concerns**
   - How will it be deployed?
   - How will it be monitored/maintained?
   - What's the support model?
   - Data backup/recovery requirements?

### Interview Guidelines

**DO:**
- Ask probing follow-up questions that dig deeper into answers
- Challenge assumptions ("What if that changes?", "How do you know?")
- Identify hidden requirements ("What happens when X fails?")
- Explore edge cases and error scenarios
- Ask about priorities ("If you could only have one of these, which?")
- Validate understanding by restating in your own words
- Use multi-select questions when gathering feature lists or priorities

**DON'T:**
- Ask obvious questions that can be inferred from context
- Accept vague answers without follow-up
- Move on before a topic is sufficiently explored
- Assume technical decisions without asking
- Skip non-functional requirements

### Question Patterns

Use varied question formats:

```
AskUserQuestion(
  questions=[{
    "question": "What's the primary problem this project solves?",
    "header": "Problem",
    "options": [
      {"label": "Efficiency", "description": "Automate manual processes or reduce time"},
      {"label": "Integration", "description": "Connect disparate systems or data"},
      {"label": "User Experience", "description": "Improve how users interact with something"},
      {"label": "New Capability", "description": "Enable something not currently possible"}
    ],
    "multiSelect": false
  }]
)
```

For deeper exploration:

```
AskUserQuestion(
  questions=[{
    "question": "Which quality attributes are most critical for this project?",
    "header": "Priorities",
    "options": [
      {"label": "Performance", "description": "Fast response times, high throughput"},
      {"label": "Reliability", "description": "High uptime, fault tolerance"},
      {"label": "Security", "description": "Data protection, access control"},
      {"label": "Scalability", "description": "Handle growth in users/data"}
    ],
    "multiSelect": true
  }]
)
```

### Step 3: Document Responses

After EACH question-answer exchange:

1. Update the spec document with the new information
2. Add the exchange to the Interview Transcript section
3. Note any follow-up questions needed
4. Identify which discovery areas still need exploration

Structure the documented responses into appropriate spec sections:

```markdown
## Problem Statement

{Synthesized from problem/goals discussion}

## Users & Stakeholders

### Primary Users
{Who and what they need}

### Secondary Stakeholders
{Others affected by the system}

## Functional Requirements

### Core Features
{Prioritized feature list}

### User Workflows
{Key user journeys}

## Technical Requirements

### Tech Stack
{Technologies, frameworks, platforms}

### Integrations
{External systems, APIs}

### Data Requirements
{What data, how stored, retention}

## Quality Attributes

### Performance
{Specific targets}

### Security
{Requirements and compliance}

### Scalability
{Growth expectations}

## Constraints

### Hard Constraints
{Non-negotiable limitations}

### Soft Constraints
{Preferences that can be traded off}

## Open Questions

{Items needing further clarification}

## Interview Transcript

### Q1: {Question}
**Response:** {User's answer}
**Follow-up:** {Any clarifications}

### Q2: {Question}
...
```

### Step 4: Iterate Until Complete

Continue interviewing until:
1. All core discovery areas have been explored
2. No major gaps or ambiguities remain
3. Priorities and tradeoffs are clear
4. The spec is actionable for downstream design work

### Step 5: Finalize Specification

When the interview is complete:

1. **Synthesize the Interview Transcript** into a cohesive specification document
2. **Add an Executive Summary** at the top (2-3 paragraphs)
3. **Create a Requirements Matrix** showing priority vs. complexity
4. **List Open Questions** that need resolution before implementation
5. **Add Next Steps** section with recommended actions

Update the spec status:

```markdown
**Status:** Complete

## Next Steps

1. Review spec with stakeholders for sign-off
2. Run `/spec system {this-spec-path}` for high-level architecture
3. Create design principles in `/context` folder
4. Identify MVP scope for initial implementation
```

### Step 6: Report Results

Provide a summary:

```
Specification Complete!

Document: {spec-file-path}

Summary:
- {problem statement in one sentence}
- {key features count} core features identified
- {integration count} integrations required
- Priority: {top priority attribute}
- Estimated complexity: {low/medium/high}

Recommended next steps:
- Review and refine with stakeholders
- Run: /spec system {spec-file-path}
```

## Example Session Flow

```
User: /spec-init A CLI tool for managing dotfiles

Claude: [Creates spec document]
Claude: [Asks about problem/goals]
User: [Responds]
Claude: [Documents, asks about features]
User: [Responds]
Claude: [Documents, probes deeper on sync mechanism]
User: [Responds]
Claude: [Documents, asks about target platforms]
...
[10-20 question cycles later]
...
Claude: [Finalizes spec document]
Claude: [Reports results with next steps]
```

## Error Handling

**No arguments:**
```
Error: No project idea provided.

Usage: /spec-init <project-idea>

Examples:
  /spec-init A mobile app for tracking workouts
  /spec-init An API for processing customer orders
  /spec-init A CLI tool for managing Kubernetes deployments
```

## Critical Boundaries

**This command MUST:**
- Use AskUserQuestion for ALL information gathering
- Document every response in the spec document
- Probe deeper when answers are vague or incomplete
- Cover all core discovery areas before completing
- Produce a structured, actionable specification document

**This command will NOT:**
- Make assumptions without asking
- Accept incomplete answers without follow-up
- Skip non-functional requirements
- End prematurely before the spec is comprehensive
- Write code or create implementation artifacts
