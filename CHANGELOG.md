# Changelog

本文件记录 `flutter_wot_ui` 的显著变更。版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。

---

## Unreleased — 2026-09-22

D 类 P1 缺失配置项批量补齐（T3.4，三批 13 个组件条目）+ a11y / i18n 验证基线。

### Added

- **WotSwitch 值域泛型化**：`WotSwitch<T>`（默认 bool 完全兼容）+ `activeValue` /
  `inactiveValue`（对接 `'1'/'0'` 后端协议）+ `beforeChange` 异步切换拦截。
- **WotBadge**：`WotBadgeType` 预设色 / `WotBadgeShape`（circle/square）/ `text`
  纯文本角标 / `showZero` / `offset` 偏移。
- **WotCell**：`placeholder` / `WotCellLayout.vertical` / `padding` /
  `WotArrowDirection` / 四个 TextStyle（与三态色按字段合并）。
- **WotNotify**：`position`(top/bottom) / `color` / `background` / `closable` /
  `safeHeight` / `onClick` / `onOpened` / `onClosed`（统一关闭回调）。
- **WotCountTo**：`startVal` 起始数值。
- **WotQrCode**：`WotQrCodeDotType` / `gapless` / `margin` / `logo`+`logoSize` /
  `onError`（新文案 key `wot.qrCode.loadFailed`）。
- **WotImg**：`imageProvider`（优先于 src）/ `cacheWidth`·`cacheHeight`（解码降采样）/
  `showLoading`·`showError` 开关。
- **WotFab**：`disabled`（主按钮与动作列表禁用 + 整体半透明）。
- **WotCountDown**：`millisecond` 毫秒级刷新（`SS` 实时）/ `SS`·`SSS` 格式修正 /
  `WotCountDownController`（start/pause/reset）。
- **WotSortButton**：`allowReset` / `descFirst`。
- **WotDialog**：`beforeConfirm` 确认拦截（confirm 返回 false）/
  `WotDialogActionLayout` / `WotDialogAction`+`actions` 自定义按钮组。
- **WotTag**：`WotTagVariant.dashed` 虚线边框（自绘 `_DashedRRectPainter`）。
- **WotCurtain**：`src` 图片幕布 / `WotCurtainClosePosition`（inside/outside）。
- **WotCellGroup**：`title`/`value` 标题区 + `WotCellGroupScope` 下发通道。
- 测试基线：`test/a11y_baseline_test.dart`（7 组件语义断言）、`test/i18n_en_test.dart`
  （en_US 五层验证）、`test/switch_value_test.dart`（值域 + beforeChange 四用例）。

### ⚠️ BREAKING CHANGES

- **WotCellGroup.bordered 默认值 false → true**（对齐 wot Vue 的 border 默认值；
  此前该参数未下发给 cell 属漂移）。行为变更：默认出现组外框；组内 cell 分割线
  现跟随组的 bordered。依赖旧默认隐藏外框的调用方需显式传 `bordered: false`。
- **WotSwitch 泛型化** `WotSwitch<T>`：现有 `WotSwitch(modelValue: true)` 用法
  自动推断 `T=bool`，无需迁移；测试中 `find.byType(WotSwitch)` 需改为
  `find.byType(WotSwitch<bool>)`（泛型组件 finder 必须写全类型参数）。
- **WotCountDown SS/SSS 格式修正**：`SSS` 现为三位毫秒（原实现为 1 位值×2）。

---

## Unreleased — 2026-09-20

三态语义规范（disabled / readonly / error）落地，试点 input / textarea / cell / form_item。

### Added

- **三态语义规范**（`lib/src/theme/wot_state.dart`，全新）：
  - `WotFieldState` 枚举：`editable` / `readonly` / `disabled`。
  - `wotFieldStyle(scheme, state, {error, baseBorder})`：三态 + 校验态的取色**单一真相源**
    （底色 / 文字 / 图标 / 边框 / 标签 / 占位符）。
  - `WotFieldScope`：`InheritedWidget`，把三态下发到子控件，实现「整项一处配置、内部跟随」。
  - 核心规则：**readonly 保持正常字色（内容有效可读）且无边框；disabled 才灰化**
    （浅灰底 + 灰字 + 保留边框）。这是「以 disabled 代 readonly」长期歧义的解药。
- `WotInput` / `WotTextarea` / `WotCell` / `WotFormItem` 新增 `error` 参数（校验失败态）。
- `WotCell` 新增 `disabled` 参数；`WotFormItem` 新增 `disabled` / `readonly` 参数。
- 三态相关 API 经 `package:flutter_wot_ui/flutter_wot_ui.dart` 统一导出。

