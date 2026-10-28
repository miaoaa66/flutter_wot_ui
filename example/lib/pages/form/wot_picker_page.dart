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

  /// 以三态打开弹层，演示弹层内部的锁交互效果。
  Future<void> _openWithState({bool disabled = false, bool readonly = false}) {
    return WotPicker.show(
      context,
      columns: wotSingleColumn(['北京', '广州', '上海', '深圳']),
      values: _city,
      title: disabled ? 'disabled 弹层' : 'readonly 弹层',
      disabled: disabled,
      readonly: readonly,
    );
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

  /// optionBuilder 插槽：命令式入口同样支持自定义选项渲染。
  Future<void> _pickWithBuilder() async {
    final res = await WotPicker.show(
      context,
      columns: [wotOptions(['北京', '广州', '上海', '深圳'])],
      values: _city,
      title: '自定义渲染',
      optionBuilder: (context, option, selected) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(option.text),
        ],
      ),
    );
    if (res != null) setState(() => _city = res);
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
        demoSection('选项自定义渲染插槽（optionBuilder）'),
        demoBlock(
            'optionBuilder：选项自定义为「图标 + 文案」；命令式入口 WotPicker.show 与'
            '内联 widget 均可传入，选中药丸/滚轮手感仍由组件统一处理',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.tonal(onPressed: _pickWithBuilder, child: const Text('自定义渲染选择')),
                const SizedBox(height: 8),
                Text('选中：$_city', style: const TextStyle(fontSize: 12)),
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
        demoSection('三态（disabled / readonly —— 作用于弹层内部交互）'),
        demoBlock(
            '弹层没有「显示区」，三态应施加在调用方的触发区；这里演示弹层内部的锁交互差异：'
            'disabled = 锁滚轮 + 整体淡化；readonly = 锁滚轮 + 配色不变',
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.tonal(
                onPressed: () => _openWithState(disabled: true),
                child: const Text('打开 disabled 弹层'),
              ),
              FilledButton.tonal(
                onPressed: () => _openWithState(readonly: true),
                child: const Text('打开 readonly 弹层'),
              ),
            ])),
      ],
    );
  }
}