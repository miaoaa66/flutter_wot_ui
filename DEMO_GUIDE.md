# 示例页（example）编写规范

> 目的：让 `example/lib/pages/` 下的示例页成为组件能力的**可交互说明书**。
> 组件加了配置项，示例页必须同步；否则新能力无法验证，也无法被发现。
> 配套文档：`COMPONENT_AUDIT.md`（组件配置项审查）

---

## 一、页面结构约定

复用 `example/lib/common/demo_scaffold.dart` 三件套，不要自建 Scaffold：

```dart
WotDemoScaffold(
  title: 'WotXxx 组件',
  children: [
    demoSection('分组标题（属性名/能力域）'),
    demoBlock('label：本块演示什么', 组件实例),
    demoBlock('label', 组件实例),
  ],
)
```

| 构件 | 用途 | 约定 |
|---|---|---|
| `WotDemoScaffold` | 页面骨架 | `title` 用 `WotXxx 中文名` |
| `demoSection` | 能力域分组 | 一个属性族一组，如「填充模式（mode）」 |
| `demoBlock` | 单个演示 | `label` 写清**属性名 + 取值**，如 `round: true（圆形）` |

交互反馈统一用 `demoToast(context, '...')`，不要各自写 SnackBar。

---

## 二、覆盖标准（改组件时逐条对照）

### 必做

1. **每个配置项至少一个 `demoBlock`**
   纯视觉属性（颜色/尺寸）可合并演示，但 label 必须点名出现的属性。

2. **枚举类型：每个枚举值都要出现**
   例：`WotImgMode` 有 14 个值，示例页应能逐个看到效果，不能只演示 1–2 个。
   数量多时用 `Wrap` 平铺 + 文字标注。

3. **交互态必须齐全**：默认 / 禁用（`disabled`）/ 加载（`loading`）/ 错误 / 空态。

4. **布尔开关要能现场切换**
   静态展示 true 和 false 两个实例不够——提供 `Switch` 或点击切换，
   让人能验证「同一实例切换后是否响应」（这能暴露 `didUpdateWidget` 缺失问题）。

5. **回调要有可见反馈**
   `onChange` / `onConfirm` / `onError` 等一律接 `demoToast` 或更新页面上的文本，
   确认回调真的被触发了。

6. **受控用法单独演示**
   表单类组件要展示「外部 setState 改变入参 → 组件跟着变」，验证受控是否生效。

### 建议

7. **边界值演示**：超长文本、`max` 溢出、空数据、极值。
8. **组合用法**：组件在真实场景的搭配（如 Form + FormItem + Input）。
9. **未能演示的能力要写注释**：若某属性因组件实现限制无法演示，
   在页面里用 `// TODO: xxx 待组件支持` 标注，不要静默略过。

---

## 三、组件改动 → 示例页同步 checklist

每次改 `lib/src/components/**/wot_xxx.dart` 后，逐项打勾：

- [ ] 新增参数 → 对应示例页加 `demoBlock`
- [ ] 新增枚举值 → 示例页枚举演示补全
- [ ] 修改默认值 → 示例页 label 标注新默认值
- [ ] 修复「死参数」→ 示例页补上该参数的演示（证明它现在真的生效）
- [ ] 修复受控问题 → 示例页加「外部切换」演示
- [ ] 删除/废弃参数 → 示例页同步移除
- [ ] 页面能编译通过（`dart analyze` 无新增问题）
- [ ] **Grep 扫旧值回归**：改完后 Grep 搜索「应当消失的旧值」，确认无残留

> **两点修正（2026-09-16）**
> 1. 原 checklist 写 `flutter analyze`，但本环境 Flutter 缺 git 直接失败，实际一律用 `dart analyze`。
> 2. `analyze` 只能查类型与 lint，**查不出「参数改了但没生效」**。上一轮 4 处改动 agent 报「已改」却未落盘，
>    全靠 Grep 扫旧值兜住。因此「Grep 回归」固化为必打勾项，不是可选项。

---

## 四、当前覆盖度基线（2026-09-20 重测）

### 口径变更说明（重要）

原基线以「Vue 文档 `###` 小节数」为分母，实测**失真**：

- 同为 1 个 `demoBlock` 的 `index_bar` 被标「尚可 50%」、`curtain` 被标「不足 25%」——差了两档
- `input` 107%、`calendar` 157%、`select_picker` 111% 超过 100%，说明分母与目标不可比
- 结论：Vue 小节粒度不统一，**不能作为排序依据**

