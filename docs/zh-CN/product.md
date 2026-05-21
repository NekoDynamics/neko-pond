# Neko Pond 产品开发计划

## 1. 当前阶段

Neko Pond 当前处于：

```text
Prototype -> Vertical Slice
```

不是完整生产阶段，也不是底层引擎重构阶段。下一阶段的核心不是增加功能，而是证明第一屏已经像一个真实存在的高级产品。

当前唯一北极星：

```text
One Perfect Pond
```

先做一个极其高级、可信、可观看的主池塘，再谈生态扩展。

## 2. 产品定义

Neko Pond 是一个原生 iPadOS ambient pond experience。

它不是：

- 休闲游戏；
- 水族箱模拟器；
- 模拟经营；
- 收集游戏；
- 装饰游戏；
- toy app。

它更接近：

- 数字香薰；
- 数字庭院；
- 情绪家具；
- ambient appliance；
- iPad 上的高级安静空间。

产品承诺：

```text
打开 app，进入一个值得安静观看的活水庭院。
```

第一成功指标不是功能数量，而是用户能否连续观看主池塘 3 分钟而不想退出。

## 3. 战略定位

### 目标品类

Neko Pond 应该被理解为 premium ambient experience，而不是 game。

参考方向：

- Apple TV screensaver；
- Japanese pond photography；
- aquarium cinematography；
- Apple Weather；
- Calm / Endel；
- Muji digital signage；
- 高端冥想产品。

### 禁止偏移

避免任何把产品推向休闲游戏的系统：

- 金币；
- 等级；
- 每日奖励；
- 以鱼收集为核心循环；
- 装饰经济；
- 任务；
- 放置收益；
- 成就弹窗；
- 高频喂食奖励；
- 街机特效。

食物如果存在，必须是偶尔、克制、主动进入的行为。默认点击不能生成食物。

## 4. 当前诊断

当前项目已经具备：

- 正确的原生 iPadOS 方向；
- SwiftUI 应用壳层；
- SceneKit 原型场景；
- 实时鱼类运动；
- 触摸处理；
- curiosity、hesitation、attention、calm、alert、drift 等情绪运动基础。

当前阻塞点不是行为复杂度。

当前阻塞点是：

```text
视觉可信度
```

现在看起来更像“有技术能力的原型”，还不像 App Store Featured 级别的真实产品。

## 5. 主目标

下一阶段只优化一件事：

```text
第一秒相信感
```

用户打开 app 的第一秒应该觉得：

```text
这个东西居然这么高级。
```

暂停截图也应该像产品宣传图。

## 6. One Perfect Pond 范围

### 范围内

只做主池塘 vertical slice：

- 电影感相机构图；
- 可信水深；
- 更可信的锦鲤轮廓与材质；
- 柔和涟漪；
- caustics 光感；
- 深色池塘氛围；
- 荷叶、花瓣、苔藓、石头、前景框景；
- 消失感 HUD；
- 克制触摸反馈；
- 真机稳定性能。

### 范围外

One Perfect Pond 期间不要做：

- 完整天气系统；
- 完整设置页；
- onboarding；
- photo mode；
- 鱼类收集；
- 商业化；
- 账号系统；
- 全量 Metal renderer；
- 完整 GPU 水体模拟；
- 删除 SceneKit；
- SpriteKit 重写；
- ECS 迁移；
- 复杂音频中间件集成。

## 7. 技术路线

当前正确路线：

```text
SwiftUI + SceneKit + selective Metal
```

不要转 Unity。不要现在删除 SceneKit。不要把完整场景迁移到 SpriteKit。

### SwiftUI 负责

- app shell；
- 池塘外导航；
- 未来 settings；
- 未来 glass panels；
- iPadOS lifecycle；
- 极少量 owner controls。

### SceneKit 负责

vertical slice 阶段继续负责：

- fish entities；
- pond geometry；
- camera；
- lighting；
- hit testing；
- scene orchestration；
- prototype water material；
- 3D 装饰元素。

