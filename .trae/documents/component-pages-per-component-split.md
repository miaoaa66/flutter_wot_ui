# 组件示例按组件拆分独立页 + 属性丰富

## 一、Summary（目标）

现有示例把 ~60 个组件挤在 5 个综合大页（`basic / nav / form / feedback / display`），
每个组件只有零散几行、属性展示不全。目标：

1. **每种组件一个独立示例页**（WotForm 这类多字段联动页允许一组共存）。
2. **丰富每个页面的属性示例**，尽量把该组件每个属性的作用都展示出来。
3. 重构 `index_page.dart`，按大类分组、每项指向对应组件的独立页。
4. **按分类分阶段推进**：本轮先做「录入 form」分类（试点 + 跑通模式），验收后再按
   `basic → nav → feedback → display` 的同类模式继续（后续阶段不在本次 plan 内落地）。

## 二、Current State Analysis（现状）

- 示例 App 入口：`example/lib/main.dart` → `WotIndexPage`（`index_page.dart`）。
- `index_page.dart` 用 `_Group` / `_Entry` 列出入口，很多项 **指向同一个综合页**：
  - 基础：Button/Icon/Text/Cell/Overlay/Loading 全指 `WotBasicPage`
  - 导航：唯一 `WotNavPage`（内含 IndexBar/Segmented/Sidebar/Pagination/Transition）
  - 录入：唯一 `WotFormPage`（内含 Form/Input/Checkbox/Radio/Switch/Rate/Slider/
    SelectPicker/Cascader/Calendar/DatetimePicker/Signature/Upload/PasswordInput/
    SlideVerify/Keyboard）
  - 反馈：唯一 `WotFeedbackPage`
  - 展示：三个入口全指 `WotDisplayPage`
- 现有综合页结构：`Scaffold + ListView + _section('WotXxx ...')` 多个 `_section` 串在一个文件里，
  均用 `ScaffoldMessenger` 弹 SnackBar 做反馈。
- 依赖测试：`example/test/render_smoke_test.dart` 直接 `WotBasicPage / WotNavPage / WotFormPage /
  WotFeedbackPage / WotDisplayPage` 逐页渲染+滚动。
- 组件与类核实：
  - `WotInput` 与 `WotTextarea` 同存于 `lib/src/components/input/wot_input.dart`（均已导出）。
  - 组件全量导出见 `lib/src/components/components.dart`。
- 通用辅助当前仅 `example/lib/common/mock.dart`（网络图片/视频地址等）。

## 三、Proposed Changes

### 3.0 新建公共示例脚手架（减少后续每页样板，保证风格一致）

**新建 `example/lib/common/demo_scaffold.dart`**：
- `WotDemoScaffold({required String title, required List<Widget> children})`
  → `Scaffold + AppBar(title) + ListView(padding:16)`。
- `Widget demoSection(String text)` → 加粗区块标题（沿用 `WotText`）。
- `Widget demoBlock(String label, Widget child)` → 属性演示块：上方灰色小字 `label`（属性名/说明），
  下方带圆角边框的容器内放 `child`（常为某属性的受控组件）。这样“每个属性一类”时结构清晰，且富文本能撑满宽度。
- 复用 `_toast` 为顶层函数 `demoToast(BuildContext, String)`，供各页给交互类属性反馈。

后续各分类页均只 `import` 该脚手架 + 组件库，正文只写 `demoSection/demoBlock` 与组件。

### 3.1 「录入 form」分类：删除综合页，拆成独立组件页

删除 `example/lib/pages/form/form_page.dart`（内容迁移/重写）。在 `pages/form/` 下新建：

