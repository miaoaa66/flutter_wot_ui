# flutter_wot_ui 组件库配置项审查报告

> 审查基准：Vue/uni-app 版 `wot-ui/docs/component/*.md` 的 `## Attributes` 表（同工作区 `wot-ui/`）
> 审查范围：`lib/src/components/` 下 **82 个公开组件**（81 个组件目录；源码文件 84 个，含 Upload 的 2 个条件导入实现文件），约 1.4 万行
> 审查日期：2026-09-15 ｜ 复核修订：2026-09-16（状态同步、补破坏性变更清单与 F 类、上调工作量估算）｜ 2026-09-20（同步执行状态与组件数口径）

---

## 一、总体结论

组件库整体完成度较高——Button、NoticeBar、PasswordInput、Pagination、Loadmore、Empty、Calendar、Tour 等已与 Vue 版高度对齐。但存在 **多类系统性问题**，其价值高于单点补参数：

| 类别 | 数量 | 性质 | 建议处理节奏 |
|---|---|---|---|
| **A. 死参数**（声明了但代码从未消费） | **18 处** | 缺陷，非增强 | ✅ **已全部处理**（2026-09-16） |
| **B. 默认值与 Vue 漂移** | **19 项** | 跨端一致性问题 | ✅ **已全部对齐**（2026-09-16） |
| **C. 受控失效**（缺 `didUpdateWidget`） | **3 处** | 功能性缺陷 | ✅ **已全部修复**（2026-09-16） |
| **F. 独立缺陷**（单点 bug，不属 A–E） | **4 项** | 功能性缺陷 | ✅ **已全部修复**（2026-09-16） |
| D. 缺失配置项 | 120+ 项 | 增强 | 分批补 |
| E. 硬编码魔数 | 普遍 | 可维护性 | 主题化重构 |

**核心判断**：A 类（18 处死参数）与 B 类（19 项默认值对齐）**均已处理完毕并完成破坏性变更说明**。
下一阶段应转向 **C/D 类**：D 类 P0 里 `upload`（当前是模拟上传，不可投产）、`form` 校验体系
（`_values` 仅支持 `String`，导致 switch/rate/slider 的 `name` 全部失效）是真正的阻断项。

---

## 二、A 类：死参数清单（最高优先级）

以下参数已出现在构造函数与文档中，但 `build` 流程从未消费。已逐一核验源码。

| # | 组件 | 参数 | 证据 | 处理建议 |
|---|---|---|---|---|
| ~~1~~ | `wot_popup` | 动画 | `:255-263` `_slide`/`_scale` 返回 `AlwaysStoppedAnimation` | **已实现**（2026-09-16）`AnimationController` + `Tween` + `easeOutCubic`，`duration` 现在作用于弹层本体 |
| ~~2~~ | `wot_swiper` | `loop` | `:73` `_canLoop` 仅用于自动播放取模，`PageController` 非无限 | **已实现**（2026-09-16）大数取模法：`initialPage = 10000`、`itemCount: null`、取模复用子项 |
| ~~3~~ | `wot_tabbar` | `fixed` | `:176` 注释自认"演示不适用" | **已处理**（2026-09-16）`@Deprecated`（Flutter 由父级决定布局，指引改用 `Scaffold.bottomNavigationBar`） |
| ~~4~~ | `wot_input` | `type` | `:292` 注释自认"当前未影响键盘类型" | **已实现**（2026-09-16）`_keyboardTypeOf` 映射 number/digit/tel/email/url |
| ~~5~~ | `wot_icon` | `classPrefix` | `:131` 赋值后完全不参与解析 | **已移除**（2026-09-17）参数与字段删除（Flutter 无 CSS class 语义，从未生效）；`WotButton.classPrefix` 同性质死参数一并移除 |
| 6 | `wot_icon` | 名称解析 | `:115` `name.replaceAll('-', '-')` **无效自替换** | 疑似本应实现 v1→v2 图标名迁移（add→plus 等），实为 bug |
| ~~7~~ | `wot_dialog` | `type` | `:106` 注释称"决定左侧辅助色条"，build 中未渲染 | **已实现**（2026-09-16）左侧 4px 辅助色条 + `clipBehavior: antiAlias` |
| ~~8~~ | `wot_overlay` | `zIndex` | `:54` 注释承认未使用 | **已处理**（2026-09-16）`@Deprecated`，注明改用父级 Stack 顺序 |
| ~~9~~ | `wot_watermark` | `zIndex` | `:74` 注释承认是"期望值" | **已处理**（2026-09-16）`@Deprecated`，注明改用 `fullScreen` |
| ~~10~~ | `wot_popover` | `showArrow` | `:47` 注释自认"暂未绘制箭头" | **已实现**`_BubblePainter` 单一路径一次性绘制气泡+箭头（连续边框+阴影，无接缝），箭头方位由生效 `placement`（含翻转）推导 |
| ~~11~~ | `wot_count_to` | `speed` | `:13,33` 声明后未使用 | **已实现**（2026-09-16）`duration = |modelValue| / speed` |
| ~~12~~ | `wot_input_number` | `longPress` | `:21,56` 声明后全文未出现 | **已实现**（2026-09-16）长按 120ms 周期连续步进，到边界自动停 |
| ~~13~~ | `wot_slide_verify` | `errorText` | `:15,25` 声明后未使用 | **已实现**（2026-09-16）失败态展示 1.2s 后自动复原 |
| ~~14~~ | `wot_action_sheet` | `WotActionSheetItem.icon` | `:29` 声明后从未渲染 | **已实现**（2026-09-16）图标 + 文字横向排列 |
| ~~15~~ | `wot_steps` | `WotStepData.status` | `:16` 定义，全文件未读取 | **已实现**（2026-09-16）`waiting` 视为未指定→按索引推导；`finished`/`process`/`error` 生效 |
| ~~16~~ | `wot_skeleton` | `WotSkeletonItem.animate` | `:180` 接收后未使用 | **已实现**（2026-09-16）改为 StatefulWidget + 闪烁动画 |
| ~~17~~ | `wot_picker_view` | `WotColumnOption.disabled` | `:10` 定义，渲染与滚动均未跳过 | **已实现**（2026-09-16）置灰 + 滚动吸附到最近可用项 |
| ~~18~~ | `wot_grid` | `reverse` | `:17` 声明，`build` 未消费 | **已实现**（2026-09-16）先整体倒序再按列切分 |
| ~~19~~ | `wot_watermark` | `fullScreen` | ~~`:20` 声明、`build` 未引用~~ | **已修复**（2026-09-16）：已用 `Overlay` 实现全屏分支，默认值改为 `true`，详见第三节 |
| ~~20~~ | `wot_popup` | `safeArea` | `:82` 声明，`build` 的 `SafeArea` 只按 `position` 推导贴边侧，从未读取该参数 | **已实现**（2026-09-16）false（默认）只避让贴边侧，true 时四边全避让；保持原默认行为不变，无破坏性 |
| ~~21~~ | `wot_popup` | `safeAreaInsetBottom` | `:86` 声明，同上未被读取 | **已实现**（2026-09-16）非空时单独覆盖底边取值 |

> **#20 / #21 是补示例页时发现的，不在原 18 项清单内。**
> 再次验证那条经验：「写不出演示的参数，往往就是不生效的参数」——
> 给 `safeArea` 写 demo 时才发现无论传 true 还是 false 渲染都一模一样。
> 推论：A 类清单可能还有类似漏项，**补示例页应作为死参数的常规排查手段**，而非事后动作。

**另有 2 处"参数名不副实"**（非 bug，属文档误导，建议标注）：
- `wot_img_cropper` 的 `outputType=jpg` 与 `quality`：`:335-341` 代码注释已说明 Flutter 原生 `toByteData` 仅支持 PNG，故恒输出 PNG。建议加 `@Deprecated` 或在文档注明。
- `wot_drop_menu` 的 `closeOnClickOverlay` 与 `duration`：均无对应实现（无蒙层、无动画）。

---

## 三、B 类：默认值与 Vue 漂移（跨端一致性）

跨端复用同一份业务代码时，这些差异会造成**同代码不同表现**。

已逐项核查源码注释、示例页调用情况与库内覆盖。**判定**：「无意偏差」= 注释仅描述功能、无任何选值理由，且与同库兄弟组件处理方式不一致；「存疑」= 有实现层面的倾向性证据但注释未明示。