### ⚠️ BREAKING CHANGES

- `WotInput.readonly: true` 现在渲染为**无下划线**（此前与可编辑态完全同形、无任何视觉区分）。
  依赖旧「只读仍显示下划线」观感的页面，需自行包裹边框或显式为其提供容器。
- `WotFormItem` 现在会**向下下发** `disabled` / `readonly` / `error`（经 `WotFieldScope`）：
  `WotFormItem(disabled: true, child: WotInput())` 的输入框会自动进入禁用态。
  子控件若显式传参则以显式值为准，故既有显式写法不受影响。
- `WotCell` 的 `value` 在 `error` 时转危险色、`title` 转标签三态色；两项新参数默认关闭，不影响既有调用。
- `WotSwitch` / `WotSlider` / `WotRate` 的 `disabled` 现在会**灰化控件**（原先仅禁交互、配色不变）。
- `WotPicker` 的 `disabled` 现在会**整体淡化弹层**（原先仅锁滚动、不改配色）。
- `WotSearch` 的 `disabled` 现在会**灰化底色与文字**（原先仅禁编辑、不改配色）。

### 验证

- ✅ `flutter analyze` 已由用户在组件库根目录复验通过（2026-09-20）。
- ✅ `dart analyze` 自检：改动的 4 个文件 + `lib` + `test` + `example` 全部 `No issues found`。

### 示例页

- ✅ 第 1 轮：`wot_input_page`（含 WotTextarea）、`wot_cell_page`、`wot_form_page`（含 `WotFieldScope` 下发对照）。
  `demoBlock` 数：`input` 18→22、`cell` 6→9、`form` 5→7。
- ✅ 第 2 轮：`wot_checkbox_page` / `wot_radio_page` / `wot_switch_page` / `wot_slider_page` / `wot_rate_page` /
  `wot_input_number_page` 补三态 section（含现场切换）。`demoBlock` 数：`checkbox` 6→9、`radio` 3→6、
  `slider` 7→9、`switch` 6→7、`rate` 7→8、`input_number` 10→11。
- ✅ 第 3 轮：`select_picker` / `cascader` / `picker` / `datetime_picker` / `calendar` / `search` /
  `password_input` / `signature` / `keyboard` / `upload` 十个页面补三态演示。`demoBlock` 数：
  `select_picker` 10→12、`cascader` 3→5、`picker` 3→4、`datetime_picker` 5→6、`calendar` 22→24、
  `search` 8→9、`password_input` 6→8、`signature` 7→9、`keyboard` 4→7、`upload` 8→9。
- ✅ **三态推广的示例页覆盖至此全部完成**（16 个推广组件 + 3 个试点组件）。

### 三态 API 补充（补示例时发现）

- `WotPicker.show` / `WotDatetimePicker.show` / `WotCalendar.show` 新增 `disabled` / `readonly` 参数 ——
  原先只有构造函数有、命令式入口未透传，导致**弹层三态无法从 `show` 使用**。
- `WotCalendar.show` 改为回落到 `WotCalendar` 本体：原先直接构造 `_CalendarSheet`，
  会**绕过** `WotCalendar.build` 里的三态包裹，使 disabled / readonly 失效。

### 测试（T4.1，2026-09-20）

- 新增 `test/golden/golden_test.dart`：10 个组件的 Golden 基线测试（flutter_test 原生
  `matchesGoldenFile`，零第三方依赖）。其中 checkbox / radio / switch / slider / rate / input
  为**三态矩阵**（正常 / readonly / disabled / error），直接守护三态语义规范的视觉。
- 生成基线（固定单一平台执行）：`flutter test --update-goldens test/golden`；
  日常验证：`flutter test test/golden`。

### 国际化（T2.1，2026-09-20）

- 新增 `WotMessages`（内置 zh_CN / en_US 文案表）与 `tr(context, key, {fallback})` 取值函数，
  接通 `WotConfigProvider` 既有的 `locale` / `localeMessages` 管道。
- 取值优先级：**自定义语言包 > 内置表（按 locale）> 默认语言表 > fallback > key 本身**；
  locale 归一化兼容 `zh-CN` / `zh_CN` 写法；无 Provider 包裹时安全回退默认语言。
- **本批未改任何组件**——组件内硬编码文案的替换在 T2.2（calendar / table / input /
  video_preview / img_cropper）与 T2.3 批次进行。
