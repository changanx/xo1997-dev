---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Compilation clean | Compile command: exit 0 | No syntax errors visible |
| Build succeeds | Build command: exit 0 | Tests passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Tests passed before" | Not current evidence |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns (Spring Boot / Maven)

**Tests:**
```
✅ [mvn clean test] [See: Tests run: 34, Failures: 0, Errors: 0] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Compilation:**
```
✅ [mvn clean compile] [See: BUILD SUCCESS] "Compilation passes"
❌ "No red lines in IDE"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Package (Optional - ask user):**
```
Before packaging, ask user:
- A. Package verification (mvn clean package -DskipTests)
- B. Self verification (user will verify manually)

✅ [mvn clean package -DskipTests] [See: BUILD SUCCESS] "Package succeeds"
❌ "Tests pass, should package fine"
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Maven Commands Reference

| Verification | Command |
|--------------|---------|
| Run all tests | `mvn clean test` |
| Run single test class | `mvn test -Dtest=ClassName` |
| Run single test method | `mvn test -Dtest=ClassName#methodName` |
| Compile only | `mvn clean compile` |
| Package (skip tests) | `mvn clean package -DskipTests` |
| Full build with tests | `mvn clean package` |

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**After verification passes, update module documentation:**

When verification is complete and the work is ready for commit/PR:
1. Read the design doc at `docs/specs/feature_{模块}_{功能}_{日期}/design.md`
2. Update the corresponding module doc `docs/modules/{模块}.md`:
   - Add new functionality to 核心功能
   - Add new files to 代码结构
   - Add new APIs to API 接口
   - Add new entities to 数据模型
   - Update 依赖 if needed
   - Update 配置说明 if needed
3. **✅ VERIFY module doc updated:**
   - Use Read tool to check `docs/modules/{模块}.md` contains the new content
   - If missing updates, update it NOW
4. Commit the updated module doc along with the feature changes

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