| 组件 | 参数 | 当前值 | Vue 值 | 判定 | 建议 |
|---|---|---|---|---|---|
| `wot_input_number` | `min` / `max` | `0` / `100` | `1` / `MAX_SAFE_INTEGER` | 无意偏差 | **优先对齐**——会静默截断数据；需复核示例页 `_n2=0` |
| `wot_select_picker` | `type` | `radio` | `checkbox`（**行为相反**） | 无意偏差 | 对齐（示例页 10 处均已显式传参，改动零成本） |
| `wot_swiper` | `autoplay` / `interval` / `duration` | `false` / `3000` / `500` | `true` / `5000` / `300` | 无意偏差 | 对齐（`autoplay` 影响面最大：示例页 6 处实例未传参） |
| `wot_notify` | `duration` | `2500` | `3000` | 无意偏差 | 对齐（示例页文案写「3 秒后关闭」，实锤抄错） |
| `wot_circle` | `size` / `strokeWidth` | `100` / `14` | `120` / `18` | 无意偏差 | 对齐（示例页已手写 `strokeWidth: 18`，说明参考源就是 Vue） |
| `wot_qr_code` | `size` / `errorLevel` | `160` / `m` | `200` / `H` | 无意偏差 | 对齐（附：Vue 参数名为 `correct-level`，命名不一致） |
| `wot_grid` | `square` | `true` | `false` | 无意偏差 | 对齐（影响示例页约 10 处未传参实例） |
| `wot_navbar` | `leftArrow` | `true` | `false` | 无意偏差 | 对齐（需同步给示例页 `:17` 补 `leftArrow: true`） |
| `wot_tabbar` | `bordered` | `true` | `false` | 无意偏差 | 对齐（navbar / cell_group 均为 `false`，仅此例外） |
| `wot_gap` | 默认高度 | `12` | `14` | 无意偏差 | 对齐 |
| `wot_count_to` | `duration` | `2000` | `3000` | 无意偏差 | 对齐 |
| `wot_notice_bar` | `speed` | `60` | `50` | 无意偏差 | 对齐 |
| `wot_tour` | `borderRadius` / `offset` | `8` / `16` | `4` / `20` | 无意偏差 | 对齐（同组 `maskPadding=8` 与 Vue 一致，属抄漏） |
| `wot_curtain` | `maskClose` | `true` | `false` | 无意偏差 | 对齐 |
| `wot_datetime_picker` | `type` | `date` | `datetime` | 无意偏差 | 对齐（示例页 5 处均显式传参，改动无影响） |
| `wot_watermark` | `imageWidth` / `rotate` | `40` / `-22` | `100` / `-25` | 无意偏差 | 对齐 |
| `wot_calendar` | `switchMode` | `month` | `none` | 已对齐 | **必须配套**：见下方「平铺模式的前提」 |
| `wot_calendar` | `firstDayOfWeek` | `1` | `0` | 已对齐 | 代码本就存在 `==0` 分支，仅改默认值即可 |
| `wot_watermark` | `fullScreen` | `false` | `true` | 已对齐 | 原为死参数（build 未引用），已用 Overlay 实现全屏 |

**统计**：19 项**全部已对齐**。原 16 项判为无意偏差；3 项存疑经可行性评估后确认 Flutter 均可实现，故一并对齐。**没有任何一项的注释给出「国内习惯 / Flutter 端简化 / 对齐 Material」之类的适配理由**。

**判定为无意偏差的强证据**：
1. `wot_notify` 示例页按钮文案写「**3 秒后关闭**」，但默认值是 2500ms——作者预期就是 3000
2. `wot_circle` 示例页 `:20` 手写 `strokeWidth: 18`（= Vue 默认值）——照着 Vue 写，却没落到默认值上
3. `wot_swiper` 与 `wot_qr_code` 的类注释都明写「参数对齐 wot」，实际取值却不符——声明与实现矛盾

**无全局覆盖**：`wot_config_provider` 仅下发 button / tag 两类默认值，`wot_theme_data` 无相关键。上述默认值全部硬编码在构造函数，可直接改。

### 平铺模式的前提（关键，不可遗漏）

`switch-mode: none` 的语义是**平铺展示所有月份**。Vue 的 `min-date` / `max-date` 默认为「当前日期 ±6 个月」
（`calendar.md:208-209`），因此平铺范围是可控的 12 个月。

而 Flutter 版原先将两者默认为 `null`，内部兜底为 ±20 年。
**若只把 switchMode 改成 none 而不补日期范围，会一次性渲染约 40 年 × 12 = 480 个月，导致严重卡顿。**

本次已配套补上：`_defaultMinDate()` / `_defaultMaxDate()` 取当前日期 ±6 个月，
在 `_MonthGridState` 消费端以 `widget.minDate ?? _defaultMinDate()` 兜底。
（Dart 构造函数默认值必须是编译期常量，无法直接写 `DateTime.now()`，故不能写在参数默认值里。）

### 全屏水印的实现（watermark.fullScreen）

该参数原先是死参数——`build` 从未引用。Vue 的 `full-screen` 语义是浮在整个页面上（类似 CSS fixed 定位），
Flutter 的对应物是 `Overlay`（脱离当前布局树）。实现要点：

- `fullScreen == true` 时由 `OverlayEntry` 承载水印，`build` 只渲染 `child`
- 浮层的插入 / 刷新 / 移除统一由 `initState`、`didUpdateWidget`、`dispose` 驱动；
  插入用 `addPostFrameCallback` 延后，避免在 build 阶段操作 Overlay 触发重入错误
- 用 `Overlay.maybeOf` 而非 `of`，在无 Overlay 的上下文中安全降级
- 图片异步加载完成后调用 `_syncOverlay()` 刷新浮层

### 执行状态（2026-09-16）

**19 项默认值全部对齐 Vue**。`dart analyze` 通过，11 条提示与改动前基线完全一致，零新增。

改动文件：17 个组件源码 + 4 个示例页。
- 示例页同步：`swiper`（新增默认轮播演示，其余实例显式关闭）、`grid`（`_square` 初值跟随）、
  `navbar`（首个 demo 补 `leftArrow: true` 并修正标题）、`watermark`（改为内嵌 / 全屏可切换对比）
- `calendar` 示例页「内嵌单选日历」补了 `switchMode: month`，保证「点击年月快速跳转」名实相符

**遗留副作用（需注意）**：`WotInputNumber` 的 `modelValue` 默认仍为 `0`，而 `min` 已改为 `1`，
且 `initState` 会执行 `clamp(min, max)`——因此**不传参时默认显示 1 而非 0**。
Vue 版 `v-model` 无默认值（空），Flutter 因 `num` 不可空只能取 `0`，属必要妥协。若业务期望默认从 0 起，需显式传 `min: 0`。
示例页 `wot_input_number_page.dart:30` 已显式传 `min: 0` 规避，可作参考写法。

---

### 破坏性变更清单（迁移必读）

本次 19 项对齐**全部属于破坏性变更**——凡业务代码中**不显式传参**的实例，升级后表现会变。
库中不存在全局覆盖机制（`wot_config_provider` 仅下发 button / tag），因此影响面只能靠代码排查。

**高危（视觉形态或交互行为改变，肉眼可见）**

| 参数 | 变更 | 不传参时的实际后果 |
|---|---|---|
| `select_picker.type` | `radio` → `checkbox` | **行为相反**：单选变多选 |
| `swiper.autoplay` | `false` → `true` | 轮播开始自动播放（示例页 6 处实例受影响） |
| `swiper.interval` / `duration` | `3000/500` → `5000/300` | 播放节奏变化 |
| `grid.square` | `true` → `false` | 栅格由正方形变为内容高度，布局整体变形 |
| `navbar.leftArrow` | `true` → `false` | 返回箭头消失（示例页已补 `leftArrow: true`） |
| `calendar.switchMode` | `month` → `none` | 日历由「可切月」变为「平铺全部月份」 |
| `calendar.firstDayOfWeek` | `1` → `0` | 周起始由周一变为周日 |
| `input_number.min` | `0` → `1` | 不传参时默认显示 1 而非 0 |

**中危（数值/间距微调）**

`input_number.max`(100→MAX_SAFE_INTEGER)、`notify.duration`(2500→3000)、
`circle.size/strokeWidth`(100/14→120/18)、`qr_code.size/errorLevel`(160/m→200/H)、
`tabbar.bordered`(true→false)、`gap`(12→14)、`count_to.duration`(2000→3000)、
`notice_bar.speed`(60→50)、`tour.borderRadius/offset`(8/16→4/20)、
`curtain.maskClose`(true→false)、`watermark.imageWidth/rotate`(40/-22→100/-25)、
`datetime_picker.type`(date→datetime)、`watermark.fullScreen`(false→true)。

**待办**：
1. 业务侧自查——全局搜索上述参数名，凡未显式传参处需评估是否要补显式值
2. `version: 0.1.0` 建议在发布破坏性变更时升至 `0.2.0`，并新建 `CHANGELOG.md` 记录本清单
3. `select_picker.type` 与 `swiper.autoplay` 影响面最大，建议列为升级检查项

---

## 四、C 类：受控失效（缺 `didUpdateWidget`）

外部改变入参时组件不响应，是明确的功能性缺陷。

| 组件 | 现象 |
|---|---|
| `wot_picker` | `:102` 仅在 `initState` 做 `_clamp`，外部改 `values` 不生效 |
| `wot_swipe_action` | `:90-165` 完全未实现，外部改 `show` 无法同步展开态（列表侧滑删除无法复位） |
| `wot_count_down` | `:53-58` 重置 `_remaining` 后既不重启也不停止定时器 |

---

## 四·补、F 类：独立缺陷（原散落在实施路径中，现单列）

这三项原先只出现在「建议实施路径」里，不属 A/B/C/D/E 任何一类，没有独立清单与验收标准，容易被漏掉。现单列：