- T2.2 首批（同日，4 组件接入）：`WotCalendar`（title / confirmText / cancelText 字段可空化 +
  弹层取消 / 确定 / 标题）、`WotTable`（emptyText 可空化 + 空态文案）、`WotImgCropper`（取消 / 完成）、
  `WotVideoPreview`（标题 / 全屏 / 关闭 / 加载失败 / 重试 / 快进快退 semanticLabel）；
  内置表累计补 **15 个 key**。`input` 审计确认无用户可见文案。
  **注**：字段可空化是 API 放宽（`String -> String?`），原传法全部兼容，非破坏性变更。
  **遗留**：带参数文案（如「不能超过 N 天」）需 tr() 支持占位符。
- T2.3 第二批（同日）：`WotSelectPicker` 弹层取消 / 确定 / 搜索 placeholder 接入 tr（复用既有 key）；
  `tabs` / `index_bar` 审计确认无用户可见文案。**遗留**：tour / upload / select_picker 的
  参数或字段默认值需可空化（同 calendar 模式）；form 的「$label校验未通过」需 tr() 占位符。
- T2.5 全库闭环·批次 1（同日）：`WotSignature`（清空 / 撤销 / 恢复 / 确认 4 处接入 tr + 画板
  Semantics「手写签名区域」+ 清空图标 button 角色）、`WotKeyboard`（title / ensureText 字段
  可空化 + 接入 tr，key 复用既有）；新增 key `wot.signature.area`。
  批次 1 续（同日）：`WotPasswordInput` 补 a11y——自绘格子对读屏报「密码输入框 + 已输入 N/M 位」
  （新增 key `wot.passwordInput.field`；value 用纯数字避免语言问题，隐藏 TextField 本无可读语义）。
  `slide_verify` 审计：轨道文案是真实 Text（读屏可读），slider 角色为低优先级补项。
  待做：`tour` / `upload` / `select_picker` 参数可空化、纯展示类批量豁免归档。
- T2.5 全库闭环·批次 2（同日）：`WotUpload`（addText 字段可空化接入 tr，key 复用 `wot.common.add`）、
  `WotSortButton`（a11y：button 角色 + `value` 报告升序 / 降序 / 未排序——三角方向是自绘
  CustomPaint 此前读屏不可感知；新增 key `wot.sort.ascending` / `descending` / `unsorted`）。
  待做：`fab`（2 处 GestureDetector 需确认语义）、`tour` / `picker` / `datetime_picker` 可空化、
  纯展示类批量豁免归档。
- T2.5 全库闭环·批次 3（同日）：`WotPicker` / `WotDatetimePicker` 的 confirmText / cancelText
  字段可空化（String -> String?，API 放宽）并接入 tr，key 复用 `wot.common.confirm` / `cancel`。
  `WotTour` 遗留：4 个按钮文案经 show() -> _TourSheet -> step 三层透传（step 级可空、sheet 级非空），
  可空化链路复杂，单独一轮处理。
- T2.5 全库闭环·批次 5 起（同日）：`WotLoadmore` 四个文案字段（loadingText / loadingFailedText /
  noMoreText / finishedText）可空化接入 tr；新增 key `wot.loadmore.*` 四个（zh + en）。
  批次 5 剩余：`cascader` / `search` / `dialog` / `pagination`（弹层反馈类文案）。

### 无障碍（T1.2，2026-09-20）

- `WotCheckbox` / `WotRadio` / `WotSwitch` / `WotSlider` 四个自绘组件补齐 Semantics ——
  此前全部是裸 GestureDetector，**屏幕阅读器读不出「选中状态 / 当前值」**。
  - checkbox / radio / switch：`checked` 状态 + `onTap` 语义动作；radio 组内声明互斥组
  - slider：`slider` 角色 + 当前值 / 增减后值；`onIncrease` / `onDecrease` 复用内部拖动路径
    （与手动拖动一致走 step 对齐吸附和 onChange）
- `WotButton`（InkWell）与 `WotInput`（TextField）由 Flutter 内建语义覆盖，无需包装。
- 导航类（第二批）：`WotTabs` / `WotSidebarItem` 逐项补 `button` + `selected` 标志（sidebar 另含
  enabled 与标题 label）；`WotSegmented` 整段读出「当前选中：X」。`WotCell` / `WotPagination`
  用 InkWell，内建语义已覆盖。
- 交互第二批收尾：`WotRate`（`slider` 角色 + 「N / M 星」）、`WotIcon`（可点时 button + 图标名，
  装饰性图标不进语义树）、`WotInputNumber`（加减按钮 button + 「增加 / 减少」）。
- 展示类降噪审计结论：**无需改动** —— `divider` / `gap` / `skeleton` 无文本无交互、`watermark` 用
  CustomPaint（均不产生语义节点）；`loading` / `divider` 的文本是有用信息，不应排除。

