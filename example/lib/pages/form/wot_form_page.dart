import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotForm + WotFormItem 表单示例页。
///
/// 覆盖：校验时机（进入页面不报错 / 提交后报错）、自定义错误消息、
/// validateTrigger、model 初始值、reset、单字段校验、errorType、
/// FormItem 属性、动态增删字段。
class WotFormPage extends StatefulWidget {
  const WotFormPage({super.key});

  @override
  State<WotFormPage> createState() => _WotFormPageState();
}

class _WotFormPageState extends State<WotFormPage> {
  final GlobalKey<WotFormState> _basicKey = GlobalKey();
  final GlobalKey<WotFormState> _imperativeKey = GlobalKey();
  final GlobalKey<WotFormState> _propKey = GlobalKey();

  // 动态表单：可增删的地址列表字段名与自增序号。
  final List<String> _addrKeys = ['addr_0'];
  int _addrSeq = 1;

  /// 当前校验结果（用于演示 errorType: none 时自行处理错误）。
  String _lastResult = '（尚未校验）';

  void _addAddr() => setState(() => _addrKeys.add('addr_${_addrSeq++}'));
  void _removeAddr(String key) => setState(() => _addrKeys.remove(key));

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotForm 表单',
      children: [
        demoSection('校验时机：进入页面不报错，提交后才报错'),
        demoBlock(
            'required 的空值提示只在校验触发后出现',
            WotForm(
              key: _basicKey,
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
                    child: WotInput(name: 'password', password: true, placeholder: '非必填，无规则')),
              ],
            )),

        demoSection('命令式校验（validate / clearValidate / reset）'),
        Column(
          children: [
            WotForm(
              key: _imperativeKey,
              model: const {'nick': '初始昵称'},
              rules: {'nick': (v) => v != null && v.toString().length >= 2},
              children: [
                WotFormItem(label: '昵称', name: 'nick', required: true,
                    child: WotInput(name: 'nick', placeholder: '至少 2 个字', clearable: true)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    final err = _imperativeKey.currentState?.validate();
                    demoToast(context, err == null ? '校验通过' : '首个错误：$err');
                  },
                  child: const Text('validate()'),
                ),
                FilledButton.tonal(
                  onPressed: () => _imperativeKey.currentState?.clearValidate(),
                  child: const Text('clearValidate()'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    _imperativeKey.currentState?.reset();
                    demoToast(context, '已回到 model 初始值');
                  },
                  child: const Text('reset()'),
                ),
              ],
            ),
          ],
        ),

        demoSection('单字段校验 validate(prop)'),
        Column(
          children: [
            WotForm(
              key: _propKey,
              rules: {
                'account': (v) => (v?.toString().isNotEmpty ?? false) ? null : '账号不能为空',
                'age': (v) {
                  final n = num.tryParse(v?.toString() ?? '');
                  if (n == null) return '年龄必须是数字';
                  if (n < 0 || n > 150) return '年龄应在 0-150 之间';
                  return null;
                },
              },
              children: [
                WotFormItem(label: '账号', name: 'account', required: true,
                    child: WotInput(name: 'account', placeholder: '请输入账号')),
                WotFormItem(label: '年龄', name: 'age',
                    child: WotInput(name: 'age', placeholder: '0-150')),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    final err = _propKey.currentState?.validate('account');
                    demoToast(context, err ?? '账号通过');
                  },
                  child: const Text('只校验 account'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    final err = _propKey.currentState?.validate('age');
                    demoToast(context, err ?? '年龄通过');
                  },
                  child: const Text('只校验 age'),
                ),
              ],
            ),
          ],
        ),

        demoSection('自定义错误消息 + 值变化即校验'),
        demoBlock(
            '规则返回字符串即自定义提示；validateTrigger: {change}',
            WotForm(
              rules: {
                // 返回字符串 → 用该字符串作为错误提示
                'phone': (v) {
                  final s = v?.toString() ?? '';
                  if (s.isEmpty) return '手机号不能为空';
                  if (s.length != 11) return '手机号应为 11 位，当前 ${s.length} 位';
                  return null;
                },
              },
              validateTrigger: const {WotFormTrigger.change},
              errorType: WotFormErrorType.message,
              children: [
                WotFormItem(label: '手机号', name: 'phone', required: true,
                    child: WotInput(name: 'phone', placeholder: '输入时即时校验')),
              ],
            )),

        demoSection('errorType: none（错误由调用方自行处理）'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WotForm(
              rules: {'code': (v) => (v?.toString().length ?? 0) >= 6 ? null : '至少 6 位'},
              errorType: WotFormErrorType.none,
              onError: (errors) => setState(() => _lastResult = '校验失败：$errors'),
              onSubmit: (ctl) {
                setState(() => _lastResult = '校验通过：${ctl.values}');
                demoToast(context, '提交成功');
              },
              submitButtonText: '提交',
              showSubmitButton: true,
              children: [
                WotFormItem(label: '邀请码', name: 'code', required: true,
                    child: WotInput(name: 'code', placeholder: '至少 6 位，错误不内联展示')),
              ],
            ),
            const SizedBox(height: 6),
            Text('onError 回调结果：$_lastResult',
                style: const TextStyle(fontSize: 12)),
          ],
        ),

        demoSection('初始数据（model）'),
        demoBlock(
            'model 预填，支持非字符串值（switch 的 bool）',
            WotForm(
              model: const {'city': '上海', 'agree': true},
              onSubmit: (ctl) => demoToast(context, '提交：${ctl.values}'),
              submitButtonText: '提交',
              showSubmitButton: true,
              children: [
                WotFormItem(label: '城市', name: 'city',
                    child: WotInput(name: 'city', placeholder: '请输入城市')),
                WotFormItem(label: '同意条款', name: 'agree',
                    child: WotSwitch(name: 'agree', modelValue: true)),
                WotFormItem(label: '评分', name: 'score',
                    child: WotRate(name: 'score', modelValue: 3)),
              ],
            )),

        demoSection('WotFormItem 属性'),
        demoBlock('labelWidth / border / errorMessage / clickable + isLink',
            WotForm(
              showSubmitButton: false,
              children: [
                WotFormItem(label: '标签', name: 'a', labelWidth: 70,
                    child: WotInput(name: 'a', placeholder: 'labelWidth=70')),
                WotFormItem(label: '无边框', name: 'b', border: false,
                    child: WotInput(name: 'b', placeholder: 'border=false')),
                WotFormItem(label: '外部错误', name: 'c', errorMessage: 'errorMessage 始终展示',
                    child: WotInput(name: 'c', placeholder: 'errorMessage')),
                WotFormItem(
                  label: '可点击跳转',
                  name: 'd',
                  clickable: true,
                  isLink: true,
                  onTap: () => demoToast(context, '点击了整行'),
                  child: WotInput(name: 'd', placeholder: 'clickable + isLink'),
                ),
              ],
            )),

        demoSection('动态表单（可增删地址行，均登记取值/校验）'),
        demoBlock(
            '动态增删字段',
            WotForm(
              rules: {
                for (final k in _addrKeys) k: (v) => v != null && v.toString().isNotEmpty,
              },
              submitButtonText: '提交',
              showSubmitButton: true,
              onSubmit: (ctl) {
                final vals = _addrKeys
                    .map((k) {
                      final v = ctl.valueOf(k);
                      return (v is String && v.isNotEmpty) ? v : '（空）';
                    })
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