| # | 组件 | 现象 | 验收标准 |
|---|---|---|---|
| F1 | `wot_toast` | loading 未传 `duration` 却落 2000ms 默认（`:111-117`），违背 Vue「loading 常驻直到手动关闭」语义 | loading 态不自动消失，只能 `close()` |
| F2 | `wot_image_preview` | 页码未受 `showIndex` 控制（`:159-173`） | `showIndex: false` 时不显示页码 |
| F3 | `wot_tabbar` | `:240-255` clone item 时丢弃 `item.onClick` | 切换 tab 时原 item 的 `onClick` 被触发 |
| F4 | wot_img | onLoad / onError 在 loadingBuilder / errorBuilder（build 阶段）同步触发 | 调用方在回调里 setState 不再崩溃；回调延后到本帧构建结束后 |

> 复核记录（2026-09-16）：F1 已确认仍存在——`wot_toast.dart` 的 `:26` / `:57` / `:76` 三处一律 `?? const Duration(milliseconds: 2000)`，loading 未做分支处理。

---

## 五、D 类：高价值缺失配置项（按优先级）

### P0 — 不补会阻断业务落地

| 组件 | 缺失项 | 说明 |
|---|---|---|
| **upload** | `action` / `header` / `formData` / `uploadMethod` / 进度与失败态 | ✅ **已实现**（2026-09-16）见第九节 |
| **form / form_item** | `model` / 规则返回自定义消息 / `validateTrigger` / `validate(prop)` / `reset()` / `errorType`；FormItem 缺 `onTap`/`clickable`/`isLink` | ✅ **已实现**（2026-09-16）见第九节 |
| **input** | `controller` / `focusNode` / `inputFormatters` / `autofocus` / `textAlign` / `error` / `onSubmitted` | ✅ **已补**（2026-09-17）除 `textAlign` / `error` 外全部到位，`WotInput` 与 `WotTextarea` 均已暴露，见第十节 |
| **signature** | 图片导出（`fileType`/`quality`/`exportScale`/`onConfirm`）、`enableHistory` + `revoke`/`restore` | ✅ **已实现**（2026-09-17）见第十节 |
| **tabs** | `TabController`（可选注入）、`onPageChanged`、指示器全套、`sticky` | ✅ **已实现**（2026-09-17）见第十节（`sticky` 吸顶未做） |
| **navbar** | `implements PreferredSizeWidget` + `preferredSize` | ✅ **已实现**（2026-09-16）见第十节 |
| **floating_panel** | `anchors` 数组 + 受控 `height`/`onHeightChange` + 吸附回弹动画 | ✅ **已实现**（2026-09-17）见第十节 |
| **image_preview** | `closeable` / `closeIconPosition` | ✅ **已实现**（2026-09-16）见第十节 |
| **swipe_action** | `didUpdateWidget` + 开合动画 + `threshold` + `beforeClose` | 见 C 类 |
| **cascader** | `title`（现硬编码"选择地区"）/ key 映射 / `lazyLoad` / `checkStrictly` | 仅 7 个参数，异步加载缺失 |
| **picker_view** | `itemHeight`(44) / `visibleItemCount`(6) / `valueKey`·`labelKey`·`childrenKey` / `cascade` | 🔶 **部分实现**（2026-09-16）见第十节；2026-09-17 补 `WotPickerView` 对 `itemExtent`/`visibleItemCount` 的透传（原先只加在 `WotPickerViewColumn` 上，公开多列入口改了没反应） |

### P1 — 常见需求，值得补

| 组件 | 缺失项 |
|---|---|
| **cell** | `placeholder` / `layout`(vertical) / `padding` / `arrowDirection` / 四个 `TextStyle` |
| **cell_group** | `title` / `value` + InheritedWidget 下发通道（Vue 侧分组属性继承是标准用法） |
| **text** | `mode`(date/phone/name/price) + `format` 脱敏 + `prefixWidget`/`suffixWidget` + `style` |
| **switch** | `activeValue` / `inactiveValue`（对接 `'1'/'0'` 后端协议）+ `beforeChange` |
| **qr_code** | `logo` / `dotType` / `gapless`+`margin` / `onError`（`qr_flutter` 已支持，仅需透传） |
| **notify** | `position` / `color` / `background` / `closable` / `safeHeight` / `onClick` / `onOpened` / `onClosed`（15 项缺 9 项） |
| **count_down** | `millisecond` 毫秒级（`SS` 当前恒为 00）+ `start`/`pause`/`reset` |
| **count_to** | `startVal`（当前恒从 0 开始） |
| **sort_button** | `allowReset` / `descFirst` |
| **drop_menu** | `modal` 蒙层（当前点击外部不关闭）+ `popupHeight` + `beforeToggle` |
| **curtain** | `src` 图片能力（缺此组件名不副实）+ `closePosition` |
| **dialog** | `beforeConfirm` / `actionLayout` / `actions` |
| **swiper** | `direction` / `curve` / 指示器体系 / `viewportFraction` / 外部 `controller` |
| **img** | `imageProvider`（asset/文件/内存）+ `cacheWidth`/`cacheHeight` + `showLoading`/`showError` |
| **skeleton** | `theme` + `rowCol` + `animation`(gradient/flashed)（现 API 与 Vue 不同源，迁移成本高） |
| **tag** | `variant: dashed` + `dynamic` 新增标签 |
| **badge** | `type` / `shape` / `value` 支持 String / `showZero` / `top`·`right` 偏移 |
| **sidebar** | `scrollController`（锚点场景必需）+ `beforeChange` |
| **keyboard** | `value` + `maxlength` + `SafeArea` |
| **checkbox / radio** | `type: button` / `dot` 形态；radio 缺 `readonly`、`size` |
| **fab** | `disabled`（Vue 有而 Flutter 完全没有）+ `position` 8 向 + `direction` + `draggable` |

---

## 六、E 类：硬编码魔数（建议主题化）

全库反复出现的魔数，建议抽取为 `WotXxxTheme` 或组件级常量类：

- **字号**：12 / 13 / 14（几乎每个组件都写死）
- **圆角**：4 / 6 / 8 / 12
- **间距**：8 / 10 / 12 / 16
- **典型单点**：
  - `wot_slider`：thumb 28×28、轨道高 3、整体高 56（本组最密集）
  - `wot_segmented` `:130` 非 block 时宽度 `options.length * 88.0`，长文案必截断
  - `wot_navbar` `:159-160` 胶囊固定 `180×34`，窄屏必然溢出
  - `wot_calendar` `:1214` topInfo/bottomInfo 字号 **8**，过小且不可配
  - `wot_select_picker` `:490` 弹层高 `430` 写死，小屏易溢出
  - `wot_cascader` `:212-244` `Column(min)` 内嵌 `Expanded` → **需实测确认**（见下方说明）
  - `wot_pagination` `:561` 文件末尾定义全局常量 `kWhite`，应直接用 `Colors.white`

**关于 `wot_cascader` 的 RenderFlex（分类纠错）**：原报告判定为「典型溢出崩溃」，但复核调用链后存疑——
`_CascaderSheet` 由 `showModalBottomSheet` 承载（`:111`），父级高度**有界**（默认上限为屏幕高 9/16），
因此 `Expanded` 大概率不会触发无界约束报错。**结论：降级为待实测，不按崩溃处理。**
若实测确认无问题则注销本条；若复现则应从 E 类（可维护性）**提升至立即修复**——
本报告的 A/B/C/D/E 分类缺少「运行时崩溃」这一维度，是分类体系本身的缺口。

---

## 七、实施路径（2026-09-16 修订版）

> **与原版的三处差异**（原版存在状态过期与估算偏差，已作废）：
> 1. 原批次一第 2 条「修正 B 类 16 处」**已完成**，从计划中移除
> 2. 原「批次一第 4 条的 3 个单点 bug」单列为 **F 类**，不再是无清单的孤儿条目
> 3. 工作量估算上调——原「1–2 天 / 3–5 天」参照上一轮实测明显偏低

### 批次零：破坏性变更迁移（0.5 天，必须先于发布）

B 类 19 项对齐已落库但未对外说明，**这是当前最高风险项**：

1. 新建 `CHANGELOG.md`，录入第三节的「破坏性变更清单」
2. `pubspec.yaml` `version: 0.1.0` → `0.2.0`
3. 业务侧自查：全局搜索高危 8 项参数名（`select_picker.type`、`swiper.autoplay`、`grid.square`、
   `navbar.leftArrow`、`calendar.switchMode`、`calendar.firstDayOfWeek`、`input_number.min`、`swiper.interval`），
   凡未显式传参处评估是否补显式值

### 批次一：缺陷修复（3–4 天）

| 序 | 内容 | 量 | 备注 |
|---|---|---|---|
| 1 | A 类 **18 处死参数** | 18 | 能实现的补实现（popup 动画、swiper.loop、input.type、popover.showArrow…），不能实现的移除或 `@Deprecated` |
| 2 | C 类 **3 处** `didUpdateWidget` | 3 | picker / swipe_action / count_down |
| 3 | F 类 **3 项**独立缺陷 | 3 | toast loading / image_preview showIndex / tabbar onClick |
| 4 | 每改一项 → 示例页同步（`DEMO_GUIDE.md` checklist） | — | 含兜底动作：**改完用 Grep 扫旧值回归** |

> **估算依据**：上一轮仅「16 个默认值 + 3 个示例页」就出现 4 处 agent 报「已改」而未落盘。
> 本批次 24 项且涉及真实逻辑实现（非单纯改数值），按 3–4 天计。