### Fixed

- `WotInput`：Android 软键盘兜底重试的 160ms Timer 未保存引用、组件销毁时不取消——
  组件销毁后 Timer 仍存活（widget 测试报 "Timer is still pending"）。已保存引用并在 dispose 中取消。

### Fixed（T3.2）

- `checkbox` / `radio` 的 `name` 此前是**死参数**（声明但从未登记），导致表单 `validate()` / `values`
  取不到它们的值、规则也绑不上。现已登记：
  - `WotCheckbox`（独立模式）→ 登记自身 bool；`WotCheckboxGroup` → 登记整组 `List`
  - `WotRadio`（独立模式）→ 登记 `true`；`WotRadioGroup` → 登记选中项 `value`
- 示例页已补「复选 / 单选接入表单」演示（`wot_form_page`：提交后 `ctl.values` 取到整组值）。

### 三态推广（第 1 批，2026-09-20）

- `WotForm` 新增表单级 `disabled`：经 `WotFieldScope` 下发给全部 `WotFormItem` 及其内部控件，
  提交按钮同步禁用（对齐 Vue `wd-form`）。
- `WotSwitch` 新增 `readonly`；`disabled` 现在会灰化轨道（原先只禁交互、配色不变）。
- `WotCheckbox` 新增 `error`；`disabled` 现在连选中态一并灰化。
- `WotRadio` 新增 `readonly` + `error`；修复「组禁用时 label 不灰化」（原按 `widget.disabled` 判断，未含组合禁用）。
- `WotSlider` 新增 `readonly` + `error`；`disabled` 灰化激活段。
- `WotRate` 新增 `error`；`disabled` 灰化已选中图标。
- `WotInputNumber` 新增 `error`；`disabled` 现灰化文字并给浅灰底（此前文字色未处理）。

### 三态推广（第 2 批，2026-09-20）

本轮为**选择器类**。经调研分为两形态：两个带「触发区」（框类），三个是**纯弹层**（无显示区）。

- `WotSelectPicker`（触发区）：新增 `readonly` + `error`；触发区套用框类三态
  （readonly 去边框 / disabled 浅灰底 + 灰字 / error 红边框），并接入 `WotFieldScope` 下发。
- `WotCascader`（触发区）：同上。
- `WotPicker`（纯弹层）：新增 `readonly`（锁滚轮、配色不变）；`disabled` 现额外整体淡化
  （原先只锁滚动、不改配色）。
- `WotDatetimePicker`（纯弹层）：新增 `disabled` + `readonly`（原先两者都缺）。
- `WotCalendar`（纯弹层）：新增 `disabled` + `readonly`。

> 弹层类的 `readonly` = 锁内部交互、**配色不变**；`disabled` = 锁交互 + `Opacity(0.5)` 淡化。
> 弹层没有「输入框边框」，故不套用框类的「readonly 去边框」策略。

### 三态推广（第 3 批，2026-09-20）

- `WotSearch`：新增 `error`（搜索框本身无边框，错误时补一圈红边）；`disabled` 现灰底 + 灰字 + 图标灰。
- `WotPasswordInput`：新增 `error`（格子边框转危险色）；`disabled` 现浅灰底 + 灰点 / 字 + 边框灰；
  锁定时不再显示聚焦光标态。
- `WotSignature`：新增 `readonly` + `error`（画板描红边）；readonly 锁书写 / 清空 / 撤销（保留「确认」导出），
  disabled 额外淡化。
- `WotKeyboard`：新增 `readonly`（锁全部按键、配色不变）；disabled 额外淡化。
  **键盘无校验语义，故不提供 error**（错误由配套的密码框 / 单元格表达）。
- `WotUpload`：新增 `readonly`（锁添加 / 删除，**预览仍可用**）；disabled 额外淡化。

---

## 0.2.0 — 2026-09-16 ~ 2026-09-17

### ⚠️ BREAKING CHANGES（除默认值外）

- `WotFormRule` 签名由 `bool Function(String?)` 改为 `Object? Function(dynamic)`。
  **既有写法无需改动**（入参为 `dynamic`，`v.isNotEmpty` 等表达式照常编译），
  但显式声明了 `WotFormRule` 类型的变量需要同步更新。
- `WotFormControl.valueOf` 返回类型由 `String?` 改为 `Object?`。
  调用方若用到字符串方法需先判类型，例如 `(v is String && v.isNotEmpty)`。
- `WotFormControl.rules` 由 public field 改为私有，请改用 `setRules()`。

### ⚠️ BREAKING CHANGES（默认值）

**19 项组件默认值已与 Vue/uni-app 版 `wot-ui` 对齐。**

