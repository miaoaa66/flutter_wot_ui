import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPickerView 滚轮视图示例页（对齐 wot wd-picker-view，仅展示滚轮区本身）。
class WotPickerViewPage extends StatefulWidget {
  const WotPickerViewPage({super.key});

  @override
  State<WotPickerViewPage> createState() => _WotPickerViewPageState();
}

class _WotPickerViewPageState extends State<WotPickerViewPage> {
  List<Object?> _single = ['选项2'];
  List<Object?> _multi = ['中南大学', '软件工程'];
  List<Object?> _withDisabled = ['选项1'];

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotPickerView 滚轮视图',
      children: [
        demoSection('单列（仅滚轮区，不包含弹层/操作栏）'),
        demoBlock('单列选择',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  child: WotPickerView(
                    columns: [wotOptions(['选项1', '选项2', '选项3', '选项4', '选项5', '选项6'])],
                    values: _single,
                    height: 180,
                    onChange: (v) => setState(() => _single = v),
                  ),
                ),
                const SizedBox(height: 8),
                Text('当前：$_single', style: const TextStyle(fontSize: 12)),
              ],
            )),
        demoBlock('禁选项（disabled）',
            SizedBox(
              height: 160,
              child: WotPickerView(
                columns: [
                  [
                    WotColumnOption(text: '选项1', value: '选项1'),
                    WotColumnOption(text: '选项2(禁用)', value: '选项2', disabled: true),
                    WotColumnOption(text: '选项3', value: '选项3'),
                    WotColumnOption(text: '选项4(禁用)', value: '选项4', disabled: true),
                    WotColumnOption(text: '选项5', value: '选项5'),
                  ],
                ],
                values: _withDisabled,
                height: 160,
                onChange: (v) => setState(() => _withDisabled = v),
              ),
            )),
        demoSection('多列'),
        demoBlock('两列联动（columns 二维数组）',
            SizedBox(
              height: 180,
              child: WotPickerView(
                columns: [
                  wotOptions(['中山大学', '中南大学', '华南理工大学']),
                  wotOptions(['计算机', '软件工程', '通信工程', '法学']),
                ],
                values: _multi,
                height: 180,
                onChange: (v) => setState(() => _multi = v),
              ),
            )),
        demoBlock('多列示意',
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('当前：$_multi', style: const TextStyle(fontSize: 12)),
            )),
      ],
    );
  }
}