### 批次二：P0 补齐（拆两小批，各 3–5 天）

原「3–5 天完成四项」低估——其中 form 校验体系重构单项的量级就接近该估算。

- **2a（阻断项，优先）**：`upload` 真实上传（当前 `:229` 是模拟上传，**不可投产**）、
  `form` / `form_item` 校验体系（`_values` 仅支持 `String`，switch/rate/slider 的 `name` 全失效）、
  `input` 基础输入能力（`controller` / `focusNode` / `inputFormatters`）
- **2b**：`tabs` TabController、`signature` 图片导出、`navbar` `PreferredSizeWidget`、
  `picker_view` 底座参数（`itemHeight` / `visibleItemCount` / key 映射 / `cascade`——
  picker / cascader / datetime / calendar 全部受益）、`floating_panel` anchors、`image_preview` 关闭按钮
- 组件补齐后**紧接着**补对应示例页（`DEMO_GUIDE.md` 第三批）

### 批次三：体系重构（持续，无终止条件）

- 字符串参数改枚举（`tabs.type`、`segmented.shape`/`size`、`select_picker.type`、`slider` 等）
- 硬编码魔数主题化（E 类）
- Flutter 生态适配：`Sliver` 变体、`ScrollController`、`SafeArea` 参数化、`Hero` 转场
- 建立 `WotXxxTheme` 体系，避免逐组件硬编码

### 分类体系的已知缺口

A/B/C/D/E/F 均按「问题成因」划分，**缺少「运行时崩溃 / 报错」这一严重度维度**。
后果如 `wot_cascader` 的 RenderFlex 被归入 E 类（可维护性 / 持续），若是真崩溃则严重度被严重低估。
建议后续在清单中增补一列「严重度：崩溃 / 功能失效 / 表现不符 / 可维护性」，与成因分类正交。

---

## 八、组件缺口（Vue 有、Flutter 无）

| 组件 | 说明 | 优先级 |
|---|---|---|
| `wd-textarea` | **非完全缺失**——已实现为 `wot_input.dart:486` 的 `WotTextarea`，但未独立成目录，属归档/命名缺口 | P1（整理即可） |
| `wd-sticky` | 完全缺失 | P1 |
| `wd-datetime-picker-view` | 现有 `WotDatetimePickerView` 不支持区间/formatter/filter/秒级 | P1 |
| `wd-resize` | 完全缺失（可用 `LayoutBuilder` 替代） | P2 |
| `wd-root-portal` | 完全缺失（可用 `Overlay` 替代） | P2 |
| `WotBarcode` | **反向缺口**——Flutter 独有扩展，Vue 无对应组件 | — |

---

## 附：完成度较高的组件（无需大改）

`Button`、`NoticeBar`（19 参数，覆盖 Vue 10 项中的 9 项）、`PasswordInput`、`Pagination`（且有超出 Vue 的增强）、`Loadmore`、`Empty`、`Calendar`（26 参数）、`Tour`（20 参数）、`Overlay`、`Divider`、`ConfigProvider`。

---

## 九、执行进度（2026-09-16）

### 批次零：破坏性变更迁移 —— 已完成

1. 新建 `CHANGELOG.md`，完整录入 19 项破坏性变更（高危 8 项 + 中危 13 项）与迁移建议
2. `pubspec.yaml` `version: 0.1.0` → `0.2.0`
3. 影响面自查：各组件在 `lib/` 内无互相调用，影响面落在示例页与测试
   - **测试侧发现并修复 2 处**（此前未被发现，因只跑 `dart analyze`、从未跑测试）：
     - `test/calendar_type_test.dart`「datetimeRange 受限高度」用例会**直接失败**——
       该用例把日历放进固定 480px 容器（无滚动），而 `switchMode` 默认值改为 `none` 后需平铺 12 个月；
       已显式补 `switchMode: month`
     - `test/watermark_overflow_test.dart` 两个用例语义失效——`fullScreen` 默认改为 `true` 后
       水印改由 Overlay 全屏承载、根本不在容器内，用例断言变成空转；已显式补 `fullScreen: false`

> **重要更正**：此前判断「项目无任何 widget test」有误。实测存在 **18 个测试文件**
> （`test/` 13 + `example/test/` 5），其中 `example/test/render_smoke_test.dart` 会逐页渲染全部示例页
> 并捕获 RenderFlex 溢出。**但本环境无法执行 `flutter test`**——子进程不继承会话内修改的 PATH
> （实测子进程 `PATH_HAS_GIT=false`），flutter 启动即报 `Failed to find "git"`，`dart test` 又缺 `package:test`。
> 因此本轮全部改动仅经 `dart analyze` 校验（11 条与基线一致、零新增），**未经测试运行验证**。

### 批次一：缺陷修复 —— 进行中

| 项 | 内容 | 状态 |
|---|---|---|
| F 类 | 4 项独立缺陷 | ✅ 全部修复 |
| C 类 | 3 处 `didUpdateWidget` | ✅ 全部修复 |
| A 类 | 18 处死参数 | ✅ **全部处理完毕**（实现 15 处 + `@Deprecated` 3 处）；后续补示例页时又发现 #20 / #21 两处，已一并修复 |

**F 类**：
- F1 `wot_toast.loading` —— `_show` 的 `duration` 改为可空，`loading` 传 `null` 实现常驻（原 2000ms 后自动消失）
- F2 `wot_image_preview` —— 页码 `'$_current+1/$length'` 补 `showIndex` 判断（原先只判断 `urls.length > 1`）
- F3 `wot_tabbar` —— clone item 时补传 `onClick: item.onClick`
- F4 `wot_img` —— `onLoad` / `onError` 原由 `loadingBuilder` / `errorBuilder` 在 build 阶段同步触发，调用方在回调里 `setState` 即崩溃；现统一延后到本帧构建结束后发出

**C 类**：
- `wot_picker` —— 新增 `didUpdateWidget`，`values`/`columns` 变化时重新 `_clamp`（含 `_sameValues` 辅助比较）
- `wot_swipe_action` —— 新增 `initState`（由 `show` 初始化）+ `didUpdateWidget`（外部改 `show` 同步展开态，不回调 `onChange` 避免回环）；`_set` 统一回调 `onChange`，并移除操作按钮里重复的一次调用
- `wot_count_down` —— `didUpdateWidget` 同时处理 `value` 与 `autoStart` 变化，重置后按 `autoStart` 重启或停止定时器

**A 类已处理**：
- #8 `wot_overlay.zIndex`、#9 `wot_watermark.zIndex` —— `@Deprecated`（Flutter 无 z-index 语义）
- #11 `wot_count_to.speed` —— 实现：`duration = |modelValue| / speed`
- #12 `wot_input_number.longPress` —— 实现：长按以 120ms 周期连续步进，到 min/max 自动停止
- #4 `wot_input.type` —— 实现：`_keyboardTypeOf` 映射 number/digit/tel/email/url（`number`/`password` 优先级更高）
- #5 `wot_icon.classPrefix` —— 参数已移除（2026-09-17，`WotButton.classPrefix` 一并删除）；#6 名称解析改为 `normalizeName`（`_`/空格→`-` 再转小写）
- #7 `wot_dialog.type` —— 实现：左侧 4px 辅助色条，`clipBehavior: antiAlias` 保证不顶出圆角
- #13 `wot_slide_verify.errorText` —— 实现：失败态展示 1.2s 后自动复原，重新拖动立即清除
- #14 `wot_action_sheet.WotActionSheetItem.icon` —— 实现：图标 + 文字横向排列
- #15 `wot_steps.WotStepData.status` —— 实现；**兼容性设计**：`waiting` 视为「未指定」仍按索引推导，
  `finished`/`process`/`error` 才覆盖，保证既有用法的表现不变
- #16 `wot_skeleton.WotSkeletonItem.animate` —— 实现：`WotSkeletonItem` 改为 StatefulWidget，自带闪烁控制器
- #17 `wot_picker_view.WotColumnOption.disabled` —— 实现：置灰 + 滚动吸附到最近可用项
- #18 `wot_grid.reverse` —— 实现：先整体倒序再按列切分
- #3 `wot_tabbar.fixed` —— `@Deprecated`（Flutter 布局由父级决定，组件无法浮出父容器；指引改用 `Scaffold.bottomNavigationBar`）
- #10 `wot_popover.showArrow` —— 实现：`_BubblePainter` 单一路径绘制气泡+箭头（连续边框+阴影，无接缝），箭头方位由生效 `placement`（含翻转）推导。
  **已知限制**：空间不足触发 `_PopoverPosDelegate` 自动翻转时，箭头方向不会跟着翻转
- #1 `wot_popup` 动画 —— 实现：`AnimationController` + `Tween` + `easeOutCubic`，
  进场 `forward` / 退场 `reverse`；初始即可见时停在终态，避免首帧播放一次入场动画
- #2 `wot_swiper.loop` —— 实现：大数取模法（`initialPage = 10000`、`itemCount: null`、取模复用子项）；
  内部保留 `_raw`（真实页索引）与 `_realIndex`（对外逻辑索引）两层，`onChange` 与指示点均用后者

---