凡业务代码中**未显式传参**的实例，升级后表现会变。库内无全局覆盖机制
（`wot_config_provider` 仅下发 button / tag 默认值），因此影响面只能通过代码排查确认。

#### 高危 —— 视觉形态或交互行为改变

| 组件 | 参数 | 旧值 → 新值 | 不传参时的实际后果 |
|---|---|---|---|
| `WotSelectPicker` | `type` | `radio` → `checkbox` | **行为相反**：单选变多选 |
| `WotSwiper` | `autoplay` | `false` → `true` | 轮播开始自动播放（示例页 6 处实例受影响） |
| `WotSwiper` | `interval` / `duration` | `3000` / `500` → `5000` / `300` | 播放节奏变化 |
| `WotGrid` | `square` | `true` → `false` | 栅格由正方形变为内容高度，布局整体变形 |
| `WotNavbar` | `leftArrow` | `true` → `false` | 返回箭头消失 |
| `WotCalendar` | `switchMode` | `month` → `none` | 由「可切月」变为「平铺全部月份」 |
| `WotCalendar` | `firstDayOfWeek` | `1` → `0` | 周起始由周一变为周日 |
| `WotInputNumber` | `min` | `0` → `1` | 不传参时默认显示 `1` 而非 `0` |

> `WotCalendar.switchMode` 改为 `none` 的同时，已配套补上 `minDate` / `maxDate` 的默认值
> （当前日期 ±6 个月，对齐 Vue `calendar.md`）。若业务侧曾依赖 `null` 时的 ±20 年兜底，需显式传参。

#### 中危 —— 数值 / 间距微调

| 组件 | 参数 | 旧值 → 新值 |
|---|---|---|
| `WotInputNumber` | `max` | `100` → `MAX_SAFE_INTEGER` |
| `WotNotify` | `duration` | `2500` → `3000` |
| `WotCircle` | `size` / `strokeWidth` | `100` / `14` → `120` / `18` |
| `WotQrCode` | `size` / `errorLevel` | `160` / `m` → `200` / `H` |
| `WotTabbar` | `bordered` | `true` → `false` |
| `WotGap` | 默认高度 | `12` → `14` |
| `WotCountTo` | `duration` | `2000` → `3000` |
| `WotNoticeBar` | `speed` | `60` → `50` |
| `WotTour` | `borderRadius` / `offset` | `8` / `16` → `4` / `20` |
| `WotCurtain` | `maskClose` | `true` → `false` |
| `WotWatermark` | `imageWidth` / `rotate` | `40` / `-22` → `100` / `-25` |
| `WotDatetimePicker` | `type` | `date` → `datetime` |
| `WotWatermark` | `fullScreen` | `false` → `true` |

### Fixed

- `WotWatermark.fullScreen`：原先是**死参数**（`build` 从未引用，恒为内嵌 `Stack` 实现）。
  现已真正实现——`fullScreen: true` 时水印由 `OverlayEntry` 承载，浮在整页之上（对应 CSS `fixed` 语义），
  非全屏时仍为容器内嵌。
- `WotCalendar`：`switchMode: none` 平铺模式原先会因缺少日期边界而渲染约 480 个月，
  现已补上 `minDate` / `maxDate` 默认边界。

- `WotImg`：**修复运行时崩溃**。`onLoad` / `onError` 原先由 `loadingBuilder` / `errorBuilder`
  在 build 阶段同步触发，调用方只要在回调里 `setState` 就会抛
  `setState() or markNeedsBuild() called during build`。现在两个回调统一延后到本帧构建结束后再发出。
- `WotToast.loading`：原先 2 秒后自动消失（与「不自动关闭」的注释语义相反）。
  现在 loading 常驻，只能由 `WotToast.close` 或下一个 toast 顶替。
- `WotImagePreview`：页码 `{当前}/{总数}` 原先不受 `showIndex` 控制，现已修正。
- `WotTabbar`：clone item 时丢弃了 `onClick`，导致每个 tab 项的点击回调永不触发，现已补传。
- `WotPicker`：补 `didUpdateWidget`，外部改变 `values` / `columns` 后重新钳制（原先受控失效）。
- `WotSwipeAction`：补 `initState` / `didUpdateWidget`，外部改变 `show` 可同步展开态；
  `_set` 统一回调 `onChange`（原先只在点击操作按钮时回调一次）。
- `WotCountDown`：`didUpdateWidget` 现在同时处理 `value` 与 `autoStart` 变化，
  重置数值后按 `autoStart` 重启或停止定时器（原先数字变了但计时状态不对）。
