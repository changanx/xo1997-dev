---
name: using-pyside6-dev
description: Use when starting any PySide6 desktop client development conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

# Using PySide6-Dev Plugin

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

pyside6-dev skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, direct requests) — highest priority
2. **pyside6-dev skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

## How to Access Skills

Use the `Skill` tool to invoke skills. When you invoke a skill, its content is loaded and presented to you—follow it directly.

## Available Skills

### Workflow Skills

| Skill | Use When |
|-------|----------|
| **brainstorming** | Starting any creative work - new features, building components, adding functionality |
| **writing-plans** | Have a spec or requirements for a multi-step task, before touching code |
| **test-driven-development** | Implementing any feature or bugfix, before writing implementation code |
| **verification-before-completion** | About to claim work is complete, before committing or creating PRs |
| **systematic-debugging** | Encountering any bug, test failure, or unexpected behavior |

### PySide6 Specific Skills

| Skill | Use When |
|-------|----------|
| **project-structure** | Setting up a new PySide6 project or reorganizing existing one |
| **component-development** | Creating reusable UI components |
| **testing-patterns** | Writing tests for Qt components with pytest-qt |
| **signal-slot-patterns** | Implementing communication between components |
| **theme-styling** | Working with themes and stylesheets |

### Commands

| Command | Use When |
|---------|----------|
| `/new-component` | Create a new UI component with tests |
| `/new-interface` | Create a new page/interface |
| `/run-tests` | Run pytest with Qt support |

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check.

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) - these determine HOW to approach the task
2. **Implementation skills second** (component-development, testing-patterns) - these guide execution

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple UI change" | UI changes need testing too. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
