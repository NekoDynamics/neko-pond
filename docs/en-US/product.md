# 产品架构

## 中文

### 产品定位

Neko Pond 是一个为 iPadOS 设计的 AI 互动生态系统。
它不是传统游戏，而是一个围绕猫的实时感知、互动和行为反馈构建的环境。

### 架构目标

- 支持多生态系统扩展
- 支持后续 SDK 抽取
- 支持共享引擎层
- 支持独立的 AI 模块和实验模块

### 模块划分

- `App`：产品入口与应用壳层
- `Engine`：渲染核心与交互调度
- `AI`：行为模型与自适应逻辑
- `Assets`：品牌与运行资源
- `Experiments`：原型与验证
- `Tools`：脚本与辅助工具

## English

### Product Positioning

Neko Pond is an AI-powered interactive ecosystem designed for iPadOS.
It is not a traditional game. It is an environment built around feline perception, interaction, and behavioral feedback.

### Architecture Goals

- Support multiple ecosystem expansion
- Support future SDK extraction
- Support a shared engine layer
- Support independent AI modules and experiment modules

### Module Split

- `App`: product entry and app shell
- `Engine`: render core and interaction orchestration
- `AI`: behavior models and adaptation logic
- `Assets`: brand and runtime resources
- `Experiments`: prototypes and validation
- `Tools`: scripts and helper utilities