- `WotCountTo.speed`：由死参数变为真实生效，`duration = |modelValue| / speed`。
- `WotInputNumber.longPress`：由死参数变为真实生效，长按以 120ms 周期连续步进，到 `min`/`max` 自动停止。

- `WotInput.type`：由死参数变为真实生效，映射为 `TextInputType`（number/digit/tel/email/url）。
- `WotIcon` 名称解析：原先 `replaceAll('-', '-')` 是无效自替换；现归一化 `_` 与空格为 `-` 再转小写。
- `WotDialog.type`：实现左侧 4px 辅助色条（success/warning/error/info 四色）。
- `WotDialog.alert`：补上此前漏暴露的 `type` 参数（`confirm` 与 `WotDialogView` 一直支持，
  只有 `alert` 没有透传，导致 alert 无法使用辅助色条）。
- `WotSlideVerify.errorText`：失败态展示该文案，1.2s 后自动复原。
- `WotActionSheetItem.icon`：现在会渲染在文字左侧。
- `WotStepData.status`：现在生效。`waiting`（默认值）视为「未指定」，仍按 `active` 索引推导，
  因此既有用法表现不变；`finished` / `process` / `error` 会覆盖索引推导。
- `WotSkeletonItem.animate`：由死参数变为真实生效（`WotSkeletonItem` 改为 StatefulWidget，自带闪烁动画）。
- `WotColumnOption.disabled`：置灰显示，且滚动落点会吸附到最近的未禁用项。
- `WotPopup.safeArea` / `safeAreaInsetBottom`：原先是两个**死参数**——`build` 里的 `SafeArea`
  只按 `position` 推导贴边侧，从不读取这两个值。现在：
  `safeArea: false`（默认）保持原行为（只避让贴边那一侧），`true` 时四边统一避让；
  `safeAreaInsetBottom` 非空时单独覆盖底边。**默认行为未变，无破坏性。**
- `WotGrid.reverse`：现在会把子项整体倒序后按列切分。
- `WotPickerView.itemExtent` / `visibleItemCount`：新增透传。
  这两个参数此前只加在 `WotPickerViewColumn`（单列底座）上，公开的 `WotPickerView` 没有往下传，
  导致多列入口改了完全没反应。现在 `WotPickerView.height` 改为可空，
  未显式传入时按 `itemExtent × visibleItemCount` 推断；默认值仍为 40 × 5 = 200，
  **与原先硬编码的 200 一致，既有调用表现不变**。
- `WotCountTo.speed`：由死参数变为真实生效，换算为 `duration = |modelValue| / speed`（秒）；
  `speed` 为 null 或非正数时回退到 `duration`。
- `WotSkeletonItem`：**修复切换 `animate` 时崩溃**
  （`_WotSkeletonItemState is a SingleTickerProviderStateMixin but multiple tickers were created`）。
  该组件在 `animate` 切回 true 时会重建 `AnimationController`，
  而 `SingleTickerProviderStateMixin._ticker` 只在 State 的 `dispose()` 里清空，
  第二次 `createTicker` 直接命中断言。已改用 `TickerProviderStateMixin`。

  顺带修了 `WotSkeleton`（父组件）的一处空转：`animate: false` 时
  控制器此前仍在 `repeat`，现在会 `stop()`；重新置 true 时复用同一控制器再 `repeat()`。
  全库已排查，仅有 `WotSkeletonItem` 这一处「条件重建 AnimationController」的写法。

- `WotPopup` 弹层本体动画：原先是 `AlwaysStoppedAnimation`（零过渡），`duration` 只作用于遮罩。
  现在由 `AnimationController` 驱动，上/下/左/右为滑入、居中为缩放，曲线 `easeOutCubic`。
- `WotSwiper.loop`：原先 `PageController` 非无限，只在自动播放取模时用到，手动滑动到头就停。
  现在用大数取模法实现真正的无限循环（`onChange` 与指示点仍对外报 0..count-1 的逻辑索引）。
- `WotPopover.showArrow`：现在会绘制三角箭头，方位由 `placement` 推导。
  已知限制：空间不足自动翻转时箭头方向不会跟着翻转。

- `WotFloatingPanel`：停靠模型重构。
  - ⚠️ **破坏性**：`anchor` / `min` / `max` 三个比例参数已删除，改用 `anchors`
    （`List<WotFloatingPanelAnchor>`，`pixels(n)` / `fraction(n)` 可混排，支持 `[100, 0.4H, 0.7H]` 这类多档位）。
    仅有示例页引用，已同步重写。
  - 新增 `initialAnchor`（初始停靠点，默认取 `anchors` 中间项）、`height`（受控高度）、
    `onHeightChange`（高度变化回调，拖拽与吸附动画中均触发）。
  - 拖拽松手后回弹到**最近吸附点**（260ms 动画）。

