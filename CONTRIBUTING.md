# 贡献指南 / Contribution Guide

## 中文

### 工作原则

- 先保证性能，再扩展功能。
- 所有交互修改都必须说明对延迟、帧率和内存的影响。
- 所有 AI 行为修改都必须说明其可观察结果。
- 所有渲染修改都必须说明其对 iPadOS 目标设备的影响。

### 提交要求

- 每个 PR 只解决一个清晰问题。
- 避免把实验、重构和功能变更混在一起。
- 保持目录边界清晰：`App`、`Engine`、`AI`、`Assets`、`Experiments`、`Tools`。
- 提交信息使用简洁的 Conventional Commits 风格。

### 验证要求

- iPad 兼容性说明
- 触摸响应说明
- FPS 或帧时间说明
- 内存或 GPU 影响说明

## English

### Working Principles

- Protect performance before expanding scope.
- Every interaction change must explain latency, frame-rate, and memory impact.
- Every AI behavior change must explain its observable effect.
- Every rendering change must explain impact on target iPadOS devices.

### Submission Requirements

- Each PR should solve one clear problem.
- Do not mix experiments, refactors, and feature changes.
- Keep boundaries explicit: `App`, `Engine`, `AI`, `Assets`, `Experiments`, `Tools`.
- Use concise Conventional Commits style messages.

### Validation Requirements

- iPad compatibility note
- Touch response note
- FPS or frame-time note
- Memory or GPU impact note
