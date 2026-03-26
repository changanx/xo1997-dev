# xo1997-dev 测试框架

自动化测试框架，用于验证 xo1997-dev 技能系统的正确行为。

## 概述

本测试框架采用分层测试策略：

| 层级 | 内容 | 数量 | 运行时间 |
|------|------|------|----------|
| **L1 触发测试** | 验证技能从自然语言中被正确触发 | 18 用例 | ~1分钟/用例 |
| **L2 行为测试** | 验证核心技能的具体行为 | 6 用例 | ~2分钟/用例 |
| **L3 集成测试** | 端到端工作流验证 | 2 用例 | 15-30分钟/用例 |

## 环境要求

- Claude Code CLI 已安装并在 PATH 中（`claude --version` 可用）
- xo1997-dev 插件已安装

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

### 运行集成测试（慢）

```bash
cd tests/l3-integration
./run-integration-test.sh springboot-user-crud
```

## 命令行选项

### run-all.sh

```bash
./run-all.sh [options]

Options:
  --verbose, -v        显示详细输出
  --timeout SECONDS    设置单测试超时时间（默认：300秒）
  --help, -h           显示帮助信息
```

### run-test.sh

```bash
./run-test.sh <skill-name> [max-turns]

Arguments:
  skill-name    技能名称（对应 prompts/目录下的文件名）
  max-turns     最大对话轮数（默认：3）

Examples:
  ./run-test.sh brainstorming
  ./run-test.sh tdd 5
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
├── l2-behavior/                  # L2 行为测试
│   ├── test-subagent-driven-dev.sh
│   ├── test-team-driven-dev.sh
│   ├── test-tdd.sh
│   └── ...
│
└── l3-integration/               # L3 集成测试
    ├── springboot-user-crud/
    │   ├── design.md
    │   └── plan.md
    └── run-integration-test.sh
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

### 环境函数

```bash
create_test_project          # 创建临时测试目录
cleanup_test_project "$dir"  # 清理测试目录
create_test_design "$dir"    # 创建测试设计文档
create_test_plan "$dir"      # 创建测试计划文档
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

## CI/CD 集成

```bash
# 运行快速测试（L1 + L2）
./tests/l1-triggering/run-all.sh --timeout 180
./tests/l2-behavior/run-all.sh --timeout 300

# 运行完整测试（包含 L3 集成测试）
./tests/l3-integration/run-integration-test.sh --all
```

## 测试结果

测试输出存储在 `/tmp/xo1997-dev-tests/<timestamp>/` 目录：

- `prompt.txt` - 使用的提示词
- `claude-output.json` - Claude 完整 JSON 输出

## 调试失败测试

```bash
# 显示详细输出
./run-all.sh --verbose

# 查看完整日志
cat /tmp/xo1997-dev-tests/<timestamp>/l1-triggering/<skill>/claude-output.json | jq .
```
