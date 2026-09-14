# flutter_wot_ui

对 **Wot UI**（uni-app 版 https://wot-ui.cn/ ）的 Flutter 复刻组件库，纯 Dart/Flutter 实现，跨平台（Web / Android / iOS / Windows / macOS / Linux）。

- 语义设计令牌：Light / Dark 两套主题 + `WotScheme.copyWith` 全色值可配置。
- 命名与参数对齐 wot：Vue props 驼峰化 → Dart 构造命名参数；`emit` → `onXxx` 回调。
- 组件独立目录、单一 barrel 出口，高内聚低耦合，接入简单。
- 尽量少引三方库，其余全部自绘。

> 开源仓库：<https://gitee.com/miaoaa66/flutter_wot_ui>

---


## 须知

此组件库仅测试和构建了web端和android端，其他平台未测试。   
组件库也没有进行所有组件所有属性的完整测试。   
flutter新项目引入组件库参考：<https://gitee.com/miaoaa66/flutter_wot_ui_demo>   

## 组件清单

按分类（与 wot 文档结构一致）：

| 分类 | 组件 |
| --- | --- |
| 基础 | Button、Icon、Text、Row/Col、Cell、CellGroup、Gap、Divider、Fab、Transition、ConfigProvider |
| 导航 | Navbar、Tabbar、Tabs、Segmented、Sidebar、Pagination、IndexBar、Backtop、Tour |
| 录入 | Form、FormItem、Input、Textarea、Search、InputNumber、Checkbox、Radio、Switch、Rate、Slider、PickerView、Picker、SelectPicker、Cascader、Calendar、CalendarView、DatetimePicker、PasswordInput、Keyboard、Signature、SlideVerify、Upload |
| 反馈 | Overlay、Loading、Popup、Dialog、ActionSheet、DropMenu、Popover、Tooltip、FloatingPanel、Progress、Circle、Toast、Notify、NoticeBar、SwipeAction、SortButton、Empty、CountDown、CountTo |
| 展示 | Tag、Badge、Avatar、Card、Grid、Collapse、Expand、Steps、Skeleton、Loadmore、Img、ImagePreview、Swiper、Table、Watermark、QrCode、Barcode、Curtain、ImgCropper、VideoPreview |

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
├── example/                         # 示例应用
└── test/                            # 单元测试
```

## 快速开始

在你的 Flutter 项目中引入依赖：

```yaml
dependencies:
  flutter_wot_ui:
    git:
      url: https://gitee.com/miaoaa66/flutter_wot_ui.git
      ref: master
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
if (ok == true) {
  // ...
}
```


## 常见问题 FAQ

| 问题 | 说明 |
| --- | --- |
| **忘记包 `WotConfigProvider`** | 组件仍会渲染但颜色回退浅色默认，主题不生效；务必在根部包裹。 |
| **文件/图片选择、视频播放** | 依赖 `file_picker` `video_player` 等插件，接入方需按对应插件要求配置对应平台权限。 |
| **深色模式** | 切换 `WotConfigProvider` 的 `wotTheme` 为 `WotThemeData.dark`，或传 `themeMode: ThemeMode.dark`。 |
| **自定义主题色** | 通过 `WotScheme.copyWithPrimary(...)` 一键换肤，再配合 `copyWith(...)` 逐项覆盖其它语义令牌；用 `WotThemeData.copyWith(scheme: myScheme)` 组装后传入 `WotConfigProvider`。 |

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


cd example
# 查看环境
flutter doctor
# 接受 Android 许可
flutter doctor --android-licenses
flutter pub get
flutter analyze
flutter test
flutter run


# 打包web
flutter build web --release
# 如果部署在子路径，例如 https://xxx.com/myapp/：
flutter build web --release --base-href /myapp/


# 打包android
flutter build apk --debug
flutter build apk --release
# 分架构，输出3个小包（推荐）
flutter build apk --release --split-per-abi
# 只打 arm64 APK
flutter build apk --release --target-platform android-arm64



```

## 许可证

本项目基于 **MIT License** 开源，版权所有 © 2026 miaoaa66，详见 [LICENSE](LICENSE)。