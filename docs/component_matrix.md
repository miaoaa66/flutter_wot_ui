# Wot-UI → Flutter Wot 组件对照表（逐组件可执行）

> 参照 `wot-ui` 源码 `src/uni_modules/wot-ui/components/*` 与文档 `docs/component/*.md` 产出。
> 状态图例：`✅` 已实现可用；`🔸` 已实现但缺功能/参数；`⬜` 完全缺失；`✖` 明确不实现（小程序专属/无 Flutter UI）。
> 批次：A=主题+注释；B=高频组件完善；C=缺失组件开发；D=按表全量补齐；E=整体验证。

> **落地进度（批次 A–E 后）**：补充能力后，各组件当前状态多为 `✅`（可在 real 组件注释/example 验证）。
> - A：主题（明暗两套 + `WotScheme.copyWith` 全色值可配置）+ 全参数中文注释；删除多套变体。
> - B：button/cell/input/textarea/input-number/checkbox/radio/switch/slider/rate/search/calendar/datetime-picker/tabs/dialog/toast/notify/action-sheet/drop-menu 能力补充 + example 补全。
> - C：新增 index-bar、tour、img-cropper、video-preview（video_player）、navbar-capsule 并入 navbar。
> - D：divider/tag/empty/card/notice-bar/watermark/overlay/popup/tabbar/sidebar/grid/fab/backtop/tooltip/popover/loadmore/skeleton/img/image-preview/progress/picker/picker-view/select-picker/keyboard/password-input/upload 能力补齐。
> - E：全库 analyze/test 通过；example 5 页渲染+滚动无溢出冒烟通过。
> 文档预留：image-preview 命令式、notice-bar 三态 type、steps `status` 生效、select-picker props 字段映射 等为已知可选增强（见各组件注释/批次汇报），非本期阻塞。

## 一、基础（basic）

| 组件 | wot 关键能力 | 类型 | 小程序专属? | Flutter 可落地? | 当前状态 | Gap（补齐项） | 建议批次 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| button | type/variant/size/round/disabled/hairline/block/loading/icon/text 等 | 属性/事件(clic+click) | open-type/lang 系列 | ✅ | 🔸 已有基础 | type 各色、variant 6 种、size 4 档、loading+icon 组合、block、事件 `onClick` | B |
| icon | name/size/color，wot 图标字体 200+ | 属性 | ❌ | ✅ | 🔸 | 图标目录需与 wot 对齐；缺 color 之外特效 | A |
| text | size/type/selectable 文本排版 | 属性 | ❌ | ✅ | ✅ 可用 | 补 selectable、type 语义 | D |
| cell/cell-group | title/label/value/desc/icon/is-link/click | 属性/事件 | ❌ | ✅ | 🔸 | 布局已优化；补 icon 槽、is-link、click 事件、cell-group border | B |
| divider | text/direction/hairline | 属性 | ❌ | ✅ | ✅ | 补 text 位置、direction 竖线 | D |
| gap | width/height/margin | 属性 | ❌ | ✅ | ✅ | - | - |
| tag | type/plain/round/mark、内置 5 色 | 属性/插槽 | ❌ | ✅ | ✅ | 补 mark、closeable、color 自定义 | D |
| empty | description/icon/image | 属性/插槽 | ❌ | ✅ | ✅ | 补 image、footSlots | D |
| card | type/title/round、阴影 | 属性/插槽 | ❌ | ✅ | ✅ | 补 footer/body 插槽排版 | D |
| navbar | title/left/right 自定义、导航 | 属性/插槽/事件 | 部分（胶囊并入） | ✅ | 🔸 | navbar-capsule 并入；安全区适配 | D |
| notice-bar | scrollable/text/左图标/右侧关闭/跳转 | 属性/插槽/事件 | ❌ | ✅ | 🔸 | 滚动动画、`scrollable`、颜色/样式回显 | D |
| badge | value/max/show-zero/dot/color | 属性/插槽 | ❌ | ✅ | ✅ | 补 max、position、hidden | D |
| watermark | 全屏/局部水印、文字/图片 | 属性 | ❌ | ✅ | 🔸 已实现 | 补 rotate/gap/zIndex、局部模式 | D |

