---
name: brainstorming
description: You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.
---

# Brainstorming PySide6 Features

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

<HARD-GATE>
Do NOT write any code, create any files, or take any implementation action until you have presented a design and the user has approved it.
</HARD-GATE>

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check files, docs, existing components
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design** — UI layout, component structure, signal/slot connections
5. **Write design doc** — save to `docs/specs/YYYY-MM-DD-<topic>-design.md`
6. **User reviews design** — ask user to review before proceeding
7. **Transition to implementation** — invoke writing-plans skill

## Process Flow

```
Explore context → Ask questions → Propose approaches → Present design
                                                              │
                                    ┌─────────────────────────┴─────────────────────────┐
                                    │                                                   │
                                    ▼                                                   ▼
                            User approves?                                       User requests changes
                                    │                                                   │
                                    ▼                                                   ▼
                            Write design doc                                    Revise design
                                    │
                                    ▼
                            User reviews spec
                                    │
                                    ▼
                            Invoke writing-plans
```

## Design Document Template

```markdown
# [Feature Name] Design

## Overview
- **Goal**: [One sentence describing what this builds]
- **Background**: [Why this is needed]

## UI Design
- **Wireframe**: [ASCII diagram or description]
- **Components**: [List of components needed]

## Architecture
- **Component Structure**: [How components are organized]
- **Signal Flow**: [How components communicate]

## Technical Details
- **New Files**: [List of files to create]
- **Modified Files**: [List of files to modify]

## Testing Strategy
- **Unit Tests**: [What to test]
- **Integration Tests**: [How to test components together]
```

## Key Questions to Ask

### UI Questions
- What should this look like? (Show options if helpful)
- Where should this be placed in the navigation?
- Should it support both light and dark themes?

### Behavior Questions
- What happens when user clicks X?
- How should errors be displayed?
- Should this be async or blocking?

### Integration Questions
- Does this need to communicate with other components?
- Should this be a reusable component or page-specific?
- Does this need to persist state?

## Principles

- **One question at a time** - Don't overwhelm
- **Multiple choice preferred** - Easier to answer
- **YAGNI** - Remove unnecessary features from designs
- **Explore alternatives** - Always propose 2-3 approaches
- **Incremental validation** - Get approval before moving on
