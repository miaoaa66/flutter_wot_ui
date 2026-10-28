# flutter_wot_ui 组件库全面审查报告（2026-10-27）

> 审查人：项目主控 Agent（GLM-5.3-Flash）
> 审查范围：lib/src/components/ 全部 82 个组件 + theme/locale 体系 + example 示例页 + test/CI
> 审查维度：① 库级能力体检 ② 组件属性与样式漏洞 ③ 示例属性覆盖度 ④ 遗留问题复核与回归
> 审查基准：以 Flutter 组件库生态惯例为主（受控/插槽/三态/a11y/i18n/主题），不以 Vue 版逐项对齐
> 方法：`dart analyze` 基线 + 自研参数覆盖度脚本（逐参数 vs 逐示例页全文匹配）+ 5 路并行源码审查 + 人工抽查验证
> 证据可信度标注：✅=已直接验证源码 　◈=子代理定位、已抽查 　▢=子代理指针、未逐行复核

---

## 一、总体结论

| 维度 | 结论 |
|---|---|
| 静态检查 | ✅ `dart analyze` **零问题**（Flutter 3.47.7 升级后基线保持干净） |
| 代码质量 | ✅ 良好——历史 A 类 18 处死参数、B 类 19 项默认值、C 类 3 处受控失效、F 类 4 项缺陷**维持已修复状态**，未发现新增死参数级别的硬伤 |
| 最大短板 | ⚠️ **示例页与组件能力脱节**——约 1550 个公开参数中，相当比例未在示例页出现；新加的 optionBuilder 插槽、config_provider / calendar_view 两个组件**完全没有演示** |
| 新发现 | ⚠️ **文档漂移**——COMPONENT_AUDIT.md 声称 input 示例页已补 controller/focusNode/formatter/autofocus/onSubmitted 演示，实际页面**一处都没有**（见问题 #1） |
| 未动工区 | T5 全部未启动（魔数主题化 / Sliver / sticky / RTL），三态推广到展示类未启动 |

**核心判断**：组件本体质量已过线，当前瓶颈从「组件能力」转移到「示例可信度」。库的规则手册 DEMO_GUIDE.md 自己写明「写不出演示的参数，往往就是不生效的参数」——而本次实测证明反过来也成立：**不少已生效的参数也没有演示**，使用者发现不了能力，等于不存在。

---

## 二、Flutter 组件库应具备的能力（基线框架）

沿用并复核 CAPABILITY_MATRIX.md 的框架（该框架依然有效），作为本轮评分依据。

### 2.1 库级能力 12 项

设计令牌体系 / 全局配置下发 / 明暗模式 / 国际化 / 无障碍 / 多端与 RTL / 版本治理 / 测试体系 / 文档 / 示例 Demo / 依赖克制 / 发布与 CI

### 2.2 组件级能力 10 项

受控与非受控（didUpdateWidget）/ 状态完整性（三态+error）/ 类型安全（枚举）/ 自定义插槽（builder）/ 控制器暴露 / 表单集成 / 拦截式回调 / 动画可控 / 边界防御 / 注释约定

---

## 三、库级能力体检结果

较 2026-09-20 评估（6.0/10）的主要变化：

| 能力项 | 09-20 状态 | 当前状态 | 变化 |
|---|---|---|---|
| 国际化 | 2.5 缺口 | **管道+48 key×2 语言已落地**，tr() 支持占位符 | ⬆ 大幅改善 |
| 无障碍 | 2.0 缺口 | **已接入 37 组件 / 豁免 23（有理由）**，a11y 基线测试+golden 守护 | ⬆ 大幅改善 |
| 测试保障 | 5.5 部分 | Golden 10 组件基线（含三态矩阵）+ CI 全绿 | ⬆ 改善 |
| 发布与 CI | 3.0 缺口 | GitHub Actions（windows-latest + 3.47.7 固定）analyze+test+golden | ⬆ 改善 |
| 组件覆盖面 | 8.5 强 | 82 组件 + 枚举化收官 + builder 插槽体系 | 维持强 |
| 主题令牌体系 | 8.0 强 | ✅ 硬编码 `Color(0x…)` 全库仅 **13 处/4 文件**（theme_btn 占 10） | 维持强 |
| 全局配置下发 | 部分 | ⚠️ ConfigProvider 仍只下发 button/tag 两类默认值 | 未动 |
| 响应式与 RTL | 3.0 弱 | ⚠️ 全库仍无 Directionality / EdgeInsetsDirectional 处理 | 未动 |
| 桌面端 | 弱 | ⚠️ hover 态与键盘焦点链仍缺失（MouseRegion 覆盖少） | 未动 |

