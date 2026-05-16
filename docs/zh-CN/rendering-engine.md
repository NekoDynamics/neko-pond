# 渲染引擎

## 中文

### 职责

渲染引擎负责场景更新、绘制提交、效果调度和帧稳定性控制。

### 规则

- 不在渲染层混入业务状态。
- 不在每帧分配可避免的对象。
- 优先保证帧时间稳定，而非仅追求平均 FPS。
- 对 iPad Pro 120Hz 进行专门优化。

## English

### Responsibility

The rendering engine owns scene updates, draw submission, effect scheduling, and frame stability.

### Rules

- Do not mix business state into the render layer.
- Avoid avoidable allocations per frame.
- Prioritize frame-time stability over average FPS alone.
- Optimize specifically for 120Hz iPad Pro devices.
