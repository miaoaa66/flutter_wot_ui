import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSelectPicker 选择器示例页。
class WotSelectPickerPage extends StatefulWidget {
  const WotSelectPickerPage({super.key});

  @override
  State<WotSelectPickerPage> createState() => _WotSelectPickerPageState();
}

class _WotSelectPickerPageState extends State<WotSelectPickerPage> {
  List<Object?> _city = ['广州'];
  List<Object?> _provinceCity = ['浙江', '杭州'];
  List<Object?> _empty = [];
  bool _disabled = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSelectPicker 选择器',
      children: [
        demoSection('基础（columns 单列 / modelValue 受控回显）'),
        demoBlock('单列选择',
            WotSelectPicker(
              columns: wotSingleColumn(['北京', '广州', '上海', '深圳']),
              modelValue: _city,
              onChange: (v) => setState(() => _city = v),
            )),
        demoSection('多列级联（columns 多列 / 标题）'),
        demoBlock(
            '省/市两级联动 + title',
            WotSelectPicker(
              columns: [
                wotOptions(['浙江', '广东']),
                wotOptions(['杭州', '宁波', '广州', '深圳']),
              ],
              modelValue: _provinceCity,
              title: '请选择地区',
              onChange: (v) => setState(() => _provinceCity = v),
            )),
        demoSection('占位与空值'),
        demoBlock('placeholder 占位（未选择）',
            WotSelectPicker(columns: wotSingleColumn(['北京', '广州']), modelValue: _empty, placeholder: '点击选择城市', onChange: (v) => setState(() => _empty = v))),
        demoSection('状态（disabled / loading）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
          const SizedBox(width: 8),
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _loading = !_loading), child: Text('loading: $_loading'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotSelectPicker(columns: wotSingleColumn(['北京']), modelValue: _city, disabled: _disabled, onChange: (v) => setState(() => _city = v))),
        demoBlock('loading 加载中', WotSelectPicker(columns: wotSingleColumn(['北京']), modelValue: _city, loading: _loading, onChange: (v) => setState(() => _city = v))),
      ],
    );
  }
}