| 文件 | 页面内容（尽量覆盖的属性） |
|---|---|
| `wot_form_page.dart` | **WotForm + WotFormItem + 字段组合**（用户已认可此类可共存）：基础多字段提交、必填/正则校验、动态增删字段（沿用现有 `_addrKeys` 动态地址示例）、`labelWidth`、`required`、错误提示样式、`showCancel/showConfirm`、`onSubmit`。 |
| `wot_input_page.dart` | **WotInput + WotTextarea**：`value`、`placeholder`、`type`、`disabled`、`readonly`、`clearable`、`showWordLimit`+`maxlength`、`prefix/suffix`、`prefix/suffix-icon`、`focus`/`blur`/`change` 回调、`label`、`border`、`align`；Textarea 的 `rows`、`maxlength`、`showWordLimit`、`autosize`。 |
| `wot_input_number_page.dart` | **WotInputNumber**：`modelValue`、`min/max`、`step`、`disabled`、`readonly`、`precision`（小数位）、增减按钮与长按步进、`change` 回调。 |
| `wot_search_page.dart` | **WotSearch**：`modelValue`、`placeholder`、`disabled`、`readonly`、`clearable`、`showCancel`、`cancelText`、`shape`(round/radius)、`hideInput`、`onSearch/onCancel/onClear`、输入前后缀图标。 |
| `wot_checkbox_page.dart` | **WotCheckbox + WotCheckboxGroup**：单/多选、`disabled`、`shape`(round/square)、`trueValue/falseValue`、`max`（可选最大数）、`border`、Group 受控联动、`change` 回调。 |
| `wot_radio_page.dart` | **WotRadio + WotRadioGroup**：单选、`disabled`、`shape`、`direction`(row/column)、`trueValue/falseValue`、group 受控、`change`。 |
| `wot_switch_page.dart` | **WotSwitch**：`modelValue`、`disabled`、`loading`、`activeColor`、`activeText/inactiveText`、`size`、`activeValue/inactiveValue`、`change`。 |
| `wot_rate_page.dart` | **WotRate**：`modelValue`、`max`、`disabled`、`readonly`、`allowHalf`(半星)、`allowClear`、`showText`+`tips`(文案数组)、不同 `type`/`color`、`iconProp`(图标)、`change`。 |
| `wot_slider_page.dart` | **WotSlider**：`modelValue`、`min/max`、`step`、`range`(区间)、`showTip`+`tipFormatter`、`showMinMax`、`showValueInThumb`、`disabled`、`marks`/刻度、`name`(表单)、`change/changeStart/changeEnd`。 |
| `wot_select_picker_page.dart` | **WotSelectPicker**：多列 columns、`modelValue` 受控回显、`disabled`、`loading`、`title`、`placeholder`、`onChange/onConfirm/onCancel`。 |
| `wot_cascader_page.dart` | **WotCascader**：多级 options、`modelValue` 回显、`disabled`、`placeholder`、联动下钻、叶子收敛、`onChange`。 |
| `wot_calendar_page.dart` | **WotCalendar**：`single/multiple/range` 三类型、`minDate/maxDate`、`modelValue` 回显、点击年月快速跳转弹窗、`onConfirm`。 |
| `wot_datetime_picker_page.dart` | **WotDatetimePicker**：`date/datetime/time/yearMonth/year/monthDay` 各类型、`modelValue` 回显、`minDate/maxDate`、`minHour/maxHour/minMinute/maxMinute`、`onConfirm`。 |
| `wot_signature_page.dart` | **WotSignature**：绘制/清空/`confirm` 导出 base64、`lineWidth`、`strokeStyle`、`backgroundColor`、`height`、`disabled`、`local`。 |
| `wot_upload_page.dart` | **WotUpload**：`modelValue`(文件列表)、`accept`、`multiple`、`max-size`、`disabled`、`onBeforeRead/onChange/onRemove/onClick、onOversize`、内置 file_picker。 |
| `wot_password_input_page.dart` | **WotPasswordInput**：`modelValue`、长度圆点、`mask`、`ellipsis`(单点省略)、居中、焦点、底部键盘联动、`onFocus`。 |
| `wot_slide_verify_page.dart` | **WotSlideVerify**：滑块校验、`width/height`、`type`、`onVerify`（成功重置）、`local`(校验底图)、样式。 |
| `wot_keyboard_page.dart` | **WotKeyboard**：`type`(number/idcard/__digit)、`show` 受控、`disabled`、随机键盘、配合 `WotPasswordInput` 数字输入的联动示例、`onInput/onDelete、onClose`。 |

> 属性名以各组件 `lib/src/components/.../wot_xxx.dart` 的**真实字段**为准；plan 不一一列出全部枚举/取值，
> 实施时按对应组件类字段逐个补 `demoBlock`，无法本地演示的（如依赖网络/插件）用 mock 或标注。

### 3.2 重构 index_page

`example/lib/pages/index_page.dart`：
- 「录入 Form」分组替换为**一行一个组件**的入口，均 `_push` 到上面的独立页：
  WotForm / Input(含Textarea) / InputNumber / Search / Checkbox / Radio / Switch / Rate /
  Slider / SelectPicker / Cascader / Calendar / DatetimePicker / Signature / Upload /
  PasswordInput / SlideVerify / Keyboard。
- 其余分组（基础/导航/反馈/展示）本轮先**保持指向旧综合页**，待后续阶段替换。

### 3.3 更新依赖测试

`example/test/render_smoke_test.dart`：
- 保留对 `WotNavPage / WotFeedbackPage / WotDisplayPage / WotBasicPage` 的冒烟。
- 把原来对 `WotFormPage` 的单个冒烟，改为**遍历所有新 form 组件页**（导入各 `wot_xxx_page.dart`，
  循环 `_smoke`）。这样拆分后仍能捕获每页的 RenderFlex 溢出/布局异常。

### 3.4 后续阶段（不在本次实施，仅记录模式）

按 3.0 脚手架 + 3.1 的“一组件一页”模式，依次对 **basic → nav → feedback → display** 分类执行同样的拆分；
每完成一个分类就同步更新 index 对应分组 + render_smoke_test 遍历该分类页，并删除该分类旧综合页。

## 四、Assumptions & Decisions

- **按分类分阶段**：本轮只落地「录入 form」，作为试点验证模式；其余分类按同一模式后续阶段推进（用户已确认）。
- **用新页替换旧页**：迁移完成后删除旧 `form_page.dart`；索引不再指向综合页（用户已确认）。
- **WotForm 允许一组共存**：Form/FormItem/字段类型天然联动，合并一页符合用户预期。
- **WotInput 与 WotTextarea**：同文件同 export，合并到 `wot_input_page.dart`。
- **可交互属性用示例内 setState/Controller**：各页为受控组件建本地 state，反馈用 `demoToast`。
- **无法稳定回归的交互**（签名笔迹、滑动验证、键盘、上传选文件、网络图片/视频）这类依赖平台/插件的，
  widget 测试只做“渲染 + 滚动无溢出”冒烟，不强断言交互结果（沿用现有 render_smoke_test 的容错策略）。
- 不新增第三方依赖；全部用组件库自带能力。

## 五、Verification（验证步骤）

1. `cd example && flutter analyze` → 0 issue。
2. `cd example && flutter test` → 全通过（含重写后的 form 逐页冒烟）。
3. 手动运行 Web/模拟器：
   - 首页「录入 Form」出现每个组件的独立入口。
   - 逐个进入各 form 组件页，滚动不溢出；每个 `demoBlock` 的属性生效（改值/点击有反馈）。
   - 受控回显类（SelectPicker/Cascader/Calendar/DatetimePicker 的 `modelValue`）重开仍回显上一次选择。
4. 试点验收通过后，按 3.4 继续其他分类（后续另行安排实施）。