# flutter_wot_ui

对 **Wot UI**（uni-app 版）的 Flutter 复刻组件库，纯 Dart/Flutter 实现，跨平台（Web / Android / iOS / Windows / macOS / Linux）。

- 语义设计令牌：Light / Dark 两套主题 + `WotScheme.copyWith` 全色值可配置。
- 命名与参数对齐 wot：Vue props 驼峰化 → Dart 构造命名参数；`emit` → `onXxx` 回调。
- 组件独立目录、单一 barrel 出口，高内聚低耦合，接入简单。
- 尽量少引三方库，其余全部自绘。

> 开源仓库：<https://gitee.com/miaoaa66/flutter_wot_ui>

---

## 组件清单

按分类（与 wot 文档结构一致）：

| 分类 | 组件 |
| --- | --- |
| 基础 | Button、Icon、Text、Row/Col、Cell、CellGroup、Gap、Divider、Fab、Transition、ConfigProvider |
| 导航 | Navbar、Tabbar、Tabs、Segmented、Sidebar、Pagination、IndexBar、Backtop、Tour |
| 录入 | Form、FormItem、Input、Textarea、Search、InputNumber、Checkbox、Radio、Switch、Rate、Slider、PickerView、Picker、SelectPicker、Cascader、Calendar、CalendarView、DatetimePicker、PasswordInput、Keyboard、Signature、SlideVerify、Upload |
| 反馈 | Overlay、Loading、Popup、Dialog、ActionSheet、DropMenu、Popover、Tooltip、FloatingPanel、Progress、Circle、Toast、Notify、NoticeBar、SwipeAction、SortButton、Empty、CountDown、CountTo |
| 展示 | Tag、Badge、Avatar、Card、Grid、Collapse、Steps、Skeleton、Loadmore、Img、ImagePreview、Swiper、Table、Watermark、QrCode、Barcode、Curtain、ImgCropper、VideoPreview |

## 目录结构

```
flutter_wot_ui/
├── pubspec.yaml
├── lib/
│   ├── flutter_wot_ui.dart          # 统一出口（barrel）
│   └── src/
│       ├── theme/                   # 语义令牌主题（Light/Dark + copyWith 可配置）
│       ├── icon/                    # 图标名称 → IconData 映射
│       ├── util/                    # props / format / touch 纯 Dart 工具
│       └── components/              # 各组件独立目录，含 components.dart 分类出口
├── example/                         # 示例应用（含接入指南 README）
└── test/                            # 单元测试
```

## 快速开始

在你的 Flutter 项目中引入依赖：

```yaml
dependencies:
  flutter_wot_ui:
    git:
      url: https://gitee.com/miaoaa66/flutter_wot_ui.git
      ref: main
      path: flutter_wot_ui   # 仓库内组件包所在目录；按仓库实际结构调整
```

然后执行 `flutter pub get`。

用 `WotConfigProvider` 包裹应用根节点，子组件通过 `context.wotScheme` 获取语义令牌：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WotConfigProvider(
      wotTheme: WotThemeData.light, // 深色：WotThemeData.dark
      child: MaterialApp(
        home: const HomePage(),
      ),
    );
  }
}
```

页面内直接使用组件：

```dart
WotButton(
  text: '主按钮',
  type: WotButtonType.primary,
  onClick: () => WotToast.success(context, '点击了按钮'),
);
```

命令式组件（不占 widget 树）：

```dart
WotToast.success(context, '操作成功');
final ok = await WotDialog.confirm(context, message: '确认删除吗？');
```

> 更完整的接入步骤、FAQ（主题/图标/插件权限/深色换肤）见 [example/README.md](example/README.md)。

## 三方依赖

| 包 | 用途 | 平台 |
| --- | --- | --- |
| `intl` | 官方日期/数字本地化 | 全平台 |
| `qr_flutter` | WotQrCode 二维码生成（纯 Dart） | 全平台 |
| `barcode` | WotBarcode 条码生成（纯 Dart） | 全平台 |
| `file_picker` | WotUpload / WotImg 文件/图片选择 | 全平台 |
| `video_player` | WotVideoPreview 视频播放 | 全平台 |

> 图标：默认用 Flutter 内置 Material 图标映射渲染 `WotIcon`；如需 wot 官方字形，可自行打包 `iconfont.ttf` 并按 `kWotIconFontFamily` 注册（见 `lib/src/components/icon/wot_icon.dart`）。

## 本地开发 & 验证

```bash
flutter pub get
flutter analyze        # 应为零告警
flutter test           # 全量单测
cd example && flutter run -d chrome   # 运行示例
```

## 许可证

待定。