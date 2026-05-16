# 触摸系统

## 中文

### 职责

触摸系统处理输入采样、噪声过滤、节流、合并与交互反馈。

### 规则

- 优先响应短促、高置信度输入。
- 降低长按、抖动和误触的干扰。
- 不让输入层打断渲染稳定性。
- 保持触觉反馈与视觉反馈一致。

## English

### Responsibility

The touch system handles input sampling, noise filtering, throttling, aggregation, and interaction feedback.

### Rules

- Prioritize short, high-confidence input.
- Reduce interference from long presses, jitter, and accidental touches.
- Never let input handling destabilize rendering.
- Keep tactile and visual feedback aligned.