### Metal 负责

Metal 只在最高视觉杠杆处逐步引入，并且要等 One Perfect Pond 方向验证后：

- water rendering；
- ripple field；
- caustics；
- fog / veil；
- post-processing；
- blur / light scattering。

### SpriteKit 负责

SpriteKit 不替代 SceneKit。未来可用于：

- soft particles；
- floating petals；
- mist；
- 2D ambient overlays；
- 非核心场景氛围层。

## 8. 视觉方向

### 必须形成的画面结构

主池塘需要有空间层次：

```text
foreground frame
midground fish
water depth
fog veil
caustics
background darkness
```

目标是空气透视和水深，不是平面装饰。

### 构图规则

- 避免纯俯视 prototype framing。
- 使用轻微透视和电影感 tilt。
- 让鱼看起来在水里，而不是贴在平面上。
- 用暗边隐藏屏幕矩形感。
- 把最亮区域留给焦点水域/鱼群。
- 前景元素应部分框住画面。

### 色彩方向

- 深蓝绿色水体；
- 低饱和；
- 温暖锦鲤点缀；
- 浅色 caustics；
- 深色苔藓/石头边缘；
- 禁止霓虹；
- 禁止街机 bloom。

### UI 方向

HUD 必须表达 ambient premium software，而不是技术 demo。

生产 UI 删除：

- SceneKit 文案；
- native/technical 标签；
- 鱼群数量 chip；
- debug 说明；
- 游戏式计数器。

主池塘允许：

- `NEKO POND` wordmark；
- calm subtitle；
- 时间 / 季节 / 温度氛围文本；
- 一个小 settings；
- 必要时三个低存在感圆形 owner controls；
- 短时间后自动淡出。

## 9. 锦鲤方向

当前鱼行为基础很有价值，必须保留。

当前 sphere/capsule 拼鱼不再适合作为 vertical slice 视觉标准。

### 视觉目标

目标不是高模，而是可信轮廓。

必须具备：

- tapered koi body；
- 可读的头/身体/尾比例；
- translucent fins；
- soft specular；
- 克制锦鲤花纹；
- 可信 swimming arc；
- 在当前相机下稳定可读。

### 行为目标

在视觉可信前，不继续扩张行为复杂度。

保留并调优：

- curiosity；
- hesitation；
- attention；
- calm/alert rhythm；
- passive drift；
- edge pressure；
- depth drift。

视觉成立后再加：

- alignment；
- cohesion；
- schooling confidence；
- fear propagation；
- comfort memory。

## 10. 水体方向

当前 torus ripple 是 prototype-only。

短期水体目标是诗意可信，不是物理真实。

### 立即目标

- 替换硬边 SCNTorus ripple 观感；
- 添加 depth color gradient；
- 添加 subtle animated caustic impression；
- 添加 underwater veil/fog；
- 添加鱼阴影/深度线索；
- 减少 flat-plane feeling；
- 效果必须安静、低对比。

### 暂缓目标

暂不做完整 GPU water simulation：

- height-field ripple simulation；
- fish wake field；
- rain field；
- normal map generation；
- Metal caustic distortion；
- full post-processing chain。

## 11. 触摸方向

触摸必须安静、有因果感。

默认 tap 不能喂食。

正确语义：

```text
tap water      -> soft ripple + nearby curiosity
tap near fish  -> fish notices or lightly evades
long press     -> gentle attention / attraction
drag           -> water trail / disturbance
feed button    -> occasional food, explicit mode only
Apple Pencil   -> quiet water stroke, no reward spam
```

反馈要即时，但不能吵。

## 12. 音频方向

音频重要，但不是当前最大阻塞点。

One Perfect Pond 阶段只需要定义结构，可选做极简 ambient prototype。

未来音频层：

- water；
- wind；
- distant birds；
- insects；
- bamboo/wood creaks；
- rain；
- fish proximity details；
- touch one-shots。

目标是 non-loop-feeling ambient sound，不是 BGM。

