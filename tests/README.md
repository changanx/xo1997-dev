# pyside6-dev 测试框架

自动化测试框架，用于验证 pyside6-dev 技能系统的正确行为。

## 概述

本测试框架采用分层测试策略：

| 层级 | 内容 | 数量 | 运行时间 |
|------|------|------|----------|
| **L1 触发测试** | 验证技能从自然语言中被正确触发 | 12+ 用例 | ~1分钟/用例 |
| **L2 行为测试** | 验证核心技能的具体行为 | 6 用例 | ~2分钟/用例 |

## 环境要求

- Claude Code CLI 已安装并在 PATH 中（`claude --version` 可用）
- pyside6-dev 插件已安装

## 快速开始

### 运行所有 L1 测试

```bash
cd tests/l1-triggering
./run-all.sh
```

### 运行单个 L1 测试

```bash
cd tests/l1-triggering
./run-test.sh brainstorming
./run-test.sh tdd
```

### 运行 L2 行为测试

```bash
cd tests/l2-behavior
./run-all.sh
```

## 目录结构

```
tests/
├── helpers/
│   └── test-helpers.sh           # 通用测试辅助函数
│
├── l1-triggering/                # L1 触发测试
│   ├── prompts/                  # 测试用提示词
│   │   ├── brainstorming.txt
│   │   ├── writing-plans.txt
│   │   ├── tdd.txt
│   │   └── ...
│   ├── run-test.sh               # 运行单个测试
│   └── run-all.sh                # 运行所有 L1 测试
│
└── l2-behavior/                  # L2 行为测试
    ├── test-brainstorming.sh
    ├── test-tdd.sh
    ├── test-component-development.sh
    └── ...
```

## 测试辅助函数

`test-helpers.sh` 提供以下函数：

### 核心函数

```bash
run_claude "prompt" [timeout] [extra_args...]  # 运行 Claude 并捕获输出
run_claude_json "prompt" [timeout]              # 运行 Claude 并输出 JSON
```

### 断言函数

```bash
assert_contains "output" "pattern" "test name"    # 验证包含
assert_not_contains "output" "pattern" "name"     # 验证不包含
assert_count "output" "pattern" count "name"      # 验证出现次数
assert_order "output" "pattern_a" "pattern_b"     # 验证顺序
```

### 技能触发检测

```bash
assert_skill_triggered "json_output" "skill_name"     # 验证技能被触发
assert_skill_not_triggered "json_output" "skill_name" # 验证技能未被触发
assert_no_premature_action "json_output"              # 验证没有过早行动
```

## 添加新测试

### 添加 L1 触发测试

1. 在 `tests/l1-triggering/prompts/` 创建提示词文件：

```bash
echo "你的测试提示词" > tests/l1-triggering/prompts/new-skill.txt
```

2. 运行测试：

```bash
./run-test.sh new-skill
```

### 添加 L2 行为测试

1. 在 `tests/l2-behavior/` 创建测试脚本：

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers/test-helpers.sh"

echo "=== Test: new-skill behavior ==="

# 测试 1
output=$(run_claude "What does new-skill require?" 30)
assert_contains "$output" "expected behavior" "Skill requires expected behavior"

echo "=== All tests passed ==="
```

2. 添加执行权限：

```bash
chmod +x tests/l2-behavior/test-new-skill.sh
```

## 测试结果

测试输出存储在 `/tmp/pyside6-dev-tests/<timestamp>/` 目录：

- `prompt.txt` - 使用的提示词
- `claude-output.json` - Claude 完整 JSON 输出

## 调试失败测试

```bash
# 显示详细输出
./run-all.sh --verbose

# 查看完整日志
cat /tmp/pyside6-dev-tests/<timestamp>/l1-triggering/<skill>/claude-output.json | jq .
```
