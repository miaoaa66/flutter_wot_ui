import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 录入 form 组件演示页。
class WotFormPage extends StatefulWidget {
  const WotFormPage({super.key});

  @override
  State<WotFormPage> createState() => _WotFormPageState();
}

class _WotFormPageState extends State<WotFormPage> {
  final _formKey = GlobalKey<WotFormState>();
  bool _agree = true;
  Object? _radio = 1;
  bool _switchOn = false;
  int _rate = 3;
  double _slider = 60;
  num _qty = 1;
  DateTime? _date;
  DateTime? _datetime;
  String _pw = '';

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('录入组件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('WotForm 表单 + WotFormItem + WotInput'),
          WotForm(
            key: _formKey,
            rules: {
              'username': (v) => v != null && v.isNotEmpty,
              'email': (v) => v != null && v.contains('@'),
            },
            submitButtonText: '提交',
            showSubmitButton: true,
            onSubmit: (_) => _toast('表单校验通过'),
            children: [
              WotFormItem(label: '用户名', name: 'username', required: true, child: WotInput(name: 'username', placeholder: '请输入用户名', clearable: true)),
              WotFormItem(label: '邮箱', name: 'email', required: true, child: WotInput(name: 'email', placeholder: '请输入邮箱', suffixIcon: 'message')),
              WotFormItem(label: '密码', name: 'password', child: WotInput(name: 'password', password: true, placeholder: '请输入密码')),
              WotFormItem(label: '多行', name: 'desc', child: WotTextarea(name: 'desc', placeholder: '请输入描述')),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotInputNumber / WotSearch'),
          WotInputNumber(
            modelValue: _qty,
            onChange: (v) => setState(() => _qty = v),
          ),
          const SizedBox(height: 12),
          WotSearch(
            modelValue: '搜索示例',
            showAction: true,
            onSearch: () => _toast('搜索'),
          ),
          const SizedBox(height: 20),
          _section('WotCheckbox / Group + WotRadio + WotSwitch'),
          WotCheckbox(label: '单选框', modelValue: _agree, onChange: (v) => setState(() => _agree = v)),
          const SizedBox(height: 8),
          WotRadioGroup(
            modelValue: _radio,
            onChange: (v) => setState(() => _radio = v),
            options: const [
              WotRadioOption(label: '选项一', value: 1),
              WotRadioOption(label: '选项二', value: 2),
              WotRadioOption(label: '禁用', value: 3, disabled: true),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('开关', style: TextStyle(fontSize: 14)),
              const Spacer(),
              WotSwitch(modelValue: _switchOn, onChange: (v) => setState(() => _switchOn = v)),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotRate / WotSlider'),
          WotRate(modelValue: _rate, onChange: (v) => setState(() => _rate = v)),
          const SizedBox(height: 8),
          WotSlider(modelValue: _slider, onChange: (v) => setState(() => _slider = v.toDouble())),
          const SizedBox(height: 20),
          _section('WotSelectPicker / WotCascader / 日历 / 日期时间'),
          WotSelectPicker(
            columns: wotSingleColumn(['北京', '广州', '上海']),
            modelValue: ['广州'],
            onChange: (v) => _toast('选择：$v'),
          ),
          const SizedBox(height: 12),
          WotCascader(
            options: [
              WotCascadeOption(text: '浙江', value: 'zj', children: [
                WotCascadeOption(text: '杭州', value: 'hz'),
                WotCascadeOption(text: '宁波', value: 'nb'),
              ]),
              WotCascadeOption(text: '广东', value: 'gd', children: [
                WotCascadeOption(text: '广州', value: 'gz'),
                WotCascadeOption(text: '深圳', value: 'sz'),
              ]),
            ],
            onChange: (v) => _toast('级联选择：$v'),
          ),
          const SizedBox(height: 12),
          WotButton(
            text: _date == null ? '选择日期' : '日期：${_date!.toIso8601String().split('T').first}',
            size: WotButtonSize.small,
            onClick: () async {
              final d = await WotCalendar.show(context);
              if (d != null) setState(() => _date = d);
            },
          ),
          const SizedBox(height: 8),
          WotButton(
            text: _datetime == null ? '选择日期时间' : '日期时间：${_datetime!.toIso8601String().substring(0, 16)}',
            size: WotButtonSize.small,
            onClick: () async {
              final d = await WotDatetimePicker.show(context, type: WotDatetimePickerType.datetime);
              if (d != null) setState(() => _datetime = d);
            },
          ),
          const SizedBox(height: 20),
          _section('WotPasswordInput / WotSlideVerify'),
          WotPasswordInput(modelValue: _pw, onChange: (v) => setState(() => _pw = v)),
          const SizedBox(height: 12),
          WotSlideVerify(onChange: (v) => _toast(v ? '验证通过' : '未到终点')),
          const SizedBox(height: 20),
          _section('WotSignature 手写签名'),
          WotSignature(height: 160),
          const SizedBox(height: 20),
          _section('WotUpload（内置 file_picker 选文件）'),
          WotUpload(
            maxCount: 3,
            onChange: (_) => _toast('已更新文件列表'),
          ),
          const SizedBox(height: 20),
          _section('WotKeyboard 数字键盘（联动密码输入）'),
          WotKeyboard(
            onKeypress: (k) {
              if (_pw.length >= 6) return;
              setState(() => _pw += k);
            },
            onDelete: () => setState(() => _pw = _pw.isEmpty ? _pw : _pw.substring(0, _pw.length - 1)),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(title, type: WotTextType.secondary, strong: true),
    );
  }
}