## 13. 里程碑

### M0 — 当前原型盘点

目标：记录现状并冻结功能扩张。

交付：

- 保留当前 SceneKit 原型；
- 保留当前鱼行为；
- 标记要删除的技术 demo 文案；
- 标记 tap feeding 为产品风险；
- 确认 One Perfect Pond 范围。

退出标准：

- 视觉基线开始前不再添加新产品系统。

### M1 — Cinematic Frame

目标：暂停截图也像高级产品。

交付：

- 调整相机角度与 FOV；
- 强化前景/中景/背景；
- 深色边缘处理；
- 荷叶/石头/苔藓/花瓣框景；
- 降低平面感。

退出标准：

- 第一屏不再像 debug prototype；
- 截图可作为内部 App Store 风格目标图。

### M2 — HUD Disappearance

目标：移除技术 demo 气质。

交付：

- 删除 SceneKit/native/fish-count/debug 文案；
- 添加克制 wordmark/time/season；
- 添加小 settings；
- 实现淡出/低存在感；
- 控件非游戏化。

退出标准：

- UI 不再把用户引导成“游戏/demo”的理解；
- 池塘仍是视觉主体。

### M3 — Credible Koi Silhouette

目标：鱼不再像几何体。

交付：

- 新低面数/stylized realistic koi mesh 或重做 procedural mesh；
- tapered body；
- translucent fins；
- 改善花纹；
- 材质调优；
- 保留现有 movement system。

退出标准：

- 静帧读起来像锦鲤；
- 动起来像生命体，不是 AI 几何体。

### M4 — Soft Water Illusion

目标：不用完整模拟也建立水深和诗意可信。

交付：

- 替换硬 torus ripple；
- soft additive ripple；
- depth gradient；
- underwater veil；
- caustic impression；
- 鱼阴影/深度调优；
- bloom/vignette 克制调优。

退出标准：

- 鱼像在水里；
- 触摸涟漪不再 prototype/arcade；
- 静帧和动帧都有深度。

### M5 — Calm Touch Semantics

目标：避免变成喂鱼游戏。

交付：

- 默认 tap 不再生成 food；
- tap water 只产生 ripple 和 curiosity；
- tap near fish 触发 notice/light evade；
- long press gentle attraction；
- feeding 为显式且偶尔的控制。

退出标准：

- 默认交互像扰动水面，而不是奖励循环。

### M6 — Three-Minute Watch Test

目标：验证 One Perfect Pond。

测试：

- 真机 iPad；
- 3 分钟 idle watching；
- 1 分钟轻交互；
- 1 分钟回到 idle。

验收：

- 第一秒高级；
- 没有明显 prototype UI；
- 没有街机效果；
- 没有明显机械循环；
- 帧节奏稳定；
- 不靠新功能也愿意继续看。

## 14. 性能目标

Vertical slice 目标：

- 最低稳定 60 fps；
- iPad Pro 尽量具备 120Hz readiness；
- 不做 per-frame texture creation；
- update loop 无重分配峰值；
- effect nodes 不无限增长；
- touch feedback 尽量一帧内可见；
- 视觉效果优先优雅降级，不能破坏帧节奏。

## 15. 决策规则

功能深度 vs 视觉可信度：选视觉可信度。

渲染纯度 vs art direction leverage：选 leverage。

真实模拟 vs 诗意可信幻觉：选可信幻觉。

更多 UI vs 更少 UI：选更少 UI。

游戏奖励 vs ambient causality：选 ambient causality。

## 16. One Perfect Pond 完成定义

One Perfect Pond 完成时必须满足：

- 第一秒高级；
- 暂停截图产品级；
- 鱼视觉足以支撑行为系统；
- 水体有深度和氛围；
- HUD 几乎消失；
- 默认触摸安静、有因果；
- 可连续观看 3 分钟而不依赖功能新鲜感；
- 仍保持原生、稳定，并为后续 selective Metal 升级留路。
