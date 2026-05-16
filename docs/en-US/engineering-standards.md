# 工程标准

## 中文

### 总体原则

- 性能预算是功能设计的一部分，不是发布前补充项。
- 渲染、触摸、AI 和产品状态必须保持清晰边界。
- 主循环路径不得引入不可解释的分配、阻塞或随机行为。
- 所有体验结论应来自设备验证、日志或可复现实验。

### Swift 风格

- 类型命名使用清晰领域词，例如 `PondSceneCoordinator`、`TouchSignalBuffer`。
- 优先使用值类型描述输入、状态快照和行为参数。
- 避免在渲染帧路径内做 I/O、复杂日志和动态资源查找。
- 将异步任务限制在明确边界内，避免影响帧提交。
- 公开 API 保持小而稳定，为未来 SDK 抽取预留边界。

### SpriteKit 约定

- `SKScene` 只负责节点生命周期、视觉状态同步和场景调度。
- 行为策略不得散落在 `SKNode` 子类中。
- 节点命名稳定，便于调试、快照和性能采样。
- 粒子、波纹和群体对象必须有明确生命周期和回收策略。

### Metal 渲染规则

- 禁止每帧创建可复用的 buffer、texture、pipeline state。
- Shader 分支复杂度必须可解释，避免不可控动态分支。
- 后处理效果必须具备开关和降级路径。
- GPU 负载应追求稳定占用，避免短时尖峰。
- Metal 与 SpriteKit 边界必须清晰，避免重复绘制和状态竞争。

### CoreML 与 AI 规则

- 推理路径不得阻塞触摸响应和帧提交。
- 模型输入、输出和置信度阈值必须可记录。
- 随机扰动必须可配置、可复现或可禁用。
- 行为变更必须提供可观察指标，而不是仅凭主观描述。

### 资源命名

| 类型 | 规则 | 示例 |
| --- | --- | --- |
| 图像 | `domain_subject_state_scale` | `pond_fish_idle_2x` |
| 音频 | `domain_event_intensity` | `pond_ripple_soft` |
| Shader | `EffectPurposeShader` | `RippleDistortionShader` |
| 配置 | `domain_purpose_config` | `ai_schooling_config` |
| 实验 | `YYYYMMDD-topic` | `20260516-touch-latency` |

### 性能预算

| 指标 | 目标 |
| --- | --- |
| 刷新率 | 120Hz iPad Pro 优先，稳定性优先于平均值 |
| 帧时间 | 8.33ms 预算意识，避免连续尖峰 |
| 触摸响应 | 输入到可见反馈路径保持低延迟、可测量 |
| 内存 | 长会话不应持续增长，资源池必须可回收 |
| GPU | 稳定占用优先，后处理可降级 |
| 启动 | 冷启动路径避免不必要模型和资源加载 |

### PR 必填说明

- 延迟影响
- FPS 或帧时间影响
- 内存和 GPU 影响
- 触摸响应影响
- AI 行为变化
- iPad 设备验证范围

## English

### General Principles

- Performance budgets are part of feature design, not a pre-release addition.
- Rendering, touch, AI, and product state must keep clear boundaries.
- Main-loop paths must not introduce unexplained allocation, blocking, or randomness.
- Experience conclusions should come from device validation, logs, or reproducible experiments.

### Swift Style

- Use clear domain names, such as `PondSceneCoordinator` and `TouchSignalBuffer`.
- Prefer value types for input, state snapshots, and behavior parameters.
- Avoid I/O, heavy logging, and dynamic resource lookup inside frame paths.
- Keep async work inside explicit boundaries so it cannot affect frame submission.
- Keep public APIs small and stable for future SDK extraction.

### SpriteKit Conventions

- `SKScene` owns node lifecycle, visual synchronization, and scene scheduling only.
- Behavior policy must not be scattered across `SKNode` subclasses.
- Node names should remain stable for debugging, snapshots, and performance sampling.
- Particles, ripples, and group objects require explicit lifecycle and reuse policies.

### Metal Rendering Rules

- Do not create reusable buffers, textures, or pipeline states per frame.
- Shader branch complexity must be explainable; avoid uncontrolled dynamic branching.
- Post-processing effects require toggles and fallback paths.
- GPU load should be stable and avoid short spikes.
- Metal and SpriteKit boundaries must be clear to prevent duplicate drawing and state contention.

### CoreML and AI Rules

- Inference paths must not block touch response or frame submission.
- Model inputs, outputs, and confidence thresholds must be recordable.
- Random perturbation must be configurable, reproducible, or disableable.
- Behavior changes require observable metrics, not subjective description alone.

### Asset Naming

| Type | Rule | Example |
| --- | --- | --- |
| Image | `domain_subject_state_scale` | `pond_fish_idle_2x` |
| Audio | `domain_event_intensity` | `pond_ripple_soft` |
| Shader | `EffectPurposeShader` | `RippleDistortionShader` |
| Config | `domain_purpose_config` | `ai_schooling_config` |
| Experiment | `YYYYMMDD-topic` | `20260516-touch-latency` |

### Performance Budgets

| Metric | Target |
| --- | --- |
| Refresh rate | 120Hz iPad Pro first; stability over averages |
| Frame time | 8.33ms budget awareness; avoid consecutive spikes |
| Touch response | Low-latency, measurable input-to-visible-feedback path |
| Memory | No continuous growth in long sessions; reusable resource pools |
| GPU | Stable utilization first; post-processing must degrade gracefully |
| Launch | Avoid unnecessary model and asset loading on cold start |

### Required PR Notes

- Latency impact
- FPS or frame-time impact
- Memory and GPU impact
- Touch responsiveness impact
- AI behavior changes
- iPad device validation scope
