import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotForm + WotFormItem 表单示例页（含基础/校验/动态增删）。
class WotFormPage extends StatefulWidget {
  const WotFormPage({super.key});

  @override
  State<WotFormPage> createState() => _WotFormPageState();
}

class _WotFormPageState extends State<WotFormPage> {
  final GlobalKey<WotFormState> _formKey = GlobalKey();
  final GlobalKey<WotFormState> _dynamicKey = GlobalKey();

  // 动态表单：可增删的地址列表字段名与自增序号。
  final List<String> _addrKeys = ['addr_0'];
  int _addrSeq = 1;

  void _addAddr() => setState(() => _addrKeys.add('addr_${_addrSeq++}'));
  void _removeAddr(String key) => setState(() => _addrKeys.remove(key));

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotForm 表单',
      children: [
        demoSection('基础表单 + 校验（rules / required / showSubmitButton）'),
        demoBlock(
            '必填用户名 + 邮箱格式校验',
            WotForm(
              key: _formKey,
              rules: {
                'username': (v) => v != null && v.isNotEmpty,
                'email': (v) => v != null && v.contains('@'),
              },
              submitButtonText: '提交',
              showSubmitButton: true,
              onSubmit: (_) => demoToast(context, '校验通过，提交成功'),
              children: [
                WotFormItem(label: '用户名', name: 'username', required: true,
                    child: WotInput(name: 'username', placeholder: '请输入用户名', clearable: true)),
                WotFormItem(label: '邮箱', name: 'email', required: true,
                    child: WotInput(name: 'email', placeholder: '请输入邮箱', suffixIcon: 'message')),
                WotFormItem(label: '密码', name: 'password',
                    child: WotInput(name: 'password', password: true, placeholder: '请输入密码')),
              ],
            )),
        demoSection('命令式校验（GlobalKey<WotFormState>.validate / clearValidate）'),
        demoBlock(
            '点击按钮触发 validate()',
            Column(
              children: [
                WotForm(
                  key: _dynamicKey,
                  rules: {'nick': (v) => v != null && v.length >= 2},
                  submitButtonText: '',
                  showSubmitButton: false,
                  children: [
                    WotFormItem(label: '昵称', name: 'nick', required: true,
                        child: WotInput(name: 'nick', placeholder: '至少 2 个字', clearable: true)),
                  ],
                ),
                Row(children: [
                  FilledButton.tonal(onPressed: () => _dynamicKey.currentState?.validate(), child: const Text('validate')),
                  const SizedBox(width: 8),
                  FilledButton.tonal(onPressed: () => _dynamicKey.currentState?.clearValidate(), child: const Text('clearValidate')),
                ]),
              ],
            )),
        demoSection('WotFormItem 属性'),
        demoBlock('labelWidth（固定标签宽）+ border 开关',
            WotForm(
              showSubmitButton: false,
              children: [
                WotFormItem(label: '标签', name: 'a', labelWidth: 70,
                    child: WotInput(name: 'a', placeholder: 'labelWidth=70')),
                WotFormItem(label: '无边框', name: 'b', border: false,
                    child: WotInput(name: 'b', placeholder: 'border=false')),
                WotFormItem(label: '外部错误', name: 'c', errorMessage: '自定义错误文案',
                    child: WotInput(name: 'c', placeholder: 'errorMessage')),
              ],
            )),
        demoSection('动态表单（可增删地址行，均登记取值/校验）'),
        demoBlock(
            '动态增删字段',
            WotForm(
              rules: {'addr_0': (v) => v != null && v.isNotEmpty, 'addr_1': (v) => v != null && v.isNotEmpty, 'addr_2': (v) => v != null && v.isNotEmpty, 'addr_3': (v) => v != null && v.isNotEmpty},
              submitButtonText: '提交',
              showSubmitButton: true,
              onSubmit: (ctl) {
                final vals = _addrKeys
                    .map((k) => ctl.valueOf(k)?.isNotEmpty == true ? ctl.valueOf(k)! : '（空）')
                    .join('、');
                demoToast(context, '地址：$vals');
              },
              children: [
                _DynamicFields(keys: _addrKeys, onAdd: _addAddr, onRemove: _removeAddr),
              ],
            )),
      ],
    );
  }
}

/// 动态表单字段块：按 [keys] 渲染若干「地址」表单项，可增删。
class _DynamicFields extends StatelessWidget {
  const _DynamicFields({required this.keys, required this.onAdd, required this.onRemove});

  final List<String> keys;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final key in keys)
          WotFormItem(
            key: ValueKey(key),
            label: '地址',
            name: key,
            required: true,
            child: Row(
              children: [
                Expanded(child: WotInput(name: key, placeholder: '请输入地址', clearable: true)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '删除该地址',
                  icon: Icon(Icons.remove_circle_outline, size: 20, color: scheme.textDisabled),
                  onPressed: () => onRemove(key),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add_circle_outline, size: 20, color: scheme.primaryOf(6)),
          style: TextButton.styleFrom(foregroundColor: scheme.primaryOf(6), padding: const EdgeInsets.symmetric(horizontal: 4)),
          label: const Text('添加地址'),
        ),
      ],
    );
  }
}