**遗留库级问题**：
- `theme_btn` 全部颜色硬编码且文档自认「不读取 context.wotScheme」◈（[wot_theme_btn.dart:7-9](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/theme_btn/wot_theme_btn.dart#L7-L9)）——它是主题演示按钮，豁免有理由，但应作为**唯一豁免**写进规范，防止扩散。
- `wot_config_provider` 仍有 `wotTheme/themeMode/localeMessages/themeVars/messages` 等 6 参数无任何示例页（见第五节）。
- test 执行情况：本环境无法运行 `flutter test`（历史环境限制：代理拦截 flutter_tester 的 WebSocket，需清空 `HTTP(S)_PROXY` 或将 `127.0.0.1` 加入 `NO_PROXY`，见 CHANGELOG Note）。**测试全绿状态未在本轮复验**，建议按附录 H2 命令执行一次。

---

## 四、组件属性与样式漏洞清单

按严重度分级：S1 功能失效 ＞ S2 表现不符 ＞ S3 API 质量 ＞ S4 可维护性。本轮**未发现 S1 级崩溃或死参数新增**（analyze 零问题 + 历史死参数维持已修）。

### S2 表现不符

| # | 组件 | 问题 | 证据 | 状态 |
|---|---|---|---|---|
| 1 | drop_menu | `closeOnClickOverlay` 默认 true，但**全文无蒙层实现**，参数仍是死参数（点击外部不会关闭） | ✅ [wot_drop_menu.dart:18](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/drop_menu/wot_drop_menu.dart#L18) 声明后仅此一处出现 | D 类 P1 项确认未做 |
| 2 | swiper | `direction`（纵向轮播）、`curve`、`viewportFraction` 均缺失；viewportFraction 硬编码 1 | ◈ [wot_swiper.dart:116](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/swiper/wot_swiper.dart#L116) | T5 backlog 确认未动 |
| 3 | select_picker | 弹层高度 430 写死，小屏溢出风险仍在 | ◈ [wot_select_picker.dart:521-523](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/select_picker/wot_select_picker.dart#L521-L523) | E 类历史项 |
| 4 | img_cropper | `outputType` 为 String 且 `jpg` 恒输出 PNG（Flutter toByteData 限制），**无 @Deprecated 也无文档警示标注** | ✅ [wot_img_cropper.dart:298](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/img_cropper/wot_img_cropper.dart#L298) | 审计建议过，仍未落 |
| 5 | steps | 圆点状态色依赖 `activeColor`/`inactiveColor` 传参推导，连接线已用 scheme 令牌但圆点未统一走主题 | ▢ [wot_steps.dart:213-219](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/steps/wot_steps.dart#L213-L219) | 子代理定位 |

### S3 API 质量

| # | 组件 | 问题 | 证据 |
|---|---|---|---|
| 6 | loadmore | 双回调 `onLoadmore` 与 `onLoadMore` 并存（两处都被调用）、`loadingFailedText` 与 `failedText` 双文案参数并存——兼容设计可理解，但应 `@Deprecated` 收敛一个 | ✅ [wot_loadmore.dart:103-107](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/loadmore/wot_loadmore.dart#L103-L107) |
| 7 | dialog | `WotDialog.confirm` 有 `beforeConfirm` 拦截，`WotDialog.alert` 没有——同族 API 不对称 | ◈ [wot_dialog.dart:61-89](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/dialog/wot_dialog.dart#L61-L89) |
| 8 | popover | 存在 `bw`/`bh`/`aw`/`ah` 四个命名不明的公开参数（疑似内部 painter 尺寸泄漏到公开 API） | ✅ 覆盖度脚本输出 |
| 9 | img_cropper | `outputType` 是 String 而非常量/枚举——T3.3 枚举化收官批漏网 | ✅ [wot_img_cropper.dart:58](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/img_cropper/wot_img_cropper.dart#L58)（有 `WotCropType` 常量但参数类型仍 String） |

### S4 可维护性（延续历史，未恶化）

- E 类魔数主题化（T5.1）未启动：字号/圆角/间距硬编码仍普遍。
- [wot_pagination.dart](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/pagination/wot_pagination.dart) 文件尾全局常量 `kWhite` 仍在。
- cascader 的 `lazyLoad` / `checkStrictly`、picker_view 的 `cascade` 多列联动仍缺（D 类 P0 遗留）。
- textarea 仍寄居在 wot_input.dart 未独立成目录（D 类归档缺口）。

---

## 五、示例属性覆盖度（本轮重点）

### 5.1 方法与总量

脚本对 82 个组件文件提取 `this.x` / `super.x` 构造参数（合计约 **1550 个**，含数据模型字段），逐一在示例页全文匹配。规则噪声已人工过滤（如 toast 经命名构造函数演示、模型字段经构造流程演示的情形）。

### 5.2 结构性缺口（最优先）

| # | 问题 | 说明 |
|---|---|---|
| 1 | **input 示例页丢失 9 月声称的演示** | COMPONENT_AUDIT.md 第十节声称「示例页已补：写入/追加/清空/读取按钮、focus 请求、三种 formatter、autofocus、onSubmitted 日志」，实测 [wot_input_page.dart](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/example/lib/pages/form/wot_input_page.dart) **零匹配** focusNode / inputFormatters / autofocus / onSubmitted / controller。35 个参数中 13 个未演示。疑为 09-23 分支合并时丢失或从未落盘。**这是文档可信度问题，必须处理** |
| 2 | **calendar_view 无示例页** | [wot_calendar_view.dart](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/calendar_view/wot_calendar_view.dart) 的 onDayClick / onMonthChange / weekdays 等在全 example 中零演示 |
| 3 | **config_provider 无示例页** | 主题切换、locale 切换、级联配置是库门面能力，当前只能靠 theme_btn 页间接看 |
| 4 | **新插槽未演示** | `cascader.optionBuilder`（09-22 新增）、`picker.optionBuilder`、`picker_view.optionBuilder/selectedIndex/itemExtent/visibleItemCount` 在各自示例页零出现——违反 DEMO_GUIDE「新增参数→示例页必须同步」的第一条 |
| 5 | form_item 无独立页 | 演示并入 form 页（name/label|required 等在 form 页出现），可接受，建议在 DEMO_GUIDE 标注归属即可 |

### 5.3 未演示参数 Top 10 组件（页内未出现且全库未见）

| 组件 | 参数总数 | 未演示数 | 典型未演示项 |
|---|---|---|---|
| tour | 41 | 17 | maskPadding / nextButtonText / onLeave / autoScroll / highlight / showPrev / isLast |
| img_cropper | 21 | 13 | outputType / aspectRatio / minScale / maxScale / onCrop / onCancelled / maskColor |
| calendar | 48 | 11 | firstDayOfWeek（B 类刚改过默认值！）/ confirmText / rangeMode / onMonth / full / allowSameDay |
| popover | 31 | 9 | borderColor / borderWidth / shadowColor / elevation（+bw/bh/aw/ah 本身是 API 问题） |
| table | 33 | 7 | emptyText / showHead / headerRowHeight / onSort / selectedRows |
| fab | 25 | 1（另 11 个散落他页） | customPosition |
| tabs | 35 | 3 | current / grow / animated |
| input | 35 | 13 | 见结构性缺口 #1 |
| notify | 9 | 2 | safeHeight / onDismiss |
| badge | 17 | 2 | showZero / showDot |

其余组件（avatar/button/card/cell/cell_group/circle/collapse/curtain/datetime_picker/dialog/divider/empty/expand/keyboard/loading/notice_bar/password_input/picker/qr_code/radio/rate/row/search/select_picker/signature/slide_verify/sort_button/steps/swipe_action/switch/tag/text/theme_btn/toast/tooltip/transition/upload/video_preview/watermark 等）合计另有约 90 个参数未演示，完整明细见附注数据（脚本输出，可按需导出）。

### 5.4 枚举值覆盖（DEMO_GUIDE 要求「每个枚举值都要出现」）

57 个枚举中，未全覆盖的重灾区：

| 枚举 | 未演示值 |
|---|---|
| `WotImgMode`（14 值） | **12 个未演示**（仅 2 个出现）——img 页是全库最丰富页面（15 demoBlock），枚举覆盖却最差 |
| `WotTourPlacement` | auto/top/bottom/left/right 全部未演示 |
| `WotCurtainPosition` / `WotCurtainClosePosition` | center/bottom/top/left/right、outside |
| `WotFabType` / `WotFabPosition` | primary/info/warning/danger；left/right/custom |
| `WotQrCodeErrorLevel` | l/m/q（仅 h 演示过） |
| `WotSegmentedSize` / `WotSegmentedShape` | medium/large；square/round |
| `WotCalendarSwitchMode` | none（恰是 09-16 默认值刚改成它的那个！） |
| `WotToastType` | 经 `WotToast.success/error/...` 命名构造已演示（启发式假阴性，排除）；loading 是否可演示待确认 |
| `WotFormTrigger` / `WotFormErrorType` | blur/submit；toast |
| `WotTableSortDirection` / `WotTableRowSelection` | none/ascending/descending；single |

> 规律：**B 类刚对齐的默认值（calendar.switchMode=none、firstDayOfWeek=0）恰恰没有演示**——改默认值时示例页同步 checklist（DEMO_GUIDE 第三节）没有被执行，这是流程性漏洞。

---

## 六、遗留问题复核（9 月清单 → 当前状态）

| 类别 | 9 月状态 | 本轮复核 |
|---|---|---|
| A 类 18+2 处死参数 | ✅ 已处理 | ✅ 维持已修（analyze 零问题，抽查 popup 动画/swiper.loop/input.type 等实现仍在） |
| B 类 19 项默认值 | ✅ 已对齐 | ✅ 维持；但配套示例页同步**部分缺失**（calendar.switchMode/firstDayOfWeek 未演示，见 5.4） |
| C 类 3 处受控失效 | ✅ 已修 | ✅ 维持；且 popover/popup/floating_panel/swipe_action 的 didUpdateWidget 均在位 ◈ |
| F 类 4 项 | ✅ 已修 | ✅ 维持 |
| D 类 P0 | 大部分完成 | ⚠️ cascader lazyLoad/checkStrictly、picker_view cascade 仍缺 |
| D 类 P1 | 大部分完成 | ⚠️ drop_menu 蒙层、text 的 mode/format、swiper direction/indicator 体系、fab 定位系、checkbox/radio button 形态仍缺 |
| 三态推广展示类（tag/badge/steps/collapse/grid/table） | 未启动 | 未启动（audit 11.5 最后一项仍空） |
| a11y 低优先级遗留 3 项 | 在案 | 未动（floating_panel 拖拽语义 / slide_verify slider 角色 / keyboard 按键角色） |
| i18n 遗留（tour/fab/form/slide_verify 参数可空化） | 在案 | 未动 |
| T5（魔数主题化/Sliver/sticky/resize/textarea 独立） | 未启动 | 未启动 |
| **文档漂移** | — | ⚠️ 新发现：COMPONENT_AUDIT.md 对 input 示例页的描述与实际不符（见 5.2 #1）；DEMO_GUIDE 覆盖度基线停留在 09-20 |

---

## 七、Flutter 3.47.7 升级回归

- ✅ `dart analyze`：**No issues found**（lib + example + test 全覆盖）
- ✅ CHANGELOG 记录的适配已落地：Table onReorder 语义迁移 + 新增拖拽回归测试、golden 基线重生成、example 索引页 ListTile 透明材质修复
- ⚠️ `flutter test` 未在本环境复验（代理拦截 flutter_tester WebSocket）。建议执行：
  ```powershell
  cd F:\3project\project_template\flutter_template_dev\flutter_wot_ui
  flutter analyze        # 已替你确认归零
  flutter test           # 18+ 个测试文件 + golden
  cd example; flutter test
  ```
  （如报 `Unable to connect to flutter_tester process: WebSocketException`，清空 `HTTP(S)_PROXY` 或把 `127.0.0.1` 加入 `NO_PROXY`）

---

## 八、问题清单总表（建议处理顺序）

| 优先级 | # | 问题 | 类型 |
|---|---|---|---|
| **P0** | 1 | input 示例页丢失 controller/focusNode/formatter/autofocus/onSubmitted 演示；审计文档与实际不符 | 示例+文档 |
| **P0** | 2 | calendar_view、config_provider 两个组件零示例页 | 示例 |
| **P0** | 3 | cascader/picker/picker_view 的 optionBuilder 新插槽未演示 | 示例 |
| **P1** | 4 | drop_menu.closeOnClickOverlay 死参数（无蒙层实现） | 功能 |
| **P1** | 5 | WotImgMode 12/14 枚举值未演示（含其余 9 组枚举缺口） | 示例 |
| **P1** | 6 | calendar.firstDayOfWeek/switchMode 刚改的默认值无演示 | 示例 |
| **P1** | 7 | img_cropper outputType：String 未枚举化 + jpg 恒 PNG 无警示标注 | API |
| **P1** | 8 | loadmore 双回调/双文案参数未 @Deprecated 收敛 | API |
| **P2** | 9 | dialog.alert 缺 beforeConfirm（API 不对称） | API |
| **P2** | 10 | popover 的 bw/bh/aw/ah 公开参数命名不明 | API |
| **P2** | 11 | tour/img_cropper/calendar/table 等 Top10 未演示参数补齐 | 示例 |
| **P2** | 12 | steps 圆点状态色未走主题令牌 | 样式 |
| **P3** | 13 | T5.1 魔数主题化 / 三态推广展示类 / RTL / 桌面 hover / ConfigProvider 下发范围 | 体系 |
| **P3** | 14 | flutter test 本机复验（用户执行） | 验证 |

---

## 九、建议

1. **把「示例页同步」从纪律变成机制**：本轮两个最重的问题（input 演示丢失、新插槽未演示）都是 DEMO_GUIDE checklist 未被执行造成的。建议给 CI 加一个轻量守卫——把本轮覆盖度脚本产出固化为 `example_coverage` 检查（新增公开参数无演示即警告），比人肉打勾可靠。
2. **审计文档加「验证日期」字段**：COMPONENT_AUDIT.md 声称的事项要有 `未验证(原因)` 标注（H5 协议本身有此要求，input 页这单是执行漏洞），避免下一轮审查再花成本甄别真伪。
3. **覆盖度脚本数据落盘**：本轮脚本输出建议存为 `example/lib/pages/COVERAGE_BASELINE.md`，作为 DEMO_GUIDE 第四节基线的替代（09-20 口径已过期）。
4. **T5 之前先补示例**：魔数主题化重构会大改视觉，届时 golden 基线要重生成——示例层先补齐，重构时才有对照。

---

*审查证据：覆盖度脚本（dart 运行，逐参数正则匹配）、dart analyze（fvm 3.47.7）、5 路子代理源码审查（库级/basic+nav/display/feedback/form）、关键发现人工抽查复核。*

---

## 十、完善执行记录（2026-10-27 同日追加）

报告交付后随即执行完善批次，结果如下（`dart analyze` 全程零问题收口，CHANGELOG 已录 2026-10-27 节）：

### 已完成

| 报告 # | 事项 | 落点 |
|---|---|---|
| P0-1 | input 示例页补 controller/focusNode/inputFormatters×3/autofocus/onSubmitted+textInputAction + textarea controller | [wot_input_page.dart](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/example/lib/pages/form/wot_input_page.dart) |
| P0-2 | calendar_view 示例页新建（受控/翻月/范围/主题色/星期表头）+ 索引注册 | example/lib/pages/form/wot_calendar_view_page.dart |
| P0-3 | config_provider 示例页新建（级联合并/wotTheme/themeMode/locale）+ 索引注册 | example/lib/pages/basic/wot_config_provider_page.dart |
| P0-4 | cascader/picker/picker_view optionBuilder 演示 ×3 + **修复 WotPicker.show 漏传插槽** | wot_picker.dart |
| P1-1 | drop_menu.closeOnClickOverlay 蒙层实现（OverlayEntry 全屏 + 挖孔放行，命中测试实时读矩形）+ 演示 | wot_drop_menu.dart |
| P1-2 | 枚举/参数演示补齐：calendar switchMode=none + firstDayOfWeek、qr errorLevel 四级、badge showZero/showDot/danger、notify top/safeHeight/onClosed、fab type 五色 + customPosition、curtain bottom/outside、tour placement 五方位、img_cropper outputType/quality、dialog alert 拦截 | 9 个示例页 |
| P1-3 | img_cropper outputType 枚举化（BREAKING：值拼写不变）+ jpg 引擎支持时真输出 JPEG（quality 生效）+ 演示 | wot_img_cropper.dart |
| P1-4 | loadmore onLoadmore/failedText @Deprecated 收敛 + 示例页迁移 onLoadMore | wot_loadmore.dart |
| P2 | dialog.alert 补 beforeConfirm（与 confirm 对称）+ 演示 | wot_dialog.dart |

### 执行中的新发现（修正原报告）

1. **`config_provider.themeVars` 是新死参数**：已声明、已级联合并进 `WotConfigScope`，但主题层零消费。原报告 A 类排查漏掉它正是因为没有示例页——「补示例页作为死参数排查手段」的经验第三次应验。已在示例页 TODO 标注、CHANGELOG 登记。
2. **`WotPicker.show` 漏传 `optionBuilder`**：插槽「四层贯通」实际漏了命令式入口一层，写演示时发现并已修复。
3. **覆盖度脚本两类假阴性**（修正第五节口径）：`WotImgMode`（img 页经 `.values` 循环全覆盖）、`WotNotifyType.error` 等经命名构造（`WotNotify.error`）覆盖的类型，字面量匹配均误报。**修订后的真实枚举缺口**以本节已完成表 + 剩余 backlog 为准。
4. **`WotNotify` 内外回调名不一致**：静态 `show()` 是 `onClosed`，内部 widget 是 `onDismiss`（演示层修正为 onClosed；API 收敛列入 backlog）。

### 剩余 backlog（未动，按报告第八节顺延）

- ~~P2#11：tour/img_cropper/calendar/table/popover 的参数演示~~ → **已完成（2026-10-27 第二批）**：
  tour（蒙层交互/四按钮文案/onChange/onNext/onPrev/onLeave/maskPadding/autoScroll）、
  table（showHead/headerRowHeight/emptyText/onSort/selectedRows 受控行选/rowSelectionWidth）、
  calendar（confirmText/cancelText/allowSameDay）、img_cropper（内置操作栏 showButtons/cancelText/
  confirmText/onCancelled/onCrop + aspectRatio/cropSize/minScale/maxScale + imageProvider）。
- ~~P2#12：steps 圆点状态色走主题令牌~~ → **撤回（误报）**：`_StepCircle` 实际已用
  `scheme.dangerMain/successMain/primaryOf(6)/textDisabled` 令牌，`Colors.white` 仅为彩底图标色。
- **popover bw/bh/aw/ah/anchor、img_cropper maskColor/borderColor/gridColor、calendar full/onDay/
  years/months/rangeMode 等** → **撤出清单（脚本假阳性）**：均为私有类（`_BubblePainter`/
  `_CropOverlayPainter`/`_MonthGrid` 等）构造器参数，非公开 API。覆盖度脚本应排除 `_` 开头类。
- 附带修复：**table 示例页拖拽重排仍保留旧 `newIndex -= 1` 修正**（10-21 语义变更漏改调用方），
  按新语义会差一位，已修正——「示例页是组件语义的回归探针」再次应验。
- P3 剩余：T5.1 魔数主题化全量（~~E 类典型单点 5 项~~ → **已完成（2026-10-27 第四批）**：
  segmented 定宽溢出、navbar 胶囊自适应、select_picker 弹层高度、calendar 字号 8→10、
  pagination kWhite 清理；~~slider 魔数组~~ → **已完成（第五批）**：height/thumbSize/trackHeight
  参数化，默认值逐像素兼容 golden；~~cascader 待实测项~~ → **已转为自动化测试**：
  新增 `test/cascader_sheet_test.dart`（小屏 375×500 + 8 子项深列表开弹层/下钻，断言无
  RenderFlex 异常），随 CI/用户 flutter test 出结论）/ RTL / 桌面 hover / ConfigProvider 下发范围
  （~~themeVars 实现~~ → **已完成（2026-10-27 第三批）**：`WotScheme.applyVars` 54 令牌全量映射 +
  ConfigProvider 叠加级联 + 单元/级联测试 + 示例演示；~~notify onDismiss 命名收敛~~ → **已完成**：
  内部 `_NotifyBar.onDismiss` 更名 `onClosed`，与静态 API 一致）
- ~~三态推广展示类（audit 11.5 末项）~~ → **审计豁免关闭（第五批核实）**：逐组件核实——
  `collapse` 已有 per-item disabled（灰化 `textDisabled` + 锁切换，符合 wot_state 规范）；
  `grid`/`steps`/`tag`/`badge` 在 Vue 版本即无三态参数，硬加反而破坏对齐；
  `table` 为本项目自有扩展、亦无 disabled 语义。展示类无需推广，事项关闭。
- 硬编码色值复核：非豁免代码路径仅剩 [wot_popover.dart:354](file:///F:/3project/project_template/flutter_template_dev/flutter_wot_ui/lib/src/components/popover/wot_popover.dart#L354)
  的阴影色 `Color(0x1A000000)` 一处——令牌体系尚无 shadow 槽位，随 T5.1 增加 shadow 令牌时一并解决；
  index_bar 命中处为 doc 注释示例、theme_btn 为已声明豁免组件。
- 验证（2026-10-27 第五批收口）：~~`flutter test` 仍需用户本机执行~~ → **已在本环境跑通**。
  环境方法突破：`flutter.bat` 在本会话挂起（git 已可用仍挂，疑 BAT 包装层问题），绕过方式为
  直调工具快照：`{fvm}/bin/cache/dart-sdk/bin/dart.exe {fvm}/bin/cache/flutter_tools.snapshot test`。
  实测结论：**根目录 79/79 全绿**（含 golden 三态矩阵——slider 参数化默认值逐像素兼容得到实证；
  theme_vars / cascader_sheet 新测试通过），**example 82/82 全绿**（render smoke 逐页渲染全部
  示例页，本轮全部演示改动无溢出、无非布局异常）。