- `WotSignature`：补全**图片导出闭环**与历史记录（原来只自绘、拿不到签名结果）。
  - 新增 `onConfirm`（`WotSignatureResult { success, bytes }`）、`fileType` / `quality` / `exportScale`、
    `enableHistory`、`step`。
  - 公开方法 `confirm()`（异步导出）/ `revoke()` / `restore()` / `clear()`；底部内置 清空 / 撤销 / 恢复 / 确认 操作栏。
  - 导出用 `RepaintBoundary` 截图 + `toImage(pixelRatio)` → `toByteData`。
  - ⚠️ 本环境 Flutter 引擎的 `ImageByteFormat` 无 `jpeg`，JPG 自动回退 PNG、`quality` 失效；
    参数保留以对齐 Vue `wd-signature`，升级到 Flutter ≥ 3.22 后 JPG 即生效。

- `WotTabs`：拓展 Flutter 生态接入与指示器样式。
  - 新增可选 `controller`（`TabController`）：注入后与 `DefaultTabController` / 外部 controller 双向联动，
    `modelValue` 随之失效（`controller.length` 须等于子项数）。
  - 新增 `onPageChanged`（滑动切换页码回调）、`indicatorWeight`、`indicatorPadding`、
    `indicatorSize`（`tab` / `label`，label 模式用 `TextPainter` 测标题宽度）。
  - 不传 `controller` 时行为与旧版完全一致。
  - 未做 `sticky` 吸顶（组件非 sliver，单加参数做不出真吸顶，需拆 `WotTabsBar`+`WotTabBarView`）。

### Added

- `WotUpload` 真实上传能力（原为模拟上传，仅延时 600ms 置成功）：
  - `uploadMethod`：`WotUploadMethod`，调用方自定义上传，全平台可用（推荐）
  - `action` / `header` / `formData` / `fileFieldName`：内置 multipart 上传配置，仅 native（`dart:io`）
  - `WotUploadResponse`：`statusCode` / `body` / `url` / `error` + `isSuccess`
  - `onFail`：单个文件上传失败回调
  - `accept` 现在真正生效（解析为 `FileType` + `allowedExtensions`），原先硬编码 `FileType.any`
  - 上传中显示真实百分比；失败态显示重试图标，点击重新上传
  - **web 平台不支持内置上传**（无 `dart:io`），请提供 `uploadMethod`

- `WotForm` / `WotFormItem` 校验体系重构（原先 `_values` 只支持 `String`，
  导致 switch / rate / slider 的 `name` 全部失效）：
  - 新增 `model`（初始数据）、`validateTrigger`（`change`/`blur`/`submit`）、
    `errorType`（`message`/`toast`/`none`）、`onError`
  - `WotFormState.validate([prop])` 支持只校验单个字段；新增 `validateFields()` 返回完整错误表
  - 新增 `WotFormState.reset()`；`WotFormItem` 新增 `clickable` / `isLink` / `onTap`
  - `WotFormRule` 返回值支持三态：`null`/`true` 通过、`false` 用默认文案、字符串即自定义提示
  - `switch` / `rate` / `slider` / `input_number` 的 `name` 现在会真正登记到表单

- `WotInput` / `WotTextarea` 基础输入能力（此前外部完全拿不到 controller 与焦点，
  表单入口组件不可编程控制）：
  - `controller`：外部 `TextEditingController`，**由调用方持有与销毁**
  - `focusNode`：外部 `FocusNode`，由调用方销毁，组件只挂/摘 listener
  - `inputFormatters`：`List<TextInputFormatter>?`
  - `autofocus`（默认 false）、`onSubmitted`、`textInputAction`

  两点语义需注意：① 组件内部用 `_ownsController` / `_ownsFocusNode` 区分归属，
  外部传入的对象绝不代为 dispose；② **传入 `controller` 后 `value` 仅作初始值**，
  `didUpdateWidget` 不再用 `value` 回填，否则外部改动会被旧 `value` 覆盖回去。

  顺带修复：`clearable` 图标与 `showWordLimit` 字数统计原先只在 `onChanged` 里刷新，
  外部程序化改 `controller.text` 时二者会停在旧值；现改为监听 controller。
- `WotFormItem`：**修复进入页面即显示必填错误**。原先只要 `required: true` 且值为空就报错，
  不区分「尚未校验」与「校验不通过」。现在必填空值提示只在该字段被校验过之后才展示
  （`WotFormControl.wasValidated`）。`errorMessage`（外部指定）行为不变，始终展示。

