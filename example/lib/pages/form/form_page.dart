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
  num _qtyStep = 0;
  List<Object?> _likes = [
    1
  ];
  List<Object?> _hobbies = const [
    2
  ];
  double _sliderStep = 40;
  num _rangeLow = 20;
  num _rangeHigh = 80;
  int _rateHalf = 2;
  int _rateCustom = 5;
  bool _switchText = false;
  bool _switchAsync = false;
  bool _loading = false;
  List<DateTime> _calMulti = [];
  List<DateTime> _calRange = [];
  DateTime? _datetimeRange;

  // 动态表单：可增删的地址列表字段名与自增序号。
  final List<String> _addrKeys = ['addr_0'];
  int _addrSeq = 1;

  /// 新增一个动态地址字段。
  void _addAddr() => setState(() => _addrKeys.add('addr_${_addrSeq++}'));

  /// 移除指定动态地址字段。
  void _removeAddr(String key) => setState(() => _addrKeys.remove(key));

  String _fmtDay(DateTime d) => d.toIso8601String().split('T').first;

  String _fmtDays(List<DateTime> list) =>
      list.map(_fmtDay).join(', ');

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
            onSubmit: (ctl) {
              // 动态字段的值也随表单一起被登记，这里按 key 读取展示。
              final addrVals = _addrKeys
                  .map((k) => ctl.valueOf(k)?.isNotEmpty == true ? ctl.valueOf(k)! : '（空）')
                  .join('、');
              _toast('表单校验通过，地址：$addrVals');
            },
            children: [
              WotFormItem(label: '用户名', name: 'username', required: true, child: WotInput(name: 'username', placeholder: '请输入用户名', clearable: true)),
              WotFormItem(label: '邮箱', name: 'email', required: true, child: WotInput(name: 'email', placeholder: '请输入邮箱', suffixIcon: 'message')),
              WotFormItem(label: '密码', name: 'password', child: WotInput(name: 'password', password: true, placeholder: '请输入密码')),
              WotFormItem(label: '多行', name: 'desc', child: WotTextarea(name: 'desc', placeholder: '请输入描述')),
              // 动态表单：可任意增删地址行，均登记在同名 name 下参与取值/校验。
              _DynamicFields(
                keys: _addrKeys,
                onAdd: _addAddr,
                onRemove: _removeAddr,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotInput / WotTextarea 增强'),
          WotInput(placeholder: '字数统计（maxlength 60）', maxlength: 60, showWordLimit: true, clearable: true),
          const SizedBox(height: 8),
          WotInput(
            placeholder: '前后缀内容插槽',
            prefix: const Text('重量'),
            suffix: const Text('kg'),
          ),
          const SizedBox(height: 8),
          WotInput(placeholder: '聚焦/失焦回调', onFocus: () => _toast('输入框聚焦'), onBlur: () => _toast('输入框失焦')),
          const SizedBox(height: 8),
          WotTextarea(
            placeholder: '多行文本（autosize 随内容自动增高）',
            rows: 2,
            autosize: true,
            maxlength: 100,
            showWordLimit: true,
          ),
          const SizedBox(height: 20),
          _section('WotInputNumber / WotSearch'),
          WotInputNumber(
            modelValue: _qty,
            onChange: (v) => setState(() => _qty = v),
          ),
          const SizedBox(height: 12),
          WotInputNumber(
            modelValue: _qtyStep,
            min: 0,
            max: 10,
            step: 0.1,
            precision: 2,
            onChange: (v) => setState(() => _qtyStep = v),
          ),
          const SizedBox(height: 4),
          const Text('步长 0.1，范围 0~10，保留 2 位小数', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          WotSearch(
            modelValue: '搜索示例',
            showAction: true,
            onSearch: () => _toast('搜索'),
            onFocus: () => _toast('搜索框聚焦'),
            onBlur: () => _toast('搜索框失焦'),
            onClear: () => _toast('已清空'),
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
          WotCheckboxGroup(
            modelValue: _hobbies,
            shape: 'circle',
            onChange: (v) => setState(() => _hobbies = v),
            options: const [
              WotCheckboxOption(label: '圆形一', value: 1),
              WotCheckboxOption(label: '圆形二', value: 2),
              WotCheckboxOption(label: '圆形三', value: 3),
            ],
          ),
          const SizedBox(height: 8),
          WotCheckboxGroup(
            modelValue: _likes,
            min: 1,
            max: 2,
            onChange: (v) => setState(() => _likes = v),
            options: const [
              WotCheckboxOption(label: '最多选 2', value: 1),
              WotCheckboxOption(label: '最少选 1', value: 2),
              WotCheckboxOption(label: '三', value: 3),
            ],
          ),
          const SizedBox(height: 8),
          WotRadioGroup(
            modelValue: _radio,
            shape: 'square',
            disabled: true,
            onChange: (v) => setState(() => _radio = v),
            options: const [
              WotRadioOption(label: '方形整组禁用', value: 1),
              WotRadioOption(label: '二', value: 2),
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('文字开关', style: TextStyle(fontSize: 14)),
              const Spacer(),
              WotSwitch(
                modelValue: _switchText,
                activeText: '开',
                inactiveText: '关',
                onChange: (v) => setState(() => _switchText = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('加载中开关', style: TextStyle(fontSize: 14)),
              const Spacer(),
              WotSwitch(
                modelValue: _switchAsync,
                loading: _loading,
                activeText: '开',
                inactiveText: '关',
                onChange: (v) {
                  setState(() => _loading = true);
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    if (!mounted) return;
                    setState(() {
                      _switchAsync = v;
                      _loading = false;
                    });
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotRate / WotSlider'),
          WotRate(modelValue: _rate, onChange: (v) => setState(() => _rate = v)),
          const SizedBox(height: 8),
          WotRate(
            modelValue: _rateHalf,
            allowHalf: true,
            onChange: (v) => setState(() => _rateHalf = v),
          ),
          const SizedBox(height: 4),
          const Text('半星评分（allowHalf）', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          WotRate(
            modelValue: _rateCustom,
            count: 6,
            activeIcon: Icons.favorite,
            icon: Icons.favorite_border,
            onChange: (v) => setState(() => _rateCustom = v),
          ),
          const SizedBox(height: 4),
          const Text('自定义图标 + 数量 6', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          WotSlider(modelValue: _slider, onChange: (v) => setState(() => _slider = v.toDouble())),
          const SizedBox(height: 8),
          WotSlider(
            modelValue: _sliderStep,
            min: 0,
            max: 100,
            step: 10,
            showTip: true,
            showValueInThumb: true,
            onChange: (v) => setState(() => _sliderStep = v.toDouble()),
          ),
          const SizedBox(height: 4),
          const Text('步长 10 + 值气泡（showTip） + 圆点内显示数值', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          WotSlider(
            modelValue: _rangeHigh,
            range: true,
            valueStart: _rangeLow,
            step: 5,
            showTip: true,
            showMinMax: true,
            showValueInThumb: true,
            onChangeRange: (v) => setState(() {
              _rangeLow = v.first;
              _rangeHigh = v.last;
            }),
          ),
          const SizedBox(height: 4),
          const Text('区间选择（range）+ 两端值 + 圆点内显示数值', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
          const SizedBox(height: 8),
          WotButton(
            text: _datetimeRange == null ? '选择受限日期' : '受限：${_datetimeRange!.toIso8601String().split('T').first}',
            size: WotButtonSize.small,
            onClick: () async {
              final now = DateTime.now();
              final d = await WotDatetimePicker.show(
                context,
                type: WotDatetimePickerType.date,
                minDate: DateTime(now.year, 1, 1),
                maxDate: DateTime(now.year, 12, 31),
              );
              if (d != null && mounted) setState(() => _datetimeRange = d);
            },
          ),
          const SizedBox(height: 8),
          WotButton(
            text: _calMulti.isEmpty ? '多选日期' : '多选：${_fmtDays(_calMulti)}',
            size: WotButtonSize.small,
            onClick: () async {
              final r = await showModalBottomSheet<Object>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                builder: (_) => WotCalendar(
                  type: WotCalendarType.multiple,
                  title: '多选日期',
                  onConfirm: (v) => _toast('多选结果：${_fmtDays((v as List).cast<DateTime>())}'),
                ),
              );
              if (r != null && mounted) {
                setState(() => _calMulti = (r as List).cast<DateTime>());
              }
            },
          ),
          const SizedBox(height: 8),
          WotButton(
            text: _calRange.isEmpty ? '区间日期' : '区间：${_fmtDays(_calRange)}',
            size: WotButtonSize.small,
            onClick: () async {
              final r = await showModalBottomSheet<Object>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                builder: (_) => WotCalendar(
                  type: WotCalendarType.range,
                  title: '区间日期',
                  onConfirm: (v) => _toast('区间结果：${_fmtDays((v as List).cast<DateTime>())}'),
                ),
              );
              if (r != null && mounted) {
                setState(() => _calRange = (r as List).cast<DateTime>());
              }
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
      child: WotText(title, type: WotTextType.wotDefault, bold: true),
    );
  }
}

/// 动态表单字段块：按 [keys] 渲染若干「地址」表单项，可增删。
/// 每个字段以 `name` 登记到所在 [WotForm] 作用域，参与取值与校验。
class _DynamicFields extends StatelessWidget {
  const _DynamicFields({
    required this.keys,
    required this.onAdd,
    required this.onRemove,
  });

  /// 当前字段名列表。
  final List<String> keys;

  /// 点击「添加」回调。
  final VoidCallback onAdd;

  /// 点击某一行「删除」回调（参数为字段名）。
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final key in keys)
          WotFormItem(
            // 以字段名为 key，保证增删时对应 item 正确挂载/卸载（卸载会自动 unregister）。
            key: ValueKey(key),
            label: '地址',
            name: key,
            required: true,
            child: Row(
              children: [
                Expanded(
                  child: WotInput(name: key, placeholder: '请输入地址', clearable: true),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '删除该地址',
                  icon: Icon(Icons.remove_circle_outline,
                      size: 20, color: scheme.textDisabled),
                  onPressed: () => onRemove(key),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add_circle_outline, size: 20, color: scheme.primaryOf(6)),
          style: TextButton.styleFrom(
            foregroundColor: scheme.primaryOf(6),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          label: const Text('添加地址'),
        ),
      ],
    );
  }
}