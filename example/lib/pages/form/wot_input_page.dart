import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotInput / WotTextarea 示例页（尽量展示各属性）。
class WotInputPage extends StatefulWidget {
  const WotInputPage({super.key});

  @override
  State<WotInputPage> createState() => _WotInputPageState();
}

class _WotInputPageState extends State<WotInputPage> {
  String _v1 = '';
  String _v2 = '预设值';
  bool _disabled = false;
  bool _readonly = false;
  String? _taText;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotInput 输入框',
      children: [
        demoSection('基础用法（value / placeholder / onChange）'),
        demoBlock('受控 value + placeholder',
            WotInput(value: _v1, placeholder: '请输入', onChange: (v) => setState(() => _v1 = v))),
        demoBlock('预设 value', WotInput(value: _v2, onChange: (v) => setState(() => _v2 = v))),
        demoBlock('number 数字键盘（支持小数）',
            WotInput(placeholder: '请输入数字', number: true)),
        demoBlock('type 透传类型 + maxLines 多行',
            WotInput(placeholder: '多行输入', type: 'textarea', maxLines: 3)),
        demoSection('键盘类型（type，A 类死参数 #4 已实现）'),
        demoBlock(
            '原先 type 只是摆在注释里，完全不影响键盘。现已映射为 TextInputType：'
            'number→小数数字盘、digit→纯数字、tel→电话盘、email→邮箱盘、url→网址盘。'
            '移动端聚焦即可验证，桌面端看不出来属正常',
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final e in <(String, String)>[
                  ('number', 'number：小数数字盘'),
                  ('digit', 'digit：纯数字'),
                  ('tel', 'tel：电话盘'),
                  ('email', 'email：邮箱盘'),
                  ('url', 'url：网址盘'),
                  ('text', 'text：普通文本'),
                ])
                  SizedBox(
                    width: 200,
                    child: WotInput(placeholder: e.$2, type: e.$1),
                  ),
              ],
            )),
        demoBlock('number:true 等价于 type:number（允许小数）',
            const WotInput(placeholder: 'number: true', number: true)),
        demoBlock('对照：不传 type（默认键盘）——与 text 应一致',
            const WotInput(placeholder: '默认键盘')),

        demoSection('前后缀（prefixIcon / suffixIcon / prefix / suffix 插槽）'),
        demoBlock('图标前后缀',
            WotInput(value: _v2, prefixIcon: 'search', suffixIcon: 'close', onChange: (v) => setState(() => _v2 = v))),
        demoBlock('Widget 插槽前后缀',
            WotInput(placeholder: '重量', prefix: const Text('重量：'), suffix: const Text('kg'))),
        demoSection('清除 / 字数 / 密码'),
        demoBlock(
            'clearable（可清除，触发 onClear）',
            WotInput(
              value: _v2,
              clearable: true,
              onClear: () => demoToast(context, '已清除'),
              onChange: (v) => setState(() => _v2 = v),
            )),
        demoBlock('showWordLimit + maxlength',
            WotInput(value: _v1, clearable: true, maxlength: 10, showWordLimit: true, onChange: (v) => setState(() => _v1 = v))),
        demoBlock('password 密码输入', WotInput(placeholder: '输入密码', password: true)),
        demoSection('三态语义（editable / readonly / disabled / error）'),
        demoBlock(
            '三态对照：editable 可编辑（有下划线）→ readonly 只读（无下划线、字色正常，'
            '内容有效可读）→ disabled 禁用（浅灰底 + 灰字 + 保留下划线）。关键：只有 disabled 才灰化',
            const Column(children: [
              WotInput(value: '可编辑的值', placeholder: '请输入'),
              SizedBox(height: 14),
              WotInput(value: '只读的值：内容有效，保持正常字色、仅去掉下划线', readonly: true),
              SizedBox(height: 14),
              WotInput(value: '禁用的值：整体灰化', disabled: true),
            ])),
        demoBlock('error 校验失败（下划线转红，聚焦也保持红）',
            const WotInput(value: '格式不正确', error: true)),
        Row(children: [
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _disabled = !_disabled), child: Text('disabled: $_disabled'))),
          const SizedBox(width: 8),
          Flexible(child: FilledButton.tonal(onPressed: () => setState(() => _readonly = !_readonly), child: Text('readonly: $_readonly'))),
        ]),
        const SizedBox(height: 8),
        demoBlock('disabled 现场切换（同一实例，当前 $_disabled）',
            WotInput(value: '禁用的值', placeholder: '禁用', disabled: _disabled)),
        demoBlock('readonly 现场切换（同一实例，当前 $_readonly）',
            WotInput(value: '只读的值', placeholder: '只读', readonly: _readonly)),
        demoSection('事件回调（onFocus / onBlur）'),
        demoBlock('聚焦 / 失焦',
            WotInput(placeholder: '点击聚焦', onFocus: () => demoToast(context, '聚焦'), onBlur: () => demoToast(context, '失焦'))),
        demoSection('WotTextarea 多行文本域'),
        demoBlock(
            '基础（rows / placeholder）',
            WotTextarea(
              value: _taText,
              placeholder: '请输入备注',
              rows: 3,
              onChange: (v) => setState(() => _taText = v),
            )),
        demoBlock('autosize 随内容增高 + 字数限制',
            WotTextarea(placeholder: '自动增高', autosize: true, maxlength: 100, showWordLimit: true)),
        demoBlock('disabled 禁用（浅灰底 + 灰字）',
            const WotTextarea(value: '禁用文本域', disabled: true)),
        demoBlock('readonly 只读（白底、正常字色，区别于 disabled）',
            const WotTextarea(value: '只读文本域：内容有效可读', readonly: true)),
        demoBlock('error 校验失败（描红边）',
            const WotTextarea(value: '校验失败的文本', error: true)),
      ],
    );
  }
}