## 二、导航（nav）

| 组件 | wot 关键能力 | 类型 | 小程序专属? | Flutter 可落地? | 当前状态 | Gap（补齐项） | 建议批次 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| tabs | type=line/card、active-color、动画、懒渲染、徽标、可滚动 | 属性/事件/插槽 | ❌ | ✅ | 🔸 | 已支持自定义宽度/滚动；补徽标、lazy-render、change 事件回点 | B |
| tabbar | 底部栏、图标切换、徽标、自定义样式 | 属性/事件 | ❌ | ✅ | 🔸 | 补 badge/max、custom 插槽、fixed 安全区 | D |
| navbar-capsule | 胶囊按钮（并入 navbar） | - | 部分 | ✅ | ⬜ | 并入 navbar 的圆角胶囊区域 | C |
| sidebar | items 选中、多选、徽标 | 属性/事件 | ❌ | ✅ | 🔸 | 补 badge、多选模式、title 插槽 | D |
| grid | 宫格、icon/text、点击 | 属性/插槽/事件 | ❌ | ✅ | ✅ | 补 icon 主题色、gap 间距 | D |
| fab | 悬浮按钮、动作展开、隐藏 | 属性/事件 | ❌ | ✅ | ✅ | 补展开菜单动画、徽标 | D |
| backtop | 回到顶部、滚动监听 | 属性/事件 | ❌ | ✅ | ✅ | 补 safe-area、自定义样式 | D |
| sticky | 吸顶 | 属性/事件 | ❌ | ✅（Sliver） | ⬜ 已移除 | 提供 Sliver 组合偏移工具或 `sliver_persistent_header` 封装 | C |
| dropdown-menu | 下拉下拉菜单 | 属性/事件 | ❌ | ✅ | 🔸 | 详见反馈-下拉 | B |

## 三、录入（form）

| 组件 | wot 关键能力 | 类型 | 小程序专属? | Flutter 可落地? | 当前状态 | Gap（补齐项） | 建议批次 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| form/form-item | 校验、错误、label 布局、表单项聚合 | 属性/方法 | ❌ | ✅ | 🔸 | 补校验规则类型(正则/长度)、自定义错误渲染、`validate/reset` 方法 | B |
| input | 双向绑定、clearable、password、前缀/后缀、事件 | 属性/事件 | ❌ | ✅ | 🔸 | 补 maxlength、showWordLimit、focus/blur 事件、prefix/suffix 插槽 | B |
| textarea | 多行、字数限制、自动增高 | 属性/事件 | ❌ | ✅ | 🔸 | 补 maxlength、showWordLimit、autosize、focus/blur | B |
| input-number | 步进、min/max、步长、disabled、整数/小数 | 属性/事件 | ❌ | ✅ | 🔸 | 补 step、min/max 越界钳制、decimal 精度 | B |
| checkbox/checkbox-group | 多选、选中态、图标、限制个数 | 属性/事件 | ❌ | ✅ | 🔸 | 补 max/min 选择数、shape、值类型 | B |
| radio/radio-group | 单选、图标、禁用 | 属性/事件 | ❌ | ✅ | 🔸 | 补 shape、背景色、support 插槽 | B |
| switch | 开关、loading、禁用、颜色 | 属性/事件 | ❌ | ✅ | ✅ | 补 loading、active/inactive 色 | B |
| slider | 单/n双滑、step、label、事件 | 属性/事件 | ❌ | ✅ | 🔸 | 补 range 双端、step、show-tooltip、drag 事件 | B |
| rate | 评分、半星、禁用、颜色 | 属性/事件 | ❌ | ✅ | 🔸 | 补 half/allow-half、void-icon、count、事件 | B |
| search | 搜索框、清空、取消/确认 | 属性/事件 | ❌ | ✅ | 🔸 | 补 input 事件、focus/blur、search 触发 | B |
| index-bar | 字母索引+锚点 | 属性/事件 | ❌ | ✅ | ⬜ | 索引条+高亮+锚点联动 | C |
| picker/picker-view | 单/多列滚动选择 | 属性/事件 | ❌ | ✅ | 🔸 | 补 value 双向、confirm/cancel 事件、切换动画 | D |
| select-picker | selectpicker 便捷封装 | 属性/事件 | ❌ | ✅ | 🔸 | 值回显、props/field-names 映射 | D |
| cascader | 级联联动 | 属性/事件 | ❌ | ✅ | 🔸 已修联动 | 补 props 字段映射、onlyLastLevel、change 事件 | D |
| datetime-picker | 日期时间滚动选择 | 属性/事件 | ❌ | ✅ | 🔸 | 补 min/max 日期、minHour/minMinute、format 类型 | D |
| calendar | 日历、单选/多选/区间 | 属性/事件 | ❌ | ✅ | 🔸 | 补 type=multiple/range、min/max 日期、poppable | B |
| keyboard | 手机数字键盘 | 属性/事件 | ❌ | ✅ | ✅ | 补 safe-area、随机排序 | D |
| password-input | 密码输入格 | 属性/事件 | ❌ | ✅ | ✅ | 补 focus、length、聚焦态 | D |
| upload | 多图/多文件、预览、删除、限制 | 属性/事件 | ❌ | ✅（file_picker） | 🔸 | 补 max-size、auto-upload、before-upload、上传状态 | D |
| signature | 手写签名 | 属性/事件/方法 | ❌ | ✅ | ✅ | 补 backgroundColor 样式 | D |
| slide-verify | 滑块验证 | 属性/事件 | ❌ | ✅ | ✅ | - | - |

