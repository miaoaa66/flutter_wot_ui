import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPicker 滚轮选择器示例页（对齐 wot wd-picker，命令式弹出）。
class WotPickerPage extends StatefulWidget {
  const WotPickerPage({super.key});

  @override
  State<WotPickerPage> createState() => _WotPickerPageState();
}

class _WotPickerPageState extends State<WotPickerPage> {
  List<Object?> _city = ['广州'];
  List<Object?> _region = ['浙江', '杭州'];
  bool _showCancel = true;

  Future<void> _pickSingle() async {
    final res = await WotPicker.show(
      context,
      columns: wotSingleColumn(['北京', '广州', '上海', '深圳']),
      values: _city,
      title: '选择城市',
      showCancel: _showCancel,
    );
    if (res != null) setState(() => _city = res);
  }

  Future<void> _pickRegion() async {
    final res = await WotPicker.show(
      context,
      columns: [
        wotOptions(['浙江', '广东']),
        wotOptions(['杭州', '宁波', '广州', '深圳']),
      ],
      values: _region,
      title: '选择地区',
    );
    if (res != null) setState(() => _region = res);
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotPicker 滚轮选择器',
      children: [
        demoSection('单列（WotPicker.show 命令式弹出）'),
        demoBlock('单列选择',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.tonal(onPressed: _pickSingle, child: const Text('选择城市')),
                const SizedBox(height: 8),
                Text('选中：$_city', style: const TextStyle(fontSize: 12)),
              ],
            )),
        demoSection('多列级联'),
        demoBlock('省/市两级',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.tonal(onPressed: _pickRegion, child: const Text('选择地区')),
                const SizedBox(height: 8),
                Text('选中：$_region', style: const TextStyle(fontSize: 12)),
              ],
            )),
        demoSection('顶部操作栏'),
        Row(children: [
          Flexible(
            child: FilledButton.tonal(
              onPressed: () => setState(() => _showCancel = !_showCancel),
              child: Text('showCancel: $_showCancel'),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        demoBlock('配置后重试上方按钮查看「取消」按钮显隐',
            Text('title / showCancel / onConfirm 等由 show 参数控制。', style: TextStyle(fontSize: 12, color: Colors.grey))),
      ],
    );
  }
}