## 九·补：批次二 2a —— `upload` 真实上传（已完成）

**原状态**：`_simulateUpload` 延时 600ms 直接置 success；`accept` 硬编码 `FileType.any`；无进度、无失败态。

**现在的上传链路**（优先级从高到低）：

1. `uploadMethod`（`WotUploadMethod`）——调用方提供，全平台可用，**推荐**
2. `action` ——内置 multipart 上传，仅 native（`dart:io`）
3. 二者都没配 → fail 状态 + 明确错误文案

**关键设计：用条件导入避免强加网络依赖**

```dart
import 'wot_upload_unsupported.dart'
    if (dart.library.io) 'wot_upload_native.dart';
```

- `wot_upload_native.dart`：`dart:io` `HttpClient` 手工拼 multipart，64KB 分块 + `req.flush()`
  以产生**真实**的字节级进度（否则一次性写完，进度不可观测）
- `wot_upload_unsupported.dart`：web 占位，返回明确错误引导使用 `uploadMethod`

> **为什么不加 `http` 依赖**：UI 组件库不应强制绑定网络库；web 端 `dart:io` 不可用，
> 硬引入 `http` 会给所有使用方增加依赖。可插拔设计让调用方自由选择 `http` / `dio` / 自研通道。

**其他补齐**：
- `accept` 生效：解析为 `FileType.image/video/audio/media/custom` + `allowedExtensions`
- 进度：`WotUploadFile.percent`（0-100），UI 在加载遮罩上显示百分比
- 失败态：`WotUploadStatus.fail` + 遮罩上的重试图标，点击重新上传
- 新增 `WotUploadResponse`（statusCode / body / url / error，`isSuccess` 判定）与 `onFail` 回调
- 注意：wot 的 `name` 在本组件已被「表单字段名」占用，multipart 文件字段名另取名 `fileFieldName`（默认 `file`）

**示例页**已补三个 demo：`uploadMethod` 真实进度、失败态重试（可切换成功/失败）、`accept` 类型限制。

---

## 九·补二：批次二 2a —— `form` 校验体系重构（已完成）

**原状态**：`_values` 是 `Map<String, String>`，`WotFormRule` 是 `bool Function(String?)`。
后果是 switch（bool）、rate / slider（num）的 `name` 全部失效，且规则无法带自定义消息。

### 兼容性设计（这是本次的关键约束）

规则签名从 `bool Function(String?)` 改为：

```dart
typedef WotFormRule = Object? Function(dynamic value);
```

- **入参必须是 `dynamic` 而不是 `Object?`**：既有写法 `(v) => v != null && v.isNotEmpty`
  在 `Object?` 下编译不过（没有 `isNotEmpty`），`dynamic` 才能让老代码零改动继续编译
- **返回值三态**：`null`/`true` 通过；`false` 用默认文案；非空字符串即自定义错误提示
- `valueOf` 返回类型 `String?` → `Object?`，因此调用方需自行判类型
  （示例页 `wot_form_page.dart` 已相应改为 `v is String && v.isNotEmpty`）

### 新增能力

| API | 说明 |
|---|---|
| `WotForm.model` | 初始表单数据（wot `model` 语义）；`setModel` 只补缺失键，不覆盖用户输入 |
| `WotFormRule` 返回字符串 | 自定义错误消息 |
| `WotForm.validateTrigger` | `Set<WotFormTrigger>`：`change` / `blur` / `submit`（默认 `{submit}`） |
| `WotFormState.validate([prop])` | 传 `prop` 只校验单个字段 |
| `WotFormControl.validateFields([prop])` | 返回完整「字段 → 错误」表 |
| `WotFormState.reset()` | 回到初始 model 并清空错误 |
| `WotForm.errorType` | `message`（内联）/ `toast`（额外 toast）/ `none`（不展示） |
| `WotForm.onError` | 校验失败回调，与 `errorType` 独立 |
| `WotFormItem.clickable` / `isLink` / `onTap` | 整行可点击 + 右侧箭头 |
| `wotFormPushValue(context, name, value)` | 供录入控件登记值的全局函数 |

### 跨控件取值打通

新增 `WotFormScope.read(context)`（用 `getElementForInheritedWidgetOfExactType`，**不建立依赖**），
配合 `wotFormPushValue` 把 `switch` / `rate` / `slider` / `input_number` 的 `name` 全部接上。

> **坑**：`rate` 的点击回调在子组件 `_StarTapArea` 里，那里既没有 `widget` 也没有 `name`。
> 正确做法是在父级 `WotRate.build` 把 `onChange` 包一层再传给子组件。

### 仍未覆盖

~~`checkbox` / `radio` 的 `name` 尚未登记（本次未动）~~ → **已于 2026-09-20 补齐**：
`WotCheckbox` / `WotCheckboxGroup` / `WotRadio` / `WotRadioGroup` 现均按 `name` 登记到表单
（独立模式登记自身值，组模式登记整组值；原先这 **4 个 `name` 是死参数**，表单 `values` / 规则完全取不到）。
`blur` 触发需要录入控件在失焦时
显式调用 `WotFormControl.validateField(name)`，`WotInput` 目前未接。

### 修复：进入页面即显示必填错误

用户反馈「进入 form 页面时校验就显示了」。根因：`WotFormItem` 的必填兜底逻辑
只看「required 且值为空」，**不区分「尚未校验」与「校验不通过」**，于是首帧就满屏红字。

修法：`WotFormControl` 增加 `_validated` 集合 + `wasValidated(name)`，
`validateField` / `validateFields` 时打标记，`FormItem` 只有在该字段已校验过时才展示必填错误。

> **配套坑**：`clearValidate()` 与 `reset()` 必须一并清空 `_validated`，
> 否则清空错误后「已校验 + 值为空」会立刻把必填错误重新显示出来，等于没清。

每步均跑 `dart analyze`，11 条提示与基线完全一致、零新增。

> **通用教训**：表单的「必填/格式校验提示」一律要绑定「是否已触发校验」这个状态，
> 不能只看当前值。这是表单组件最常见的体验 bug，值得当成 checklist 项。

---

## 九·补三：批次二 2a —— `input` 基础输入能力（已完成 2026-09-17）

2a 的最后一项。此前 `WotInput` 有 52 个参数，外部却完全拿不到
`TextEditingController` / `FocusNode`——**表单入口组件不可编程控制**，
典型后果是「校验失败无法自动定位到出错字段」。

### 新增参数（`WotInput` 与 `WotTextarea` 均已暴露）

| 参数 | 说明 |
|---|---|
| `controller` | 外部 `TextEditingController`，由调用方持有与销毁 |
| `focusNode` | 外部 `FocusNode`，由调用方销毁 |
| `inputFormatters` | `List<TextInputFormatter>?` |
| `autofocus` | 默认 `false` |
| `onSubmitted` | 键盘完成键回调 |
| `textInputAction` | 键盘动作按钮类型，与 `onSubmitted` 配合 |

未做：`textAlign`（现硬编码 `TextAlign.left`）、`error`（错误态，与 form 校验体系耦合，单独立项）。

### 两个必须记住的语义

1. **谁创建谁销毁**。State 内用 `_ownsController` / `_ownsFocusNode` 两个标记区分，
   外部传入的对象只 `removeListener`、绝不 `dispose`。
2. **传入 `controller` 后 `value` 只作初始值**。`didUpdateWidget` 里遇到外部 controller
   直接 return——否则「外部改 `controller.text`」会被旧 `value` 覆盖回去，表现为输入被回弹。
   controller 即唯一数据源，这是 Flutter 的惯例。

### 顺带修掉的一个隐性 bug

`clearable` 的清除图标与 `showWordLimit` 的字数统计都读 `controller.text`，
而原先只在 `TextField.onChanged` 里 `setState`——**外部程序化改 text 时二者会停在旧值**。
现在对 controller 挂监听，与键盘输入路径解耦。

### 环境坑

`TextInputFormatter` / `FilteringTextInputFormatter` 定义在 `package:flutter/services.dart`，
**`material.dart` 不导出它**，必须显式 import，否则报 `non_type_as_type_argument`。

示例页已补：写入/追加/清空/读取四个按钮、focus 请求与取消、三种 formatter
（digitsOnly / allow(RegExp) / withFunction 转大写）、autofocus 按需挂载、onSubmitted 日志。
`dart analyze` 仍 11 条基线、零新增。

---

## 十、批次二 2b（进行中）

### `WotNavbar` —— 实现 `PreferredSizeWidget`

现在可直接用于 `Scaffold.appBar` / `NestedScrollView`。新增三个参数：

| 参数 | 默认 | 说明 |
|---|---|---|
| `height` | `44` | 内容区高度（原先硬编码 44） |
| `topPadding` | `0` | 计入 `preferredSize` 的顶部额外高度（通常填状态栏高） |
| `safeArea` | `true` | **作为 appBar 时必须置 false**，否则与 Scaffold 的避让重复，顶部多出空白 |

`preferredSize = Size.fromHeight(height + topPadding)`。

### `WotImagePreview` —— 关闭按钮

新增 `closeable`（默认 true）与 `closeIconPosition`
（`topLeft` / `topRight` / `bottomLeft` / `bottomRight`，默认 `topLeft`），
自动避让状态栏与安全区。此前只能点遮罩退出。

