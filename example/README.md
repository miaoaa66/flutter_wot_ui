# flutter_wot_ui_example

`flutter_wot_ui` 的示例应用，展示组件库各组件的能力与接入方式。

> 本页即「新项目快速接入指南」。若你是要在自己的新 Flutter 项目中引入该组件库，请直接参考下方
> [从零接入 flutter_wot_ui](#-从零接入-flutter_wot_ui)。

---

## 一、从零接入 flutter_wot_ui

以下步骤假设你已有一个 Flutter 项目（`flutter create my_app`）。

### 1. 在 `pubspec.yaml` 引入依赖

组件库计划发布到开源仓库 `https://gitee.com/miaoaa66/flutter_wot_ui`，可走 Git 依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_wot_ui:
    git:
      url: https://gitee.com/miaoaa66/flutter_wot_ui.git
      ref: main        # 可选：指定分支/tag/commit
      path: flutter_wot_ui   # 仓库内组件包所在目录
```

> 若组件库尚未推送远程或你想本地联调，也可用本地路径依赖：
> ```yaml
>   flutter_wot_ui:
>     path: ../flutter_wot_ui
> ```

然后执行：

```bash
flutter pub get
```

### 2. 用 `WotConfigProvider` 包裹应用根节点

组件库的样式通过 `context.wotScheme` 语义令牌下发，必须在 `MaterialApp` 外层（或内层）套一个
`WotConfigProvider`，否则组件会回退到浅色默认主题。

```dart
import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WotConfigProvider(
      // 深色模式也可：改传 WotThemeData.dark
      wotTheme: WotThemeData.light,
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData.light(), // 可选，仅影响原生 Material 观感
        home: const HomePage(),
      ),
    );
  }
}
```

### 3. 页面里直接使用组件

```dart
import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 1;
  bool _sw = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 按钮：type/size/variant/round/block/loading 等属性
          WotButton(
            text: '主按钮',
            type: WotButtonType.primary,
            onClick: () => WotToast.success(context, '点击了按钮'),
          ),
          const SizedBox(height: 16),
          // 数字步进 / 开关 / 单选等录入组件
          WotInputNumber(
            modelValue: _count,
            onChange: (v) => setState(() => _count = v),
          ),
          WotSwitch(
            modelValue: _sw,
            onChange: (v) => setState(() => _sw = v),
          ),
        ],
      ),
    );
  }
}
```

### 4. 命令式组件（不占 widget 树）

Toast / Dialog / ActionSheet / Notify 等通过静态方法触发，需要传入 `BuildContext`：

```dart
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

// 轻提示
WotToast.success(context, '操作成功');
WotToast.loading(context, '加载中…');

// 确认对话框
final ok = await WotDialog.confirm(context, title: '提示', message: '确认删除吗？');
if (ok == true) {
  // ...
}
```

---

## 二、常见问题 FAQ

| 问题 | 说明 |
| --- | --- |
| **忘记包 `WotConfigProvider`** | 组件仍会渲染但颜色回退浅色默认，主题不生效；务必在根部包裹。 |
| **图标形态** | 组件库默认用 Flutter 内置 Material 图标映射渲染 `WotIcon`，开箱即用无需资产。若想获得与 wot 一致的官方字形，可按 [`kWotIconFontFamily`](file:///f:/3project/project_template/flutter_template_dev/flutter_ui/flutter_wot_ui/lib/src/components/icon/wot_icon.dart) 说明，自行打包 wot 的 `iconfont.ttf` 并注册字体族。 |
| **文件/图片选择、视频播放** | 依赖 `file_picker` `video_player` 等插件，接入方需按对应插件要求配置对应平台权限。 |
| **深色模式** | 切换 `WotConfigProvider` 的 `wotTheme` 为 `WotThemeData.dark`，或传 `themeMode: ThemeMode.dark`。 |
| **自定义主题色** | 通过 `WotScheme.copyWithPrimary(...)` 一键换肤，再配合 `copyWith(...)` 逐项覆盖其它语义令牌；用 `WotThemeData.copyWith(scheme: myScheme)` 组装后传入 `WotConfigProvider`。 |

---

## 三、本地开发说明

- 运行示例：`flutter run -d chrome`（或其它设备）。
- 索引页 `lib/pages/index_page.dart` 按 基础/导航/录入/反馈/展示 分组列出全部组件入口。
- 单测：`flutter test`（含各页面“渲染 + 滚动无溢出”冒烟）。

---

## Getting Started (Flutter 模板残留说明)

本目录由 `flutter create` 生成。除上述接入说明外，标准 Flutter 模板的默认内容对本项目无实际作用，
请以本 README 第一节「从零接入」为准。