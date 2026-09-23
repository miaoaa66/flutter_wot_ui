# flutter_wot_ui 能力矩阵评估

> 定位：回答「这个库整体成熟度如何、短板在哪」，是**决策视图**。
> 与 `COMPONENT_AUDIT.md` 互补——后者是逐组件的问题清单与实施路径，本文件是跨组件的横向评估。
> 评估日期：2026-09-20　·　方法：源码静态检索与抽样核验（未执行 flutter test，结论以静态检索为准）

---

## 一、核心结论

能力**宽度已经达标**，欠账集中在**交付与工程保障**层，综合约 **6.0 / 10**。

组件 82 个、语义令牌主题体系完整、80 余个示例页、参数级中文注释覆盖接近 100%、版本与破坏性变更治理规范——在个人复刻项目中属上游水准。真正的短板是五项：无障碍语义、国际化、RTL、视觉回归测试、CI 与发布。

按投入产出比排序的推进顺序：**补 Semantics 与三态语义 → 文案集中管理 → Golden 测试与 CI → 其余 API 补齐**。

当前版本适合内部试用与个人项目，尚不足以支撑对外的、有可用性承诺的团队级依赖。

### 评分分布

| 维度 | 评分 | 状态 |
|---|---|---|
| 组件覆盖面 | 8.5 | 强 |
| 示例与 Demo | 8.5 | 强 |
| 主题令牌体系 | 8.0 | 强 |
| 文档与注释 | 8.0 | 好 |
| 版本治理 | 7.5 | 好 |
| API 对齐源库 | 7.0 | 部分 |
| 单组件完备度 | 6.5 | 部分 |
| 测试保障 | 5.5 | 部分 |
| 响应式与 RTL | 3.0 | 弱 |
| 工程化与发布 | 3.0 | 弱 |
| 国际化 | 2.5 | 弱 |
| 无障碍 | 2.0 | 缺口 |

---

## 二、库级能力（12 项）

| 能力项 | 标准要求 | 本库现状 | 评级 |
|---|---|---|---|
| 设计令牌体系 | 语义化颜色/字号/圆角变量，不散落硬编码 | `WotScheme` / `WotThemeData` / `WotColors`，Light+Dark，`copyWithPrimary` 换肤 | 强 |
| 全局配置下发 | 根节点统一配置，子层级联覆盖 | `WotConfigProvider` 已实现级联 merge，但**仅下发 button / tag 两类** | 部分 |
| 明暗模式 | 跟随系统 + 手动切换 | 支持 `themeMode` 与 `WotThemeData.dark` | 具备 |
| 国际化 i18n | 内置文案全部外置，多语言包可覆盖 | **仅有管道无内容**：`locale`/`localeMessages` 只在 config_provider 内自引用，82 个组件零消费；Dialog 默认写死「确定 / 取消」 | 缺口 |
| 无障碍 a11y | Semantics 标签、可聚焦、最小点击区、对比度 | 全库仅 video_preview 一个文件出现 Semantics（1 处，`semanticLabel` 快进/快退 15 秒） | 缺口 |
| 多端与 RTL | 安全区、断点、文本方向、桌面端 hover/焦点 | SafeArea 与 MediaQuery 有处理；**RTL 未实现**，桌面端 hover 态与键盘焦点链缺失 | 弱 |
| 版本治理 | 语义化版本、CHANGELOG、破坏性变更清单、废弃过渡 | 0.2.0 + CHANGELOG 完整记录 19 项破坏性变更，不可用参数改用 `@Deprecated` 并给替代方案 | 好 |
| 测试体系 | 单元 + Widget + Golden + 溢出冒烟 | 18 个测试文件，含 `render_smoke_test` 逐页渲染捕获 RenderFlex；**无 Golden 快照** | 部分 |
| 文档 | README + 逐参数 dartdoc + 在线 API 站 | README / DEMO_GUIDE / COMPONENT_AUDIT 质量高，参数注释覆盖近 100%；无在线文档站 | 好 |
| 示例 Demo | 每组件可运行 demo，覆盖主要参数组合 | 80+ 示例页逐组件覆盖，编写过程中反向发现两处死参数 | 强 |
| 依赖克制 | 最小依赖面，不强加网络/状态框架 | 运行时依赖仅 5 个；Upload 用条件导入规避 `dart:io` 限制而非强绑 `http` | 好 |
| 发布与 CI | pub.dev 发布、自动化 analyze/test | `publish_to: none`，仅 git 依赖；无 CI 配置 | 缺口 |

---

## 三、组件级能力（10 项）

