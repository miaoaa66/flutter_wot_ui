# flutter_wot_ui

[English](README.md) | [简体中文](README.zh-CN.md)

A Flutter re-implementation of the **Wot UI** component library (uni-app version: https://wot-ui.cn/), built in pure Dart/Flutter, cross-platform (Web / Android / iOS / Windows / macOS / Linux).

- Semantic design tokens: Light / Dark themes out of the box, with every color customizable via `WotScheme.copyWith`.
- Naming and parameters aligned with wot: Vue props camelCased → Dart named constructor parameters; `emit` → `onXxx` callbacks.
- One directory per component with a single barrel export — highly cohesive, loosely coupled, easy to adopt.
- Minimal third-party dependencies; everything else is drawn from scratch.

> Open source repository: <https://gitee.com/miaoaa66/flutter_wot_ui>   
> Open source repository: <https://github.com/miaoaa66/flutter_wot_ui>   

---


## Notes

This library has only been tested and built for Web and Android; other platforms are untested.   
Not all properties of all components have been fully covered by tests.   
For integrating the library into a new Flutter project, see: <https://gitee.com/miaoaa66/flutter_wot_ui_demo>   
For integrating the library into a new Flutter project, see: <https://github.com/miaoaa66/flutter_wot_ui_demo>   

## Component List

Grouped by category (consistent with the wot docs structure):

| Category | Components |
| --- | --- |
| Basic | Button, Icon, Text, Row/Col, Cell, CellGroup, Gap, Divider, Fab, Transition, ConfigProvider, ThemeBtn |
| Navigation | Navbar, Tabbar, Tabs, Segmented, Sidebar, Pagination, IndexBar, Backtop, Tour |
| Form | Form, FormItem, Input, Textarea, Search, InputNumber, Checkbox, Radio, Switch, Rate, Slider, PickerView, Picker, SelectPicker, Cascader, Calendar, CalendarView, DatetimePicker, PasswordInput, Keyboard, Signature, SlideVerify, Upload |
| Feedback | Overlay, Loading, Popup, Dialog, ActionSheet, DropMenu, Popover, Tooltip, FloatingPanel, Progress, Circle, Toast, Notify, NoticeBar, SwipeAction, SortButton, Empty, CountDown, CountTo |
| Display | Tag, Badge, Avatar, Card, Grid, Collapse, Expand, Steps, Skeleton, Loadmore, Img, ImagePreview, Swiper, Table, Watermark, QrCode, Barcode, Curtain, ImgCropper, VideoPreview |

> Notes:
> - `Textarea` is implemented as `WotTextarea`, exported from the same file as `WotInput` (`lib/src/components/input/wot_input.dart`); it has no standalone directory.
> - `ThemeBtn` (light/dark theme toggle button) is an independently re-implemented component; its colors are hardcoded literals and do not follow the library theme.

## Directory Structure

```
flutter_wot_ui/
├── pubspec.yaml
├── lib/
│   ├── flutter_wot_ui.dart          # Single barrel export
│   └── src/
│       ├── theme/                   # Semantic token themes (Light/Dark + copyWith configurable)
│       ├── icon/                    # Icon name → IconData mapping
│       ├── util/                    # props / format / touch pure Dart utilities
│       └── components/              # One directory per component, with components.dart category exports
├── example/                         # Example app
└── test/                            # Unit tests
```

## Getting Started

Add the dependency in your Flutter project:

```yaml
dependencies:
  flutter_wot_ui:
    git:
      url: https://gitee.com/miaoaa66/flutter_wot_ui.git
      # url: https://github.com/miaoaa66/flutter_wot_ui.git
      ref: master
```

Then run `flutter pub get`.

Wrap your app root with `WotConfigProvider`; descendant widgets access semantic tokens via `context.wotScheme`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WotConfigProvider(
      wotTheme: WotThemeData.light, // Dark: WotThemeData.dark
      child: MaterialApp(
        home: const HomePage(),
      ),
    );
  }
}
```

Use components directly in your pages:

```dart
WotButton(
  text: 'Primary',
  type: WotButtonType.primary,
  onClick: () => WotToast.success(context, 'Button clicked'),
);
```

Imperative components (no widget-tree footprint):

```dart
WotToast.success(context, 'Operation succeeded');
final ok = await WotDialog.confirm(context, message: 'Delete this item?');
if (ok == true) {
  // ...
}
```


## FAQ

| Issue | Description |
| --- | --- |
| **Forgot to wrap with `WotConfigProvider`** | Components still render, but colors fall back to the light defaults and theming has no effect; always wrap at the root. |
| **File/image picking, video playback** | Depends on plugins such as `file_picker` and `video_player`; you must configure the required platform permissions for those plugins. |
| **Dark mode** | Switch `WotConfigProvider`'s `wotTheme` to `WotThemeData.dark`, or pass `themeMode: ThemeMode.dark`. |
| **Custom theme colors** | Use `WotScheme.copyWithPrimary(...)` for one-line re-theming, then `copyWith(...)` to override other semantic tokens individually; assemble with `WotThemeData.copyWith(scheme: myScheme)` and pass to `WotConfigProvider`. |

## Third-party Dependencies

| Package | Purpose | Platforms |
| --- | --- | --- |
| `intl` | Official date/number localization | All platforms |
| `qr_flutter` | QR code generation for WotQrCode (pure Dart) | All platforms |
| `barcode` | Barcode generation for WotBarcode (pure Dart) | All platforms |
| `file_picker` | File/image picking for WotUpload / WotImg | All platforms |
| `video_player` | Video playback for WotVideoPreview | All platforms |

> Icons: `WotIcon` renders using Flutter's built-in Material icon mapping by default; if you need the official wot glyphs, bundle your own `iconfont.ttf` and register it with `kWotIconFontFamily` (see `lib/src/components/icon/wot_icon.dart`).

## Local Development & Verification

```bash


cd example
# Check the environment
flutter doctor
# Accept Android licenses
flutter doctor --android-licenses
flutter pub get
flutter analyze
flutter test
flutter run


# Build for web
flutter build web --release
# If deploying under a sub-path, e.g. https://xxx.com/myapp/:
flutter build web --release --base-href /myapp/


# Build for Android
flutter build apk --debug
flutter build apk --release
# Split per ABI, outputs 3 smaller APKs (recommended)
flutter build apk --release --split-per-abi
# Build arm64-only APK
flutter build apk --release --target-platform android-arm64




```







## CI

A repository is created on Gitee; Gitee's repository mirroring feature syncs automatically to GitHub, which triggers GitHub Actions automatically.







## Development Environment & AI Assistance

- **Local environment:** Java 17.0.12, Flutter 3.41.4.
- **AI models involved:** The development of this project was assisted by the following AI models — deepseek-v4-flash, deepseek-v4-pro, seed-code, qwen-3.7-plus, glm-5.3-flash, hy3, hy4.

## License

This project is open sourced under the **MIT License**, Copyright © 2026 miaoaa66. See [LICENSE](LICENSE) for details.
