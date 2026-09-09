import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotSelectPicker 列表选择器示例页（对齐 wot wd-select-picker）。
class WotSelectPickerPage extends StatefulWidget {
  const WotSelectPickerPage({super.key});

  @override
  State<WotSelectPickerPage> createState() => _WotSelectPickerPageState();
}

class _WotSelectPickerPageState extends State<WotSelectPickerPage> {
  Object? _fruit; // 单选（value）
  List<Object?> _hobby = []; // 多选（value 列表）
  Object? _city;
  List<Object?> _limit = ['篮球'];
  Object? _confirm;
  Object? _auto;
  Object? _objVal;
  bool _disabled = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotSelectPicker 列表选择器',
      children: [
        demoSection('基础（type=radio，columns 传简单值数组）'),
        demoBlock('单选（radio，showConfirm=true）',
            WotSelectPicker(
              type: 'radio',
              columns: ['苹果', '香蕉', '橙子'],
              modelValue: _fruit,
              placeholder: '请选择水果',
              onChange: (v) => setState(() => _fruit = v),
            )),
        demoSection('多选（type=checkbox，值为 List<Object?>）'),
        demoBlock('多选（checkbox，可清除）',
            WotSelectPicker(
              type: 'checkbox',
              columns: [
                WotSelectPickerOption(label: '篮球', value: '篮球'),
                WotSelectPickerOption(label: '足球', value: '足球'),
                WotSelectPickerOption(label: '羽毛球', value: '羽毛球'),
                WotSelectPickerOption(label: '乒乓球（禁用）', value: '乒乓球', disabled: true),
              ],
              modelValue: _hobby,
              placeholder: '请选择爱好',
              showConfirm: true,
              onChange: (v) => setState(() => _hobby = (v is List) ? v : []),
            )),
        demoSection('可搜索（filterable）'),
        demoBlock('filterable 单选可搜索',
            WotSelectPicker(
              type: 'radio',
              filterable: true,
              columns: ['北京市', '上海市', '广州市', '深圳市', '杭州市', '南京市'],
              modelValue: _city,
              placeholder: '搜索选择城市',
              onChange: (v) => setState(() => _city = v),
            )),
        demoSection('选择数量限制（min / max）'),
        demoBlock('多选 max=3 min=1',
            WotSelectPicker(
              type: 'checkbox',
              columns: ['篮球', '足球', '羽毛球', '游泳', '跑步'],
              modelValue: _limit,
              min: 1,
              max: 3,
              placeholder: '请选择（1~3 项）',
              onChange: (v) => setState(() => _limit = (v is List) ? v : [])),
            ),
        demoSection('确认前校验（before-confirm）'),
        demoBlock('before-confirm：选「选项二」则拒绝确认',
            WotSelectPicker(
              type: 'radio',
              columns: ['选项一', '选项二', '选项三'],
              modelValue: _confirm,
              placeholder: '点击选择（选"选项二"会拒绝确认）',
              beforeConfirm: (v) async {
                if (v == '选项二') {
                  demoToast(context, '选项二不可选！');
                  return false;
                }
                return true;
              },
              onChange: (v) => setState(() => _confirm = v),
            )),
        demoSection('单选自动回填（showConfirm=false）'),
        demoBlock('showConfirm=false：点击即选中关闭',
            WotSelectPicker(
              type: 'radio',
              showConfirm: false,
              columns: ['选项A', '选项B', '选项C'],
              modelValue: _auto,
              placeholder: '点击即选中',
              onChange: (v) => setState(() => _auto = v),
            )),
        demoSection('对象选项 + value-key / label-key'),
        demoBlock('Map options（valueKey/labelKey）',
            WotSelectPicker(
              type: 'radio',
              columns: [
                {'id': 1, 'name': '北京'},
                {'id': 2, 'name': '上海'},
                {'id': 3, 'name': '广州'},
              ],
              valueKey: 'id',
              labelKey: 'name',
              modelValue: _objVal,
              placeholder: '选择城市（值存 id）',
              onChange: (v) => setState(() => _objVal = v),
            )),
        demoSection('状态（disabled / loading / clearable）'),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
          const SizedBox(width: 8),
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _loading = !_loading), child: Text('loading: $_loading'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 禁用', WotSelectPicker(type: 'radio', modelValue: _fruit, columns: ['苹果'], disabled: _disabled)),
        demoBlock('loading 加载态弹层', WotSelectPicker(type: 'radio', modelValue: _fruit, columns: ['苹果'], loading: _loading)),
        demoBlock('clearable=false 不可清除', WotSelectPicker(type: 'radio', modelValue: _fruit, columns: ['苹果'], clearable: false)),
      ],
    );
  }
}