### `WotPickerView` —— 底座参数（部分）

- `visibleItemCount`（默认 5）：`WotPickerColumn` 与 `WotPickerViewColumn` 均支持；
  未显式传 `height` 时以 `itemExtent * visibleItemCount` 推断，不再固定 200
- `itemExtent` 现可透传（原先 `WotPickerViewColumn` 内部写死 40）
- 键名映射：`WotPickerViewOptions.listFrom(data, valueKey:…, labelKey:…, childrenKey:…)`，
  可直接把 `{id, name, subList}` 这类后端结构转成列数据
- `WotColumnOption` 新增 `children`，为级联数据提供载体

**未实现**：`cascade`（多列联动）需要父列变化时重建子列，属组件级改造，尚未做；
`itemHeight` 默认值保持 40 未改为 44（改默认值属破坏性变更，需单独评估）。

### `WotFloatingPanel` —— anchors 数组 + 受控高度 + 吸附回弹（已完成 2026-09-17）

原先用 `anchor`/`min`/`max` 三个比例参数近似停靠，表达不了真实的多档位。
现改为：

| 参数 | 默认 | 说明 |
|---|---|---|
| `anchors` | `[fraction(0.1), fraction(0.5), fraction(0.95)]` | 吸附点列表（建议升序）。`pixels(n)` 表固定像素，`fraction(n)` 表占可用高度比例；可混排如 `[pixels(100), fraction(0.4), fraction(0.7)]` |
| `initialAnchor` | 取 `anchors` 中间项 | 初始停靠点；不传则落中间档 |
| `minHeight` | `56` | 硬下限，最终高度与拖拽下限都钳制到不小于它 |
| `height` | `null` | 受控高度（像素）。非空时由父组件决定，拖拽仍通过 `onHeightChange` 回传，双向同步 |
| `onHeightChange` | `null` | 高度变化回调（拖拽过程与吸附动画中均触发） |

拖拽松手后计算**最近吸附点**并用 `AnimationController`（260ms）回弹；拖拽开始 / 更新时
`_anim.stop()` 以避免动画与手势抢 `_height`。`SingleTickerProviderStateMixin` 仅需一个 ticker、
在 `initState` 建一次，安全。`_availH` 在 `LayoutBuilder` 内首帧确定后再算初始像素高度。

**破坏性变更**：`anchor`/`min`/`max` 三个参数已删除，调用方需改用 `anchors`；仅有示例页引用，已同步重写。

### `WotSignature` —— 图片导出闭环 + 历史撤销/恢复（已完成 2026-09-17）

原组件只自绘笔画、无任何产出物，签名结果拿不到。现补齐：

| 参数 | 默认 | 说明 |
|---|---|---|
| `onConfirm` | `null` | 确认导出回调，参数为 `WotSignatureResult { success, bytes }` |
| `fileType` | `png` | `WotSignatureFileType.png` / `jpg` |
| `quality` | `1` | JPG 质量（0~1），仅 JPG 生效 |
| `exportScale` | `1` | 导出像素倍数（2 表示 2 倍清晰度） |
| `enableHistory` | `false` | 开启后底部出现「撤销 / 恢复」 |
| `step` | `1` | 撤销 / 恢复步长（一次几笔） |

公开方法：`confirm()`（异步导出，返回 `WotSignatureResult` 并触发 `onConfirm`）、
`revoke()` / `restore()` / `clear()`。底部内置操作栏：清空 / 撤销 / 恢复 / 确认。

**实现要点**：画板用 `RepaintBoundary`（`GlobalKey`）包裹，仅绘制区入库，清空图标与按钮在边界外；
`confirm()` 经 `boundary.toImage(pixelRatio: exportScale)` → `toByteData(format)` 得 `Uint8List`。
历史用 `_redoStack`：落笔提交后清空重做栈，撤销把笔画移入、恢复移回。

**环境坑（重要）**：本机 Flutter 引擎的 `ImageByteFormat` **只有 `png`、没有 `jpeg`**
（`ImageByteFormat.jpeg` 构造需 Flutter ≥ 3.22）。直接写会编译报 `undefined_method`。
现用 `ImageByteFormat.values.firstWhere((e) => e.name == 'jpeg')` 运行时探测：支持则用 JPG、
不支持回退 PNG，`quality` 随之失效。`fileType`/`quality` 参数保留以对齐 Vue API、便于升级后启用。

### `WotTabs` —— TabController 注入 + onPageChanged + 指示器全套（已完成 2026-09-17）

原组件完全自管选中态，不认识 Flutter 的 `TabController`/`DefaultTabController` 生态，外部无法驱动。

新增：

| 参数 | 默认 | 说明 |
|---|---|---|
| `controller` | `null` | Flutter 标准 `TabController`（可选）。注入后选中态以它为准，`modelValue` 失效；`controller.length` 必须等于子项数 |
| `onPageChanged` | `null` | 滑动切换页码时触发（来自 swipeable 的 PageView），参数为新索引 |
| `indicatorWeight` | `3` | 指示器厚度（像素），原硬编码 3 |
| `indicatorPadding` | `zero` | 指示器四向内边距 |
| `indicatorSize` | `tab` | `WotTabsIndicatorSize.tab`（满项宽）/ `label`（贴合标题文字宽，用 `TextPainter` 测宽） |
| `lineWidth` / `lineColor` | - | 原已有；`lineWidth` 非空时忽略 `indicatorSize` 直接定宽 |

**绑定要点**：注入 `controller` 后 `_select`/`_onPageChanged` 改走 `controller.animateTo(i)`，
`_onControllerChanged` 监听把外部变化同步回 `_current`（不在此回发 `onChange` 避免重复）；
`swipeable` 模式仍用内置 `_pageController`，与 controller 双向同步（靠 `_current==idx` 提前返回防回环）。
`initState`/`didUpdateWidget`/`dispose` 三处统一订阅/退订/重建 controller。不传 controller 时 100% 维持旧行为。

**未做**：`sticky` 吸顶——`WotTabs` 非 sliver 结构，单加参数做不出真吸顶（需拆 `WotTabsBar`+`WotTabBarView` 配合 `CustomScrollView`），本批搁置。

**批次二 2b 全部完成**（floating_panel / signature / tabs）。后续可进入批次三或收尾评审。

---

## 十一、三态语义规范（2026-09-20 试点落地）

> 目的：统一 disabled / readonly / error 三态的视觉语义，消除「以 disabled 代 readonly」的长期歧义。
> 代码位置：`lib/src/theme/wot_state.dart`（规范的**单一真相源**）。
> 试点范围：`input` / `textarea` / `cell` / `form_item`；后续按同一规范推广到全库。

### 11.1 三态定义

| 态 | 业务语义 | 典型场景 |
|---|---|---|
| `editable`（默认） | 可编辑 | 正常录入 |
| `readonly` | 有值、**内容有效可读**、不可改 | 展示已确定的值、详情页回填 |
| `disabled` | 整体**失效**、不可交互 | 无权限、流程已归档、条件未满足 |
| `error`（叠加维度） | 校验失败 | 必填未填、格式错误 |

**最关键的一条**：`readonly` 保持正常字色，只有 `disabled` 才灰化。
只读内容本身是有效的、用户需要正常阅读；禁用内容是失效的、才应灰掉。
这正是「以 disabled 代 readonly」长期混用的根因所在。

### 11.2 视觉规范（映射到语义令牌）

| 态 | 底色 | 文字 | 边框 / 下划线 | 标签 |
|---|---|---|---|---|
| editable | 常规（组件自身底色） | `textMain` | `baseBorder`（组件常规边框） | `textMain` |
| readonly | 常规 | **`textMain`（不灰化）** | **`borderZero`（无边框）** | `textMain` |
| disabled | **`filledContent`（浅灰）** | **`textDisabled`（灰）** | `baseBorder`（**保留结构**） | `textDisabled` |
| + error | 不变 | 不变 | **`dangerMain`（红）** | **`dangerMain`（红）** |

优先级：**disabled > error > readonly > editable**
（禁用字段通常不参与校验，故 disabled 不吃 error 视觉。）

### 11.3 组件落地要点