**现改以实测 `demoBlock` 数为唯一口径**，Vue 比值降级为参考。

### 统计范围修正

原基线只覆盖 69 个页面，实测有 `demoBlock` 的页面为 **77 个**，漏统计 8 个：
`cell`、`circle`、`count_to`、`floating_panel`、`loadmore`、`picker`、`picker_view`、`slide_verify`。
其中 `picker` / `picker_view` 属 C 类受控失效 + P0 底座组件，漏统计影响较大。

### 实测基线（2026-09-20）

| demoBlock 数 | 组件 |
|---|---|
| **1（最紧急）** | `sidebar`、`index_bar`、`img_cropper`、`curtain` |
| **2** | `backtop`、`card`、`cell_group`、`collapse`、`empty`、`drop_menu`、`notify`、`floating_panel`、`qr_code`、`video_preview` |
| **3** | `segmented`、`transition`、`action_sheet`、`count_down`、`fab`、`overlay`、`sort_button`、`swipe_action`、`toast`、`loadmore` |
| **4** | `badge`、`avatar`、`gap`、`circle`、`image_preview`、`picker_view`、`tooltip`、`tour`、`picker` |
| **5** | `tabs`、`divider`、`notice_bar`、`popup`、`table`、`theme_btn`、`cascader` |
| **6** | `expand`、`row_col`、`progress`、`skeleton`、`steps`、`watermark`、`radio`、`datetime_picker` |
| **7** | `form`、`navbar`、`pagination`、`dialog`、`text`、`loading`、`swiper`、`slide_verify`、`tag`、`switch`、`keyboard` |
| **8** | `barcode`、`icon`、`popover`、`rate`、`password_input` |
| **9** | `cell`、`tabbar`、`button`、`count_to`、`checkbox`、`slider`、`search`、`upload`、`signature` |
| **10+** | `select_picker` 12、`input_number` 11、`grid` 14、`img` 15、`input` 22、`calendar` 24 |

> 2026-09-20 重测：共 **79 个**示例页含 `demoBlock`。相比 09-16 基线，
> `skeleton`(1→6)、`tabbar`(2→9)、`steps`(2→6)、`popover`(2→8)、`count_to`(2→9)、
> `icon`(4→8)、`watermark`(3→6)、`input`(15→18)、`grid`(12→14) 等十余页已大幅补齐；
> 新增 `theme_btn`(5) 与 `image_preview`(4) 两个独立示例页。
> 仍待补的最紧急组（1 块）为：`sidebar`、`index_bar`、`img_cropper`、`curtain`。
>
> 2026-09-20 三态语义推广配套（三轮）：第一轮 `input` 18→22、`cell` 6→9、`form` 5→7；
> 第二轮 `checkbox` 6→9、`radio` 3→6、`slider` 7→9、`switch` 6→7、`rate` 7→8、`input_number` 10→11；
> 第三轮 `select_picker` 10→12、`cascader` 3→5、`picker` 3→4、`datetime_picker` 5→6、`calendar` 22→24、
> `search` 8→9、`password_input` 6→8、`signature` 7→9、`keyboard` 4→7、`upload` 8→9。
> **至此 16 个三态推广组件 + 3 个试点组件的示例页全部覆盖完成。**

**均值参考**：原「整体 48%」基于失真分母，不再引用。

---

## 五、补齐优先级（2026-09-16 修订）

结合「实测 demoBlock 数低」与「组件能力已具备（补齐示例即可见效）」两个条件：

> 截至 2026-09-20：下表为 09-16 制定的待办计划，多数批次已通过「补示例页的执行记录」推进完成，
> 最新覆盖度以第四节基线为准，各页面的补齐明细见下方执行记录。

| 批次 | 组件 | 状态 / 前置条件 |
|---|---|---|
| 第一批 | `img` ✅、`grid` ✅、`swiper`(4)、`skeleton`(1)、`sidebar`(1) | img / grid **已完成**（15 / 12 块），剩余三页继续 |
| 第二批 | `tabbar`(2)、`radio`(3)、`steps`(2)、`popover`(2)、`qr_code`(2)、`collapse`(2) | **需先修组件再补示例**：`popover.showArrow`、`steps.status` 均为 A 类死参数，不修则示例写出来也不生效 |
| 第三批 | `upload`(5)、`cascader`(3)、`tabs`(3)、`drop_menu`(2) | 组件本身有 P0 缺口，「补组件 + 补示例」一起做，见 `COMPONENT_AUDIT.md` 批次二 |
| **第四批（新增补漏）** | `popup`(2)、`curtain`(1)、`index_bar`(1)、`img_cropper`(1)、`notify`(2)、`backtop`(2)、`card`(2)、`empty`(2)、`cell_group`(2)、`count_to`(2)、`video_preview`(2)、`floating_panel`(2) | 实测同为 1–2 块，但**原计划完全未纳入** |

