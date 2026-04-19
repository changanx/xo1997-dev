---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Document Verification Gate

<VERIFICATION-GATE>
Every document output step MUST be followed by existence verification. This is NON-NEGOTIABLE.

**Verification Protocol:**
```
After claiming to create/write/save a document:
1. STOP - Do not proceed to next step
2. Use Read tool to check file exists at the claimed path
3. If file does NOT exist:
   - STOP immediately
   - Create the document NOW
   - Re-verify existence
   - Do NOT skip to next step
4. If file EXISTS:
   - Confirm to user: "✅ Document saved: {path}"
   - Only then proceed to next step
```

**Why this matters:** AI often claims to have created documents without actually writing them. This gate catches that failure before it propagates.
</VERIFICATION-GATE>

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Create isolated workspace** — **REQUIRED SUB-SKILL:** Use `xo1997-dev:using-git-worktrees` to create an isolated worktree before any design work
   - This ensures all design documents, plans, and code are created in isolation from main branch
   - The worktree will persist through the entire workflow: brainstorming → writing-plans → execution
2. **Explore project context** — check files, docs, recent commits
   - **Verify docs/modules consistency:** Before starting, run `git diff main -- docs/modules/` to confirm the `docs/modules/` directory on the current branch is consistent with `main`. If there are differences, alert the user — they must review and resolve before proceeding with brainstorming.
3. **Offer visual companion** (if topic will involve visual questions) — this is its own message, not combined with a clarifying question. See the Visual Companion section below.
4. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
5. **Write requirements doc** — save requirements summary to `docs/specs/feature_{模块}_{功能}_{日期}/requirements.md` using `docs/templates/requirements-template.md` as reference; include business goals, user scenarios, core features, and acceptance criteria
6. **✅ VERIFY requirements doc exists** — Use Read tool to confirm file was created; if missing, create it NOW before proceeding
7. **Propose 2-3 approaches** — with trade-offs and your recommendation
8. **Present design** — in sections scaled to their complexity, get user approval after each section
9. **Database schema design** (for Spring Boot + MyBatis-Plus projects) — **MANDATORY** discuss and design database schema, verify all tables include unified audit fields
10. **Write design doc** — save to `docs/specs/feature_{模块}_{功能}_{日期}/design.md` and commit
11. **✅ VERIFY design doc exists** — Use Read tool to confirm file was created; if missing, create it NOW before proceeding
12. **Spec review loop** — dispatch spec-document-reviewer subagent with precisely crafted review context (never your session history); fix issues and re-dispatch until approved (max 5 iterations, then surface to human)
13. **User reviews written spec** — ask user to review the spec file before proceeding
14. **Transition to implementation** — invoke writing-plans skill to create implementation plan

### Database Schema Design Checklist (Spring Boot Projects)

When designing database schema, you MUST verify each table includes:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | BIGINT | ✅ | Primary key, auto increment |
| `create_by` | VARCHAR(30) | - | Creator |
| `create_time` | DATETIME | ✅ | Creation time, default CURRENT_TIMESTAMP |
| `update_by` | VARCHAR(30) | - | Updater |
| `update_time` | DATETIME | ✅ | Update time, default CURRENT_TIMESTAMP |
| `is_del` | TINYINT(1) | ✅ | Logical delete (0: not deleted, 1: deleted) |

**Before finalizing design, ask:**
> "Does this table need the standard audit fields (create_by, create_time, update_by, update_time, is_del)?"

If the user says no, confirm the reason and document it.

## Process Flow

```dot
digraph brainstorming {
    "Create isolated workspace (worktree)" [shape=box style=filled fillcolor=lightblue];
    "Explore project context" [shape=box];
    "Visual questions ahead?" [shape=diamond];
    "Offer Visual Companion\n(own message, no other content)" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Write requirements doc" [shape=box];
    "VERIFY requirements doc" [shape=box style=filled fillcolor=yellow];
    "File exists?" [shape=diamond];
    "Create document NOW" [shape=box style=filled fillcolor=red];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Write design doc" [shape=box];
    "VERIFY design doc" [shape=box style=filled fillcolor=yellow];
    "File exists?" [shape=diamond];
    "Spec review loop" [shape=box];
    "Spec review passed?" [shape=diamond];
    "User reviews spec?" [shape=diamond];
    "Invoke writing-plans skill" [shape=doublecircle];

    "Create isolated workspace (worktree)" -> "Explore project context";
    "Explore project context" -> "Visual questions ahead?";
    "Visual questions ahead?" -> "Offer Visual Companion\n(own message, no other content)" [label="yes"];
    "Visual questions ahead?" -> "Ask clarifying questions" [label="no"];
    "Offer Visual Companion\n(own message, no other content)" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Write requirements doc";
    "Write requirements doc" -> "VERIFY requirements doc";
    "VERIFY requirements doc" -> "File exists?";
    "File exists?" -> "Create document NOW" [label="NO"];
    "Create document NOW" -> "VERIFY requirements doc";
    "File exists?" -> "Propose 2-3 approaches" [label="YES"];
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Write design doc" [label="yes"];
    "Write design doc" -> "VERIFY design doc";
    "VERIFY design doc" -> "File exists?";
    "File exists?" -> "Create document NOW" [label="NO"];
    "File exists?" -> "Spec review loop" [label="YES"];
    "Spec review loop" -> "Spec review passed?";
    "Spec review passed?" -> "Spec review loop" [label="issues found,\nfix and re-dispatch"];
    "Spec review passed?" -> "User reviews spec?" [label="approved"];
    "User reviews spec?" -> "Write design doc" [label="changes requested"];
    "User reviews spec?" -> "Invoke writing-plans skill" [label="approved"];
}
```