- `WotNavbar`：实现 `PreferredSizeWidget`，可直接用于 `Scaffold.appBar` / `NestedScrollView`。
  新增 `height`（默认 44，原先硬编码）、`topPadding`（计入 `preferredSize`）、
  `safeArea`（**作为 appBar 时须置 false**，否则与 Scaffold 避让重复）。
- `WotImagePreview`：新增 `closeable`（默认 true）与 `closeIconPosition`
  （`topLeft`/`topRight`/`bottomLeft`/`bottomRight`）。此前没有关闭按钮，只能点遮罩退出。
- `WotPickerView`：新增 `visibleItemCount`（未显式传 `height` 时按 `itemExtent * count` 推断）、
  `itemExtent` 透传；新增 `WotPickerViewOptions.listFrom()` 支持自定义
  `valueKey` / `labelKey` / `childrenKey`；`WotColumnOption` 新增 `children`（级联数据载体）。
  （2026-09-17 补：上述两项此前只加在单列底座 `WotPickerViewColumn` 上，本组件未透传，已修。）

- `WotImagePreview` / `WotVideoPreview` / `WotPopup` / `WotPopover` / `WotCurtain` /
  `WotTooltip` / `WotTransition`：**修复「setState() or markNeedsBuild() called during build」**。
  这些组件的 `onOpen` / `onClose` / `onShow` / `onHide` / `onEnter` 原先在 `initState`
  或 `didUpdateWidget` 里同步触发，而这两处都处于 build 阶段，调用方只要在回调里
  `setState` 就会崩溃。现在统一延后到本帧构建结束后再发出。

  `WotPopover` / `WotTooltip` 额外修复了同一成因的**另一半问题**：`didUpdateWidget` 里
  同步 `insert` / `remove` `OverlayEntry`，会让 `Overlay` 这个**祖先**节点 `markNeedsBuild`
  （build 阶段只允许标记当前构建节点的后代），同样抛上述异常。现与回调一并延后一帧。

### Examples

批次一第 4 条「改完同步示例页」此前一行未动，本次起分批补齐（详见 `DEMO_GUIDE.md`）：

| 批次 | 页面 |
|---|---|
| 1 | `popup` / `popover` / `swiper` / `steps` |
| 2 | `tabbar` / `input` / `icon` / `dialog` |
| 3 | `count_to` / `input_number` / `slide_verify` / `action_sheet` / `skeleton` / `picker_view` / `grid` / `watermark` |

补示例页不只是「加演示」，本轮借此又发现并修掉了三处缺陷：
`WotDialog.alert` 漏 `type` 参数、`WotPickerView` 漏透传 `itemExtent`/`visibleItemCount`、
`WotPopup.safeArea` / `safeAreaInsetBottom` 是死参数。
另修正两处「演示本身写错」：`wot_icon_page` 的「点击图标」压根没传 `onClick`；
`wot_tabbar_page` 分节标题写着已废弃的 `fixed` 且页面根本没演示。

### Deprecated

- `WotOverlay.zIndex`、`WotWatermark.zIndex`、`WotIcon.classPrefix`、`WotTabbar.fixed` —— 四者从未被 `build` 消费。
  Flutter 没有 CSS `z-index` / class 语义，层级由父级 `Stack` 的子节点顺序决定
  （水印浮到整页之上请用 `fullScreen`）。`WotTabbar.fixed` 同理——是否吸底由父级决定，
  请直接放进 `Scaffold.bottomNavigationBar`。将在后续版本移除。
### 迁移建议

1. 全局搜索上表参数名，凡未显式传参处逐项评估是否要补显式值
2. 优先检查 `WotSelectPicker.type` 与 `WotSwiper.autoplay`——这两项影响面最大
3. 若业务期望 `WotInputNumber` 从 0 起，显式传 `min: 0`（示例页 `wot_input_number_page.dart:30` 为参考写法）
4. 测试/示例页中隐式依赖旧默认值的地方，需改为显式传参。本次已修正：
   - `test/calendar_type_test.dart` — `datetimeRange` 用例补 `switchMode: month`（受限高度无法平铺 12 个月）
   - `test/watermark_overflow_test.dart` — 两个用例补 `fullScreen: false`（用例语义是验证容器内裁剪）

### 已知遗留

- `WotInputNumber.modelValue` 默认仍为 `0`，配合 `min: 1` 会在 `initState` 被 `clamp` 到 `1`。
  Vue 的 `v-model` 无默认值（空），Flutter 因 `num` 不可空取 `0`，属必要妥协。