| 组件 | 形态 | 三态实现 |
|---|---|---|
| `WotInput` | 下划线式 | readonly → 去掉下划线；disabled → 浅灰底（`filled`）+ 灰字 + 保留下划线；error → 下划线转红 |
| `WotTextarea` | 框式（圆角底色） | readonly → 白底无边框；disabled → 浅灰底 + 灰字；error → 描红边 |
| `WotCell` | 展示行 | disabled → 标题/值/图标/箭头整体灰化且不可点；error → 标题与值转危险色 |
| `WotFormItem` | 表单容器 | 标签随三态变色（error 红 / disabled 灰）；经 `WotFieldScope` **下发** disabled / readonly / error 给内部控件 |
| `WotForm` | 表单容器 | 表单级 `disabled`，经 `WotFieldScope` 下发整表；提交按钮同步禁用 |
| `WotCheckbox` / `WotRadio` | 勾选类 | disabled → 勾选块 / 边框 / 标签一并灰化；error → 未选中描边与标签转红；readonly → 仅锁交互 |
| `WotSwitch` / `WotSlider` / `WotRate` | 开关 / 滑块 / 评分 | disabled → 关键色（轨道 / 激活段 / 已选图标）转灰；readonly → 仅锁交互、配色不变 |
| `WotInputNumber` | 数字步进 | disabled → 文字灰 + 浅灰底；error → 输入框描红边 |
| `WotSelectPicker` / `WotCascader` | 触发区（框类）+ 弹层 | 触发区套框类三态（readonly 去边框 / disabled 浅灰底 / error 红边）；弹层内容不受影响 |
| `WotPicker` / `WotDatetimePicker` / `WotCalendar` | 纯弹层（无显示区） | 无触发区，三态应施加在**调用方的触发区**；组件内 readonly 锁交互（配色不变）、disabled 额外 `Opacity(0.5)` |
| `WotSearch` | 无边框浅灰底 | disabled → 浅灰底 + 灰字 + 图标灰；error → 补一圈红边；readonly → 仅锁编辑 |
| `WotPasswordInput` | 格状 PIN | disabled → 浅灰底 + 灰点 / 字 + 边框灰；error → 格子描红边；readonly → 仅锁输入 |
| `WotSignature` | 画板 + 操作栏 | readonly → 锁书写 / 清空 / 撤销（保留「确认」导出）；disabled → 额外淡化；error → 画板描红边 |
| `WotKeyboard` | 虚拟键盘面板 | readonly → 锁全部按键（配色不变）；disabled → 额外淡化。**无 error**（键盘无校验语义） |
| `WotUpload` | 文件列表 | readonly → 锁添加 / 删除（**预览仍可用**）；disabled → 额外淡化 |

> **非框类控件（勾选 / 开关 / 滑块 / 评分）**没有「输入框边框」，故 readonly 只锁交互、**配色不变**；
> disabled 通过关键色转灰表达（`filledExtraStrong` / `textDisabled`）。与框类的「去边框」策略不同，但语义一致。
>
> **纯弹层组件**（picker / datetime_picker / calendar）没有可编辑的「显示区」——
> 其 readonly / disabled 只作用于**弹层内部交互**；真正的三态应施加在调用方提供的触发区上。

### 11.4 下发机制与优先级

`WotFormItem` 通过 `WotFieldScope`（InheritedWidget）包裹子控件，内部录入控件读取时遵循：

**显式传参 > `WotFieldScope` 下发 > 默认可编辑**

例：`WotFormItem(disabled: true, child: WotInput())` → 输入框自动禁用；
写成 `WotInput(disabled: false)` 则显式值胜出。

### 11.5 推广待办

- [x] `flutter analyze` **用户复验通过**（2026-09-20）；`dart analyze` 自检 `lib` + `test` + `example` 全部 `No issues found`
- [x] 示例页补三态演示（`input` / `cell` / `form_item`），见 `DEMO_GUIDE.md` checklist
- [x] **推广第 1 批**（2026-09-20）：`WotForm` 表单级 `disabled` + `checkbox` / `radio` / `switch` / `slider` / `rate` / `input_number`
- [x] **推广第 2 批**（2026-09-20）：`select_picker` / `cascader`（触发区三态）+ `picker` / `datetime_picker` / `calendar`（弹层 readonly / disabled）
- [x] **推广第 3 批**（2026-09-20）：`upload` / `search` / `password_input` / `keyboard` / `signature`
- [ ] 推广到展示类（可选）：`tag` / `badge` / `steps` / `collapse` / `grid` / `table`

---

## 附录 G：静态检查待办（flutter analyze）

> 来源：原 `ANALYZE_REPORT.md`（已并入本附录）。执行方式：在**组件库根目录**执行 `flutter analyze`，
> 覆盖范围 `lib/` + `example/` + `test/`。基线共 **11 条**（0 error / 3 warning / 8 info）。
> 注意：在 `example/` 子目录执行只会分析 example 工程（实测仅 1 条 info），**不能替代**根目录执行。
>
> **状态（2026-09-20）：11 条已由用户处理完毕，并经 `flutter analyze` 复验**归零**；本附录归档（保留供追溯）。**

### Warning（3 条，需人工判断）

| # | 文件:行 | 规则 | 问题 | 处理建议 |
|---|---|---|---|---|
| 1 | `lib/src/components/button/wot_button.dart:278:10` | `unused_element_parameter` | 可选参数 `dashLength` 从未被传值 | 预留则加 `// ignore:`，否则删除 |
| 2 | `lib/src/components/button/wot_button.dart:279:10` | `unused_element_parameter` | 可选参数 `gapLength` 从未被传值 | 同上 |
| 3 | `lib/src/components/loading/wot_loading.dart:184:15` | `unused_local_variable` | 局部变量 `rect` 赋值后未使用 | 调试残留则删，否则补上使用逻辑 |

### Info（8 条，可 `dart fix --apply` 批量处理）

| # | 文件:行 | 规则 | 问题 |
|---|---|---|---|
| 1 | `example/lib/pages/nav/wot_pagination_page.dart:24:7` | `prefer_final_fields` | `_pageSize7` 可声明为 `final` |
| 2 | `lib/src/components/badge/wot_badge.dart:106:32` | `use_null_aware_elements` | 判空可改空感知写法 |
| 3 | `lib/src/components/calendar/wot_calendar.dart:104:34` | `unintended_html_in_doc_comment` | 注释中尖括号被当 HTML，需加反引号 |
| 4 | `lib/src/components/calendar/wot_calendar.dart:858:33` | `unnecessary_underscores` | 多余下划线命名 |
| 5 | `lib/src/components/calendar/wot_calendar.dart:930:7` | `use_null_aware_elements` | 判空可改空感知写法 |
| 6 | `lib/src/components/calendar/wot_calendar.dart:931:7` | `use_null_aware_elements` | 同上 |
| 7 | `lib/src/components/calendar/wot_calendar.dart:932:7` | `use_null_aware_elements` | 同上 |
| 8 | `test/calendar_features_test.dart:38:28` | `unnecessary_underscores` | 多余下划线命名 |

### 处理顺序

1. `dart fix --apply` 清空 8 条 info（`unintended_html_in_doc_comment` 需手动加反引号）
2. 人工判定 3 条 warning：`wot_button` 两个预留参数是保留还是删除、`wot_loading` 的 `rect` 是否调试残留
3. 重新执行 `flutter analyze` 确认清零；改动后**基线应保持 11 条零新增**

> 纪律：本附录是 lint 待办的**唯一归处**。修完一条划掉一条，不要再新建 analyze 快照文档。

---

## 附录 H：长任务执行计划

> 本附录是执行级手册，回答「按什么顺序做、做到什么算完、下一会话怎么接上」。
> 现状评估见 `CAPABILITY_MATRIX.md`，示例页规范见 `DEMO_GUIDE.md`。

### H1 阶段划分与依赖

| 阶段 | 目标 | 依赖 | 说明 |
|---|---|---|---|
| Stage 0 | 打通验证链路 | 无 | **由用户在自己终端执行** flutter 命令（见 H2），agent 负责改代码与分析结果 |
| Stage 1 | 无障碍基线 | Stage 0 | 可与 Stage 2 并行 |
| Stage 2 | 国际化管道 | Stage 0 | 可与 Stage 1 并行 |
| Stage 3 | 组件 API 与状态语义 | Stage 0 | 内部可分小批 |
| Stage 4 | 质量保障（Golden / CI / 发布） | Stage 0 | 建议提前启动 |
| Stage 5 | 生态适配与收尾 | Stage 3 | 持续优化，可随时收尾 |

**阶段门**：每阶段结束须同时满足——① 验收标准逐条判定通过；② 示例页已同步；③ 破坏性变更已入 CHANGELOG。缺一不得进入下一阶段。

### H2 验证命令（用户执行）

```
cd /d F:\3project\project_template\flutter_template_dev\flutter_ui\flutter_wot_ui
flutter analyze          :: 覆盖 lib/ + example/ + test/（基线：11 条已处理，复验应归零）
flutter test             :: 根目录 test/
cd example
flutter analyze          :: 仅 example 工程
flutter test             :: example 的 widget 测试
```
需要回收的结果：`analyze` 的问题清单、两条 `test` 的通过/失败数（后者是质量保障基线，尚无记录）。

### H3 全局纪律（所有任务默认继承）

| 编号 | 纪律 |
|---|---|
| G1 | `flutter analyze` 保持零新增；lint 待办集中在附录 G |
| G2 | 示例页同步走 `DEMO_GUIDE.md` 第三节 checklist，逐条打勾 |
| G3 | **Grep 扫旧值回归**：改完搜索「应当消失的旧值」确认无残留（曾出现 4 处报「已改」却未落盘，靠此项兜住） |
| G4 | 改默认值 / 删参数 → 写 `CHANGELOG.md` + 升版本号；不可用参数用 `@Deprecated` 并给替代方案 |
| G5 | 单批次改动组件文件 **≤ 8 个**，超出即拆，保证可回退 |
| G6 | 区分「已验证 / 未验证」，**禁止把打算做写成已完成**；测试未跑通的项标 `未验证(测试不可执行)` |
| G7 | 每张卡完成即更新：进度追踪表 → CHANGELOG → 工作日志 |

### H4 进度追踪表

