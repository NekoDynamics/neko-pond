# 仓库结构

## 中文

### 顶层结构

| 路径 | 职责 |
| --- | --- |
| `App` | iPadOS 应用壳层、SwiftUI 入口、平台适配 |
| `Engine` | 渲染核心、交互调度、模拟系统、生态抽象 |
| `AI` | 行为策略、CoreML 模型、自适应逻辑 |
| `Assets` | 品牌、纹理、音频、运行资源 |
| `Experiments` | 原型、性能验证、行为观察实验 |
| `Tools` | 构建、资源处理、性能分析脚本 |
| `Docs` | 中英双语文档系统 |
| `.github` | 社区健康文件、模板、工作流 |

### 核心边界

| 边界 | 说明 |
| --- | --- |
| 渲染 | `Engine/Rendering`，只处理绘制、管线和帧稳定性 |
| AI | `AI`，只处理行为、模型、自适应和可观察输出 |
| 生态逻辑 | `Engine/Ecosystems`，承载 Neko Pond 等产品级互动规则 |
| 触摸 | `Engine/Interaction`，处理输入采样、过滤、聚合和反馈调度 |
| 实验 | `Experiments`，不直接进入主路径，需经复审迁移 |

### 扩展方向

- Neko Pond：水域生态模块。
- Neko Swarm：昆虫生态模块。
- Neko Sky：空域生态模块。
- Neko Insight：行为分析模块。
- Shared Engine：未来 SDK 抽取的共享核心。

## English

### Top-level Structure

| Path | Responsibility |
| --- | --- |
| `App` | iPadOS app shell, SwiftUI entry points, platform adaptation |
| `Engine` | Rendering core, interaction scheduling, simulation systems, ecosystem abstraction |
| `AI` | Behavior policy, CoreML models, adaptation logic |
| `Assets` | Brand, textures, audio, runtime resources |
| `Experiments` | Prototypes, performance validation, behavior observation experiments |
| `Tools` | Build, asset processing, performance analysis scripts |
| `Docs` | Bilingual documentation system |
| `.github` | Community health files, templates, workflows |

### Core Boundaries

| Boundary | Description |
| --- | --- |
| Rendering | `Engine/Rendering`, drawing, pipelines, and frame stability only |
| AI | `AI`, behavior, models, adaptation, and observable output only |
| Ecosystem Logic | `Engine/Ecosystems`, product-level interaction rules such as Neko Pond |
| Touch | `Engine/Interaction`, input sampling, filtering, aggregation, and feedback scheduling |
| Experiments | `Experiments`, not part of the main path until reviewed and migrated |

### Expansion Tracks

- Neko Pond: aquatic ecosystem module.
- Neko Swarm: insect ecosystem module.
- Neko Sky: aerial ecosystem module.
- Neko Insight: behavior analytics module.
- Shared Engine: future SDK extraction core.
