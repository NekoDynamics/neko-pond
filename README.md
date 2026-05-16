# Neko Pond

<p align="center">
  <a href="https://github.com/NekoDynamics/neko-pond"><img alt="Repo" src="https://img.shields.io/badge/GitHub-NekoDynamics%2Fneko--pond-181717?logo=github"></a>
  <a href="#license"><img alt="License" src="https://img.shields.io/badge/License-See%20LICENSE-lightgrey"></a>
  <a href="#performance-goals"><img alt="Target" src="https://img.shields.io/badge/Target-iPadOS%20120Hz%20Ready-0A84FF"></a>
</p>

## 中文

### 作品简介

Neko Pond 是一个面向 iPadOS 的 AI 互动生态系统，专为猫的感知、追踪和互动行为而设计。
项目以低延迟渲染、自然运动模拟和行为自适应为核心，提供接近原生系统级体验的沉浸式环境。

### 产品哲学

- 以实时交互为首要目标，而非传统游戏循环。
- 以环境氛围承载行为反馈，而非依赖夸张视觉刺激。
- 以猫的感知和动作模式为设计基准，而非人的操作习惯。
- 以 Apple 风格的克制、精密和一致性组织整个体验。

### 功能总览

| 模块 | 说明 |
| --- | --- |
| AI Fish Pond | 动态鱼群与行为自适应系统 |
| Organic Motion | 非线性、非重复的自然运动轨迹 |
| Ripple Simulation | 基于触点与运动反馈的水面波纹 |
| Touch Interaction | 面向爪部触摸的低延迟交互层 |
| Ambient Audio | 轻量、克制的环境音反馈 |
| Guided Access | 适配 iPadOS 的受控使用场景 |

### 架构

- `App`：应用壳层、入口、设置与状态协调
- `Engine`：渲染核心、场景管理、帧调度
- `AI`：行为策略、状态机、响应逻辑
- `Assets`：图像、音频、特效与品牌资源
- `Experiments`：原型、验证和短周期实验
- `Tools`：脚本、调试工具、构建辅助

### 渲染管线

Neko Pond 的渲染路径围绕稳定帧时间设计：

1. 输入采样
2. 交互聚合
3. 行为决策
4. 场景更新
5. Metal 绘制
6. 后处理与提交

目标是在高刷新 iPad Pro 上保持稳定的 120Hz 体验，并尽量避免帧时间尖峰。

### AI 行为系统

AI 层负责：

- 鱼群移动策略
- 触摸驱动的状态变化
- 群体行为与路径扰动
- 环境节奏和反馈强度调节

系统应保持可解释、可扩展、可迁移，以便未来抽取为独立 SDK。

### 触摸交互模型

- 优先处理快速、短促、局部的触点输入
- 降低长按和误触对主交互的干扰
- 过滤无意义的多点噪声
- 维持接近系统级的响应连贯性

### 开发路线

- 生态核心与场景骨架
- 鱼群与波纹基础系统
- 低延迟触摸层
- 行为自适应层
- 音频反馈与节奏控制
- 组织化文档与模板体系
- 第二生态模块的抽象准备

### 截图

> 待补充真实运行截图

### 演示

> 待补充可运行演示链接或录屏

### 参与贡献

请先阅读 `CONTRIBUTING.md`、`SECURITY.md` 和 `SUPPORT.md`。

贡献前请确保：

- 变更聚焦
- 性能指标可解释
- iPad 兼容性已验证
- 触摸与渲染影响已说明

### 技术栈

| 层 | 技术 |
| --- | --- |
| UI | SwiftUI |
| 场景 | SpriteKit |
| 图形 | Metal |
| AI | CoreML |

### 性能目标

- 面向 120Hz iPad Pro 设备优化
- 保持稳定低延迟响应
- 降低掉帧和帧时间波动
- 控制 GPU 与内存占用

### 许可证

见 [LICENSE](LICENSE)。

### 免责声明

本项目面向受控环境下的 iPadOS 交互体验设计。
它不是传统人类游戏，也不替代任何动物照护、行为训练或医疗建议。

## English

### Overview

Neko Pond is an AI-powered interactive ecosystem for iPadOS, designed around feline perception, tracking, and interaction patterns.
It focuses on low-latency rendering, organic motion simulation, and adaptive behavior in a calm, premium native experience.

### Product Philosophy

- Real-time interaction comes before conventional game loops.
- Ambient feedback carries the experience instead of loud visual effects.
- The system is tuned for cat perception and motion, not human control habits.
- The product language follows Apple-style restraint, precision, and consistency.

### Feature Overview

| Module | Description |
| --- | --- |
| AI Fish Pond | Dynamic fish system with behavioral adaptation |
| Organic Motion | Non-linear, non-repeating motion paths |
| Ripple Simulation | Water feedback driven by touch and motion |
| Touch Interaction | Low-latency interaction layer for paw input |
| Ambient Audio | Minimal, controlled environmental feedback |
| Guided Access | Support for supervised iPadOS sessions |

### Architecture

- `App`: app shell, entry, settings, and state coordination
- `Engine`: render core, scene management, frame scheduling
- `AI`: behavior policy, state machines, response logic
- `Assets`: images, audio, effects, and brand resources
- `Experiments`: prototypes, validation, and short-cycle tests
- `Tools`: scripts, debug utilities, build helpers

### Rendering Pipeline

The rendering path is designed around stable frame time:

1. Input sampling
2. Interaction aggregation
3. Behavior decision
4. Scene update
5. Metal draw submission
6. Post-processing and present

The target is a stable 120Hz experience on high-refresh iPad Pro devices with minimal frame spikes.

### AI Behavior System

The AI layer handles:

- Fish movement policy
- Touch-driven state transitions
- Group behavior and path perturbation
- Environment rhythm and feedback intensity

The system should remain explainable, extensible, and portable for future SDK extraction.

### Touch Interaction Model

- Prioritize fast, short, local touch events
- Reduce interference from long press and accidental input
- Filter irrelevant multi-touch noise
- Preserve near-native response continuity

### Development Roadmap

- Ecosystem core and scene scaffolding
- Fish and ripple baseline systems
- Low-latency touch layer
- Behavior adaptation layer
- Audio feedback and pacing control
- Documentation and template system
- Architecture prep for the second ecosystem module

### Screenshots

> Real runtime screenshots to be added

### Demo

> Link or recording to be added

### Contribution

Read `CONTRIBUTING.md`, `SECURITY.md`, and `SUPPORT.md` first.

Before contributing, ensure:

- the change is focused
- performance impact is explainable
- iPad compatibility has been validated
- touch and rendering impact are documented

### Tech Stack

| Layer | Technology |
| --- | --- |
| UI | SwiftUI |
| Scene | SpriteKit |
| Graphics | Metal |
| AI | CoreML |

### Performance Goals

- Optimize for 120Hz iPad Pro devices
- Maintain stable low-latency interaction
- Reduce frame drops and frame-time variance
- Control GPU and memory usage

### License

See [LICENSE](LICENSE).

### Disclaimer

This project is designed for supervised iPadOS interaction in controlled environments.
It is not a traditional human game, and it is not a substitute for animal care, training, or veterinary guidance.
