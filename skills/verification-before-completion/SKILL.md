---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output
---

# Verification Before Completion

## The Iron Rule

```
NO SUCCESS CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you say "done", "fixed", or "passing", you must have run the verification commands and seen the output.

## Verification Commands

### Run Tests

```bash
pytest tests/ -v
```

**Expected output:**
```
===== 15 passed in 2.34s =====
```

**If tests fail:** You are not done. Fix and re-run.

### Run Application

```bash
python app/main.py
```

**Verify manually:**
- [ ] Application starts without errors
- [ ] New feature works as expected
- [ ] Theme switching works
- [ ] No console errors

### Code Quality (Optional)

```bash
ruff check app/
mypy app/
```

## Verification Checklist

Before marking complete:

### Tests
- [ ] All tests pass: `pytest tests/ -v`
- [ ] New code has test coverage
- [ ] Edge cases tested
- [ ] Theme variations tested (light/dark)

### Code Quality
- [ ] No obvious bugs
- [ ] No memory leaks (widgets have parents)
- [ ] Signals properly connected
- [ ] Resources properly loaded

### Documentation
- [ ] New files have docstrings
- [ ] Public methods documented
- [ ] README updated (if needed)

### Manual Testing
- [ ] Application starts
- [ ] New feature works
- [ ] Existing features still work
- [ ] No console warnings

## Common Verification Failures

### Test Failures

```bash
$ pytest tests/ -v
FAILED tests/test_widget.py::test_click - AssertionError
===== 1 failed, 14 passed =====
```

**Action:** Fix the test or code, then re-run.

### Import Errors

```bash
$ python app/main.py
ImportError: cannot import name 'MyWidget' from 'app.components'
```

**Action:** Check import paths and __init__.py exports.

### Runtime Errors

```bash
$ python app/main.py
RuntimeError: QWidget must have a parent
```

**Action:** Ensure widgets have proper parent set.

## Verification Report

After verification, provide:

```markdown
## Verification Report

### Tests
- Command: `pytest tests/ -v`
- Result: 15 passed, 0 failed

### Manual Testing
- [x] Application starts
- [x] New feature works
- [x] Theme switching works
- [x] No console errors

### Code Quality
- [x] No ruff warnings
- [x] Widgets have parents
- [x] Signals connected properly

**Status: VERIFIED ✓**
```

## Red Flags

| Claim | Required Evidence |
|-------|-------------------|
| "Tests pass" | Recent test output showing all passed |
| "Works" | Manual test confirmation |
| "Fixed" | Test that reproduces the fix |
| "Ready to commit" | All verifications passed |

**No evidence = Not verified = Not done.**