## 四、反馈（feedback）

| 组件 | wot 关键能力 | 类型 | 小程序专属? | Flutter 可落地? | 当前状态 | Gap（补齐项） | 建议批次 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| overlay/popup | 遮罩、弹层位置/动画/关闭 | 属性/事件 | ❌ | ✅ | ✅ | popup 补 position/round/duration/closeOnClickOverlay | D |
| toast | 命令式轻提示、图标/文字 | 方法 | ❌ | ✅ | ✅ | 补 duration、loading 态、队列 | B |
| dialog/notify | 命令式对话框/通知 | 方法 | ❌ | ✅ | ✅ | notify 补 type/color/自定义 | B |
| action-sheet | 底部操作菜单 | 属性/方法 | ❌ | ✅ | ✅ | 补 cancel/show、loading、标题 | D |
| drop-menu | 下拉选择菜单（下拉居中） | 属性/事件 | ❌ | ✅ | 🔸 | closeOnClick/值回显/swipe | B |
| tooltip/popover | 气泡提示/浮层 | 属性/事件 | ❌ | ✅ | 🔸 | 补 trigger、placement、遮罩、事件 | D |
| loading/loadmore | 加载中/加载更多 | 属性/插槽 | ❌ | ✅ | ✅ | loadmore 补 no-more/failed 状态 | D |
| skeleton | 骨架屏、动画 | 属性/插槽 | ❌ | ✅ | ✅ | 补 loading 切换、标题/头像结构 | D |
| swipe-action | 滑动操作（左滑按钮） | 属性/事件 | ❌ | ✅ | ✅ | 补自动关闭、禁用 | D |
| curtain | 仿抖音 悬浮 播放 | 属性/方法 | ❌ | ✅ | ✅ | - | - |
| action-sheet / picker 等命令式 | - | - | - | - | - | - | - |

## 五、展示（display）