> **第四批为什么必须补**：原计划按失真的 Vue 比值排序，把这几个漏掉了。
> 其中 `popup` 只有 2 块却是 `dialog` / `action_sheet` / `toast` / `select_picker` 的**公共底座**，
> 且 `wot_popup` 的动画参数是 A 类死参数第 1 项——**建议提到第二批之前优先处理**。

### 与 `COMPONENT_AUDIT.md` 的交叉引用

改组件时必须回头看本节，两类工作强耦合：

| 组件侧改动 | 需同步的示例页 |
|---|---|
| A 类死参数修复（18 处） | `popup`、`swiper`、`tabbar`、`input`、`icon`、`dialog`、`popover`、`count_to`、`input_number`、`slide_verify`、`action_sheet`、`steps`、`skeleton`、`picker_view`、`grid`、`watermark` |
| C 类受控修复（3 处） | `picker`(3)、`swipe_action`(3)、`count_down`(3)——按「必做」第 4、6 条加「外部切换」演示 |
| F 类独立缺陷（3 项） | `toast`(3)、`image_preview`（✅ 已补独立页面）、`tabbar`(2) |
| D 类 P0 补齐 | `upload`、`form`(4)、`input`、`signature`(4)、`tabs`、`navbar`(5)、`floating_panel`(2)、`cascader`(3)、`picker_view`(4) |

### 补示例页的执行记录（2026-09-16 ~ 09-17）

批次一第 4 条「改完同步示例页」此前一行未动，本轮起补。已完成的四页：

| 页面 | 补了什么 | 顺带发现 |
|---|---|---|
| `wot_popup_page` | position 5 值全覆盖、`duration`（A#1）、`modal`/`round`/`closeOnClickOverlay` 现场切换、`onOpen`/`onClose`/`onClickOverlay` 日志 | **`safeArea` / `safeAreaInsetBottom` 是死参数**（传 true/false 渲染完全一样）→ 已记为 A#20/#21 并修复 |
| `wot_popover_page` | placement 8 值全覆盖、`showArrow`（A#10）现场切换、`trigger` 三模式、受控 `visible` + `didUpdateWidget` 验证 | `showArrow` 的字段注释仍写着「暂未绘制箭头」，已同步更正 |
| `wot_swiper_page` | `loop`（A#2）现场开关——切换会触发 `PageController` 重建，原实现会崩溃、`duration` 300/1200 对比、`indicator` 开关 | — |
| `wot_steps_page` | `WotStepData.status` 四个取值（A#15）+「显式状态覆盖索引推导」对照演示 | — |
| `wot_tabbar_page` | `WotTabbarItem.onClick`（F#3）回写日志、`activeColor`/`inactiveColor`、`activeIcon` 切换、`badge`/`value+max`/`isDot` 三种角标、`bordered`/`iconSize`、`child` 插槽 | 原「style」分节标题写着 fixed，但 `fixed` 已废弃、页面也根本没演示——标题与内容双错，已改为不演示并写明替代方案 |
| `wot_input_page` | `type` 六个取值（A#4）→ 各自键盘类型，`number:true` 与不传 type 的对照；外部 `controller`（写入/追加/清空/读取）、外部 `focusNode`（请求/取消聚焦）、三种 `inputFormatters`、`autofocus` 按需挂载、`onSubmitted` 日志 | — |
| `wot_icon_page` | 名称归一化四个写法（A#6）：`arrow-left` / `arrow_left` / `arrow left` / `ARROW-LEFT` 应渲染同一图标；未知名/空/null 兜底；`onClick` 有无的对照（原页面的「点击图标」演示**根本没传 onClick**） | `classPrefix` 已随参数一并移除（2026-09-17），不再演示 |
| `wot_dialog_page` | `type` 四枚举值（A#7）的左侧辅助色条；confirm 同样支持 type | **`WotDialog.alert` 漏了 `type` 参数**——`confirm` 有、`WotDialogView` 也有，唯独 `alert` 没透传，导致 alert 用不了色条。已补 |
| `wot_count_to_page` | `speed`（A#11）快慢对比 + 重放按钮、`duration`、`decimals` / `thousands`、`autoplay`、`onChange` 回写 | — |
| `wot_input_number_page` | `min` 破坏性变更（默认 0→1）的「不传 min vs 显式 min: 0」对照、`max` 不再默认 100、`step × precision` 浮点修正 | 需允许 0 的业务必须显式传 `min: 0`，否则静默截断 |
| `wot_slide_verify_page` | `errorText`（A#13）触发方式：中途松手 → 展示 1.2s 后复原；`modelValue` 程序复位；`disabled` 与「成功态不可拖动」的区分 | — |
| `wot_action_sheet_page` | `WotActionSheetItem.icon`（A#14）三种用法、`loading` 项、`showCancel` / `cancelText`、`onSelect` / `onCancel` 顺序日志 | — |
| `wot_skeleton_page` | `animate`（A#16）在 `WotSkeleton` 与 `WotSkeletonItem` 上的对比、`WotSkeletonItem` 四类型、`avatarShape`、`rowWidth` 百分比/像素两种写法、`hideTitles` | — |
| `wot_picker_view_page` | `disabled`（A#17）吸附演示、`itemExtent` / `visibleItemCount` 滑杆、`listFrom` 自定义键名（吃 `{id, name, subList}`）、`loading` / `disabled` | **`WotPickerView` 没透传 `itemExtent` / `visibleItemCount`**——2b 只加在 `WotPickerViewColumn` 上，公开的多列入口改了没反应。已补透传 |
| `wot_grid_page` | `reverse`（A#18）现场开关 + 与外部 `.reversed` 的区别说明 | 原页面末尾 TODO 写着「reverse 是死参数，待实现后补」——实现后 TODO 没删，已替换为正式演示 |
| `wot_watermark_page` | `fullScreen`（A#19）内嵌/全屏对比、`image` 图片水印、`rotate`/`opacity`/`lineHeight` 滑杆、`repeat`、`color` 与 `fontColor` 优先级、多行 `content` | `zIndex` 已 `@Deprecated`（Flutter 无 z-index 语义） |