标记：`[ ]` 未开始　`[~]` 进行中　`[x]` 完成（附日期）　`[!]` 阻塞

**Stage 1 无障碍**
- [ ] T1.1 建 `test/a11y_baseline_test.dart` 输出语义节点基线表（必须有数字）
- [x] T1.2 交互类第一批 —— ✅ 已完成（2026-09-20）：`checkbox` / `radio` / `switch` / `slider` 四个
  **自绘裸 GestureDetector** 组件补齐 Semantics（`checked` / `slider` / `value` / `increasedValue` /
  `decreasedValue` / `onIncrease` / `onDecrease` / `enabled` / `onTap`；radio 组内加 `inMutuallyExclusiveGroup`），
  slider 的语义增减复用内部拖动路径（与拖动一致走 step 对齐 + onChange）。
  `button` 用 InkWell、`input` 用 TextField，Flutter 已内建语义（审计确认无需包装）。
  遗留：`input` 的「必填 / 错误」语义未关联。
- [x] T1.3 交互类第二批 —— ✅ 已完成（2026-09-20）：
  `tabs`（逐项 button + selected）、`sidebar`（逐项 button + selected + enabled + label）、
  `segmented`（整段 value「当前选中：X」，逐项标志待细化）、`rate`（slider 角色 + 「N / M 星」）、
  `icon`（可点时 button + 图标名；装饰性不进语义树无噪声）、`input_number`（加减按钮 button + 「增加/减少」）；
  ✔ 无需改：`cell` / `pagination` 用 InkWell（内建 button 语义，审计确认）
- [x] T1.4 展示类降噪 —— ✅ 审计结论：**无需改动**（2026-09-20）：
  `divider` / `gap` / `skeleton` 无文本无交互（本就不产生语义节点）、`watermark` 用 CustomPaint（不进语义树）、
  `loading` / `divider` 的文本（「加载中…」/ 分割线文案）是有用信息，不应排除。
  原计划按「统一 ExcludeSemantics」处理，实测审计后确认全部不需要。

**Stage 2 国际化**
- [x] T2.1 定义 `WotMessages` + `tr()`，接通 `localeMessages` 管道 —— ✅ 已完成（2026-09-20）：
  新增 `lib/src/locale/wot_messages.dart` 并导出。取值优先级：**自定义语言包 > 内置表（按 locale）>
  默认语言表 > fallback > key 本身**；locale 归一化兼容 `zh-CN` / `zh_CN` 写法；
  无 Provider 包裹时安全回退默认语言（组件内可直接调用，无需判空）。
  **未动任何组件**（硬编码文案替换在 T2.2 / T2.3）。
  内置 key：common 系列（confirm / cancel / done / clear / add / revoke / restore / loading /
  increase / decrease / search）+ calendar.title + keyboard.title（zh_CN + en_US）
- [x] T2.2 首批替换 —— ✅ 已完成（2026-09-20）：
  ✅ `calendar`（title / confirmText / cancelText **字段可空化** + 弹层取消 / 确定 / 标题接入 tr）、
  `table`（emptyText 可空化 + 空态文案）、`img_cropper`（取消 / 完成）、
  `video_preview`（标题 / 全屏 / 关闭 / 加载失败 / 重试 / 快进快退，共 6 处含 1 处 semanticLabel）；
  内置表累计补 **15 个 key**。✔ 无需改：`input` —— 审计确认无用户可见文案（命中的中文全是注释）。
  ⏳ 遗留：带参数文案（rangePrompt「不能超过 N 天」）需 tr() 支持占位符；
  calendar 年月选择器标题（`title: title ?? '选择日期'`）未走 tr。
  注：字段可空化是 **API 放宽**（`String -> String?`），原传法全部兼容，非破坏性变更。
- [x] T2.3 第二批 —— ✅ 已完成（2026-09-20）：
  ✅ `select_picker`（弹层取消 / 确定 / 搜索 placeholder，3 处接入 tr，均复用既有 key，零新增）；
  ✔ 无需改：`tabs` / `index_bar` —— 审计确认无用户可见文案（命中的中文全是注释 / doc 示例）；
  ⏳ 遗留：`tour`（show 的 4 个按钮文案参数默认值）、`upload`（addText 构造默认值）、
  `select_picker`（placeholder / emptyText 构造默认值）需**参数/字段可空化**（同 calendar 模式，API 放宽）；
  `form` 的「$label校验未通过」为带参数拼接，需 tr() 支持占位符。
- [ ] T2.4 提供 en_US 包并验证

**Stage 3 组件能力**
- [x] T3.1 disabled / readonly / error 三态语义规范 + 试点（input / cell / form_item）—— ✅ 已完成并**超额推广**：
  规范落于 `lib/src/theme/wot_state.dart`，覆盖 **16 个组件 + 19 个示例页**，详见第十一节（2026-09-20）
- [x] T3.2 checkbox / radio 接入 Form 值登记 —— ✅ 已完成（2026-09-20）：修掉 **4 个死参数**
  （`WotCheckbox.name` / `WotCheckboxGroup.name` / `WotRadio.name` / `WotRadioGroup.name`），示例页已补演示
- [ ] T3.3 外观参数枚举化（tabs.type / segmented.shape / select_picker.type）
- [ ] T3.4 D 类 P1 补齐（cell / switch / notify / badge / fab / count_down / img / qr_code）
- [ ] T3.5 builder 插槽体系化（cell / grid / picker / cascader / swiper）

**Stage 4 质量保障**
- [ ] T4.1 Golden 测试 —— **测试文件已就绪，待生成基线**（2026-09-20）：
  新增 `test/golden/golden_test.dart`（flutter_test 原生 `matchesGoldenFile`，零第三方依赖），
  覆盖 10 个组件：button / checkbox / radio / switch / slider / rate / input / input_number /
  search / cell，其中 checkbox / radio / switch / slider / rate / input 为**三态矩阵**
  （正常 / readonly / disabled / error），直接守护三态语义规范的视觉。
  稳定性措施：surface 固定 400x120、dpr 3.0、pump 300ms 到动画稳定态。
  **首轮实测（用户执行）**：7/10 基线已生成；3 个多行用例（slider / rate / input 三态矩阵）
  因 surface 400x120 高度不足溢出 —— 已修复（surface 统一提到 400x400，一处改动覆盖全部用例）。
  **附带修复真实缺陷**：`WotInput._ensureKeyboardVisible` 的 160ms Timer 未保存引用、dispose 不取消，
  组件销毁后仍存活 → 已保存引用并在 dispose 中 cancel（首次全量 `flutter test` 暴露的既有问题）。
  **待用户重跑**：`flutter test --update-goldens test/golden` 生成剩余 3 张基线并确认全绿。
- [ ] T4.2 接入 CI（analyze + test + golden）
- [ ] T4.3 发布准备（评估移除 `publish_to: none`、补 dartdoc 元信息）

**Stage 5 生态与收尾**
- [ ] T5.1 魔数主题化为 `WotXxxTheme`
- [ ] T5.2 Sliver / ScrollController / SafeArea 参数化 / Hero 转场 / Tabs 吸顶
- [ ] T5.3 缺口组件：sticky、resize、datetime_picker_view 增强、textarea 独立成目录

### H5 会话恢复协议

**开始（按顺序）**：① 读本附录进度追踪表确认当前卡 → ② 读 `CHANGELOG.md` 末尾 → ③ 读最近一次工作日志 → ④ 读该卡「涉及文件」原文，不凭记忆下手。

**结束（必须完成）**：① 更新进度追踪表与日期 → ② 破坏性变更写入 CHANGELOG → ③ 写工作日志（改了什么、遇到什么坑、下一步） → ④ 未完成的验证标 `未验证(原因)`，不得留空。

**人工确认点**：Stage 2 完成（全库文案改动，风险最高）、每次破坏性变更发布前、是否对外发布。

### H6 风险登记

| 编号 | 风险 | 缓解 |
|---|---|---|
| R1 | flutter 命令由用户执行，反馈有延迟 | 一次给全命令清单与所需输出格式，减少往返 |
| R2 | 破坏性变更影响业务侧 | 每批次结束更新 CHANGELOG；高危项在 README 列自查清单 |
| R3 | 文案替换引入语义漂移 | key 按 `组件.语义` 命名；替换时保留原字面量注释 |
| R4 | Golden 测试跨平台 flaky | 固定单一平台与 Flutter 版本生成基线并注明 |
| R5 | 跨会话上下文丢失 | 严格执行 H5 |
| R6 | 单批次改动过大 | G5 上限 8 个文件 |
| R7 | 状态虚报 | G6 + G3 |

### H7 工作量与置信度

| 阶段 | 预估 | 置信度 |
|---|---|---|
| Stage 1 | 2.5–3.5 天 | 中高（改动模式统一） |
| Stage 2 | 4–5 天 | 中（替换量大，calendar 单文件 135 处） |
| Stage 3 | 6–8 天 | 中低（依赖业务判断） |
| Stage 4 | 3 天 | 高 |
| Stage 5 | 7 天起，可裁剪 | 低（持续优化） |

上一轮实测显示原估「1–2 天」实际耗时 3–4 天，本表已上调；建议完成 2–3 张卡后按实际速度重新校准，而非一次估到底。