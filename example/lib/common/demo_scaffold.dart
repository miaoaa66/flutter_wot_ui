import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 组件示例脚手架：统一的 `Scaffold + AppBar + ListView`，
/// 各组件演示页只需提供 `children`（用 [demoSection] / [demoBlock] 拼装）。
class WotDemoScaffold extends StatelessWidget {
  const WotDemoScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  /// 页面标题（AppBar）。
  final String title;

  /// 页面内容块集合（建议由 [demoSection] / [demoBlock] 组成）。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}

/// 区块标题（加粗），用于给某组件的一类属性做分组。
Widget demoSection(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 8),
    child: WotText(text, type: WotTextType.wotDefault, bold: true),
  );
}

/// 属性演示块：上方灰色小字 `label`（属性名/说明），下方圆角边框容器内放 `child`。
/// 让「每个属性一类」的演示结构清晰统一；`child` 请尽量撑满宽度。
Widget demoBlock(String label, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // color: Colors.black.withValues(alpha: 0.03),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    ),
  );
}

/// 轻提示（复用各页反馈）。
void demoToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)));
}

/// 把值格式化为整数不带小数的展示（供文案类 demo 提示）。
String demoNum(num v) {
  final d = v.toDouble();
  return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toString();
}