| 能力项 | 标准要求 | 本库现状 | 评级 |
|---|---|---|---|
| 受控与非受控 | 外部传值受控 + 内部自管；外部变更须 `didUpdateWidget` 响应 | 40 个文件实现 didUpdateWidget；picker / swipe_action / count_down 三处受控失效已修复 | 基本达标 |
| 状态完整性 | default / loading / disabled / readonly / error / focus / empty 语义清晰 | 已建立 **disabled / readonly / error 三态语义规范**（`wot_state.dart`，单一真相源），并在 input / textarea / cell / form_item 试点落地；其余组件待按规范推广 | 部分（规范已立，覆盖待扩） |
| 类型安全 | 外观类参数用枚举而非字符串 | Button / Tour 已枚举化；`tabs.type`、`segmented.shape`、`select_picker.type` 仍为字符串 | 部分 |
| 自定义插槽 | 提供 `(context, item, index) => Widget` 型 builder | 扩展点以 `child`/`children` 为主，builder 型插槽仅 `WotTable` 一处 | 弱 |
| 控制器暴露 | 可注入 controller / focusNode，支持编程控制 | Input 已补 controller / focusNode / inputFormatters；Tabs 支持 TabController；Navbar 实现 PreferredSizeWidget；Picker / Cascader / Signature 尚不完整 | 部分 |
| 表单集成 | 与 Form 双向登记值、触发校验、展示错误 | Form 校验体系已重构（自定义消息、触发时机、单字段校验）；switch/rate/slider 已接，**checkbox / radio 未登记** | 部分 |
| 拦截式回调 | 关键动作提供 beforeXxx 拦截 | switch 的 `beforeChange`、sidebar / drop_menu / dialog 拦截未补齐 | 弱 |
| 动画可控 | 时长/曲线可配，可关闭 | Popup 已实现 AnimationController 与 easeOutCubic；Swiper 的 curve 与 indicator 体系仍缺 | 部分 |
| 边界防御 | 超长文本、空数据、极端尺寸不崩溃不溢出 | 有溢出冒烟测试兜底；硬编码魔数仍普遍（Segmented 非 block 宽度 `options.length × 88`、Navbar 胶囊固定 180×34） | 部分 |
| 注释与约定 | 公开 API 全部注释；命名、参数顺序一致 | `Wot` 前缀统一、目录对齐、`onXxx` 回调命名一致，注释覆盖率极高 | 强 |

---

## 四、三项优先缺口与修复路径

### 缺口一：无障碍语义（严重・低成本）

Flutter 的无障碍依赖 Semantics 树，自绘 Widget 不会自动生成语义节点。当前 82 个组件中仅 1 个文件使用 Semantics，屏幕阅读器用户几乎无法理解界面内容。这是「组件能否进团队生产环境」的硬门槛之一。

**路径**：先建基准确认现状（见附录 H 的 T1.1），再按「交互类组件先行」分批补 `semanticLabel`、`button: true`、`toggled`、`value` 语义；纯展示组件加 `excludeFromSemantics` 避免噪音。

### 缺口二：文案硬编码（高・中成本）

`WotConfigProvider` 已预留 `locale` 与 `localeMessages`，但除自身定义外零组件读取——已建好却未接线的管道。文案散落各处：Calendar 135 处、Table 126 处、Input 93 处、VideoPreview 92 处、ImgCropper 75 处。

**路径**：先抽 `WotMessages` 集中管理（保留现有默认值以维持兼容），新增 `tr(context, key)` 并接入既有 locale 管道；再按文案密度倒序替换。管道打通后，支持英文只是补一份 Map 的工作量。

### 缺口三：视觉回归与 CI（中・低成本，长期收益最高）

现有 `render_smoke_test` 能捕获 RenderFlex 溢出，但无法发现「样式悄悄变形」。而本库刚完成 19 项默认值破坏性变更、17 个组件改动，恰恰是最容易出现视觉回归的时刻。

**路径**：为 Top 20 高频组件建立 Golden 快照（固定单一平台与 Flutter 版本生成基线）；接入 CI 跑 analyze + test；若计划对外发布，需补 example、dartdoc 与平台声明。

---

## 五、推进顺序

| 优先级 | 内容 |
|---|---|
| **P0** | 交互类组件补 Semantics；disabled / readonly / error 三态语义规范 —— ✅ **规范已建并试点**（2026-09-20，`wot_state.dart` + input / textarea / cell / form_item），待推广至其余录入/展示组件 |
| **P1** | 抽 `WotMessages` + `tr()` 接通 locale 管道；Checkbox / Radio 接入 Form 值登记；字符串外观参数枚举化 |
| **P2** | Golden 测试覆盖 Top 20 组件；接入 CI；补 Sticky、Resize 等源库缺口组件 |
| **P3** | 魔数主题化为 `WotXxxTheme`；builder 型插槽体系化；Sliver / ScrollController / Hero 生态适配 |

---

## 六、评估证据（静态检索来源）

| 检索项 | 结果 | 说明 |
|---|---|---|
| `Semantics｜semanticLabel｜excludeFromSemantics` | 1 文件 / 1 处 | video_preview（`wot_video_preview.dart:787`） |
| `localeMessages｜WotMessages｜tr(context` | 1 文件 | 仅 config_provider 自身定义，无组件消费 |
| 中文字符串 `[\u4e00-\u9fa5]` | 82 文件 | lib/src 下近乎全覆盖，含大量默认文案 |
| `Directionality｜TextDirection｜Localizations` | 6 文件 | 多为 MediaQuery 用途，RTL 未系统性支持 |
| `didUpdateWidget` | 40 文件 | 受控能力覆盖的主要证据 |
| `builder?｜ItemBuilder｜widgetBuilder` | 1 文件 | 仅 WotTable |
| `goldenFile` | 0 | 无视觉回归测试 |
| `.github/workflows` | 不存在 | 无 CI |
| 测试文件 | 18 | test/ 13 + example/test/ 5 |
| 版本 / 发布 | 0.2.0 / none | CHANGELOG 齐备，未发布 pub.dev |