| 组件 | wot 关键能力 | 类型 | 小程序专属? | Flutter 可落地? | 当前状态 | Gap（补齐项） | 建议批次 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| img | 图片、加载失败/占位、模式 | 属性/事件 | ❌ | ✅（自绘/网络） | 🔸 | 补 placeholder/error、fit 模式、懒加载 | D |
| image-preview | 图片预览缩放/轮播 | 方法/属性 | ❌ | ✅ | 🔸 | 补缩放手势、轮播、命令式 | D |
| img-cropper | 图片裁剪（纯自绘） | - | ❌ | ✅ | ⬜ | 裁剪框+手势+导出 | C |
| circle | 环形进度 | 属 | ❌ | ✅ 已修尺寸 | ✅ | 补 stroke-linecap、渐变色 | D |
| progress | 进度条、百分比/动画 | 属性 | ❌ | ✅ | ✅ | 补 striped、颜色、动画 | D |
| count-down | 倒计时 | 属性/方法 | ❌ | ✅ | ✅ | 补 format 时/分/秒 | D |
| count-to | 数字滚动 | 属性 | ❌ | ✅ | ✅ | - | - |
| qr-code | 二维码 | 属性 | ❌ | ✅ 自绘 | ✅ | 补 size/level/fg/bg | D |
| steps | 步骤条、完成/进行/失败 | 属性/插槽 | ❌ | ✅ | 🔸 | 补 dot/icon、竖直模式 | D |
| swiper | 轮播、自动播放/循环/切换 | 属性/事件 | ❌ | ✅ | 🔸 | 补 autoplay/interval/loop、indicator 样式 | D |
| collapse | 手风琴折叠 | 属性/事件 | ❌ | ✅ | ✅ | 补 icon 位置、动画 | D |
| table | 表格、固定列/头、滚动 | 属性/插槽 | ❌ | ✅ | 🔸 | 补固定列/头、自定义单元格、合并 | D |
| avatar | 头像/组合 | 属性 | ❌ | ✅ | ✅ | avatar-group 已做重叠 | D |
| pagination | 分页 | 属性/事件 | ❌ | ✅ | ✅ | 补简洁模式、跳转 | D |
| tour | 引导蒙层气泡 | - | ❌ | ✅ | ⬜ | 高亮+气泡+下一步 | C |
| sticky | 吸顶（展示缺） | - | ❌ | ✅(Sliver) | ⬜ 已移除 | 结构调整 | C |
| video-preview | 视频预览播放 | - | ❌ | 🔸(三库) | ⬜ | 需 `video_player` | C |
| row/col/layout | 栅格布局 | 属性 | ❌ | ✅ | ✅ | - | - |
| floating-panel | 悬浮面板 | 属性/事件 | ❌ | ✅ 已修 | ✅ | - | - |
| sort-button | 排序按钮 | 属性 | ❌ | ✅ 已修 | ✅ | - | - |

## 六、功能（utils / 命令式）

| 组件 | wot 关键能力 | 类型 | 小程序专属? | Flutter 可落地? | 当前状态 | Gap | 建议批次 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| use-toast / use-dialog / use-notify / use-image-preview | 命令式 API | 方法 | ❌ | ✅ | ✅ | 与 Dart 顶层函数对齐 | A |
| use-count-down | 倒计时 Hook | 方法 | ❌ | ✅ | ✅ | count-down 组件已覆盖 | D |
| config-provider | 主题/全局配置 | 配置 | ❌ | ✅ | ✅ WotConfigProvider | 补全键、色值透传 | A |
| use-config-provider | 读取配置 | 方法 | ❌ | ✅ | ✅ | - | A |
| resize | 视口尺寸监听 | 内部 | ❌ | ✅(LayoutBuilder) | - | 内部无 UI，不单独实现 | - |
| root-portal | 根挂载 | 内部 | ❌ | ✅(Overlay) | - | 内部实现，不单独暴露 | - |

## 七、明确不实现

- 小程序专属：全部 `open-type`/`lang`/微信开放能力/客服会话/`send-message-*`/`ButtonOpenType`。
- `resize`、`root-portal`：无独立 UI 能力，作为内部实现处理。

---

## 三方依赖清单

| 包 | 用途 | 涉及组件 | 状态 |
| --- | --- | --- | --- |
| `file_picker` | 文件/图片选择 | upload | 已引入，保留 |
| `video_player` | 视频播放 | video-preview | **待引入（批次 C）**；若不同意则 video-preview 仅框架占位或推迟 |

其余组件全部纯 Flutter 自绘，无三方依赖。