**两条可复用的写法**：
1. 布尔参数一律配一个 `WotSwitch` 现场切换，不要只是静态摆两个实例——
   「同一实例切换后是否响应」才能验出 `didUpdateWidget` 缺失。
2. 回调一律 `setState` 写回页面上的日志文本。这既是「回调有可见反馈」（必做第 5 条），
   又能顺带验证组件有没有在 build 阶段同步回调——本轮 7 个组件的崩溃就是这么暴露的。
3. **写完演示要回头删 TODO**。示例页里的 `// TODO: 某某参数是死参数，待实现后补演示`
   在参数实现后不会自动消失，反而变成误导——`wot_grid_page` 就留了一条。
   补演示时应先全文搜 `TODO` / `死参数` / `未实现`，把已过期的清掉。
4. **命令式封装要逐个入口核对参数表**。`WotDialog.alert` 漏 `type`、
   `WotPickerView` 漏 `itemExtent`/`visibleItemCount`，都是「底层组件有、上层封装手抄漏了」。
   这类缺失编译器不报错，只能靠「列出所有能触发该能力的入口，逐个确认」发现。

### 无内嵌形态的组件（容易漏统计）

`WotImagePreview` / `WotToast` / `WotDialog` 这类**命令式服务**没有可内嵌的 widget，
写示例页时无法用 `demoBlock(组件实例)` 直接承载，因此很容易在覆盖度统计里被整组件漏掉
——`WotImagePreview` 就属于这种情况。

处理方式：示例页用「**配置项切换器（ChoiceChip）+ 触发按钮**」组合，
把参数摆在页面上让用户先选再触发，回调结果回显到页面。参见
`example/lib/pages/display/wot_image_preview_page.dart`。

> 2026-09-16 补记：`WotImagePreview` 此前既无独立示例页、也未进首页索引，
> 只能通过在 img 页点图片间接触发（`wot_img.dart:146`），
> 导致新增的 `closeable` / `closeIconPosition` 无人可见。现已补齐页面并注册到「展示 Display」分组。

**排查建议**：统计覆盖度时，除了数 `demoBlock`，还应核对「组件目录」与
「首页索引 `_Entry`」两份清单，凡在目录中存在却没有索引条目的组件都要单独确认。