**The terminal state is invoking writing-plans.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is writing-plans.

## The Process

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → plan → implementation cycle.
- For appropriately-scoped projects, ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing

**For Spring Boot + MyBatis-Plus projects, also cover:**

- **Database schema design** — discuss table structure during brainstorming phase
  - Table names, fields, types, constraints
  - Index design for query optimization
  - Relationships between tables (foreign keys, associations)
  - Unified audit fields: `create_by`, `create_time`, `update_by`, `update_time`, `is_del`
- Schema design is documented in `design.md` as part of the design document
- During writing-plans phase, schema will be extracted to `database.md` for reference
- Schema optimization continues during development with performance considerations

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier for you to work with - you reason better about code you can hold in context at once, and your edits are more reliable when files are focused. When a file grows large, that's often a signal that it's doing too much.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design - the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## After the Design

**Documentation:**

- **Requirements doc:** Summarize requirements from the clarifying dialogue to `docs/specs/feature_{模块}_{功能}_{日期}/requirements.md`
  - Use `docs/templates/requirements-template.md` as reference
  - Include: business goals, user scenarios, core features, acceptance criteria
- **Design doc:** Write the validated design (spec) to `docs/specs/feature_{模块}_{功能}_{日期}/design.md`
  - (User preferences for spec location override this default)
- **Use the design document template:** `docs/templates/design-document-template.md`
- The template includes:
  - Overview (goal, background, scope)
  - Architecture design (components, data flow)
  - Detailed design (API, data model, database schema)
  - Error handling
  - Test strategy
  - Implementation notes
- Commit both documents to git

**Spec Review Loop:**
After writing the spec document:

1. Dispatch spec-document-reviewer subagent (see spec-document-reviewer-prompt.md)
2. If Issues Found: fix, re-dispatch, repeat until Approved
3. If loop exceeds 5 iterations, surface to human for guidance

**User Review Gate:**
After the spec review loop passes, ask the user to review the written spec before proceeding:

> "Spec written and committed to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."

Wait for the user's response. If they request changes, make them and re-run the spec review loop. Only proceed once the user approves.

**Implementation:**

- Invoke the writing-plans skill to create a detailed implementation plan
- Do NOT invoke any other skill. writing-plans is the next step.

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Surface assumptions explicitly** - If uncertain, ask rather than guess
- **Present multiple interpretations** - Don't pick silently when ambiguity exists
- **Push back when warranted** - If a simpler approach exists, say so
- **Stop when confused** - Name what's unclear and ask
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design, get approval before moving on
- **Be flexible** - Go back and clarify when something doesn't make sense

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming. Available as a tool — not a mode. Accepting the companion means it's available for questions that benefit from visual treatment; it does NOT mean every question goes through the browser.

**Offering the companion:** When you anticipate that upcoming questions will involve visual content (mockups, layouts, diagrams), offer it once for consent:
> "Some of what we're working on might be easier to explain if I can show it to you in a web browser. I can put together mockups, diagrams, comparisons, and other visuals as we go. This feature is still new and can be token-intensive. Want to try it? (Requires opening a local URL)"

**This offer MUST be its own message.** Do not combine it with clarifying questions, context summaries, or any other content. The message should contain ONLY the offer above and nothing else. Wait for the user's response before continuing. If they decline, proceed with text-only brainstorming.

**Per-question decision:** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or the terminal. The test: **would the user understand this better by seeing it than reading it?**

- **Use the browser** for content that IS visual — mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use the terminal** for content that is text — requirements questions, conceptual choices, tradeoff lists, A/B/C/D text options, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" is a conceptual question — use the terminal. "Which wizard layout works better?" is a visual question — use the browser.

If they agree to the companion, read the detailed guide before proceeding:
`skills/brainstorming/visual-companion.md`
