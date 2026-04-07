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

### End-to-End Testing (REQUIRED for data features)

**对于涉及数据导入/导出/处理的功能，必须执行端到端验证：**

```bash
# 使用真实/模板数据运行完整流程
python -c "
from core.excel_processor import ExcelProcessor
from core.ppt_generator import PPTGenerator

# 1. 导入真实数据
processor = ExcelProcessor()
success, msg = processor.import_excel('data_template.xlsx')
print(f'导入: {success}, {msg}')
print(f'部门数: {processor.department_count}')
print(f'员工数: {processor.employee_count}')

# 2. 验证数据正确
assert processor.department_count > 0, '部门数应为正数'
assert processor.employee_count > 0, '员工数应为正数'

# 3. 生成输出
tree = processor.get_department_tree()
stats = processor.get_employee_stats()
generator = PPTGenerator()
success, msg = generator.generate(tree, stats, 'test_output.pptx')
print(f'输出: {success}, {msg}')

import os
assert os.path.exists('test_output.pptx'), '输出文件应存在'
print('端到端验证通过！')
"
```

<HARD-GATE>
**数据功能验证必须包含：**
1. 使用真实/模板数据文件
2. 验证导入数量与源数据一致
3. 验证输出文件生成成功
4. 清理测试数据

**没有端到端验证 = 未完成验证！**
</HARD-GATE>

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
