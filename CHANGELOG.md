# Changelog

本文件记录 `flutter_wot_ui` 的显著变更。版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。

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
