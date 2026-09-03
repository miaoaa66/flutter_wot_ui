import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 数字键盘，对应 wot `wd-keyboard`。为密码/支付输入提供软键盘。
///
/// 通过 [onKeypress] 回调数字键，[onDelete] 删除键，[onPressEnsure] 确定键。
class WotKeyboard extends StatelessWidget {
  const WotKeyboard({
    super.key,
    this.onKeypress,
    this.onDelete,
    this.onPressEnsure,
    this.title = '安全键盘',
    this.showTitle = false,
    this.ensureText = '完成',
    this.color,
    this.disabled = false,
  });

  final ValueChanged<String>? onKeypress;
  final VoidCallback? onDelete;
  final VoidCallback? onPressEnsure;
  final String title;
  final bool showTitle;
  final String ensureText;
  final Color? color;
  final bool disabled;

  void _fire(String k) {
    if (disabled) return;
    onKeypress?.call(k);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final primary = color ?? scheme.primaryOf(6);

    return Container(
      color: scheme.filledBottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(title,
                  style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
            ),
          _row(context, [
            _key(context, '1', () => _fire('1'), null),
            _key(context, '2', () => _fire('2'), null),
            _key(context, '3', () => _fire('3'), null),
          ]),
          _row(context, [
            _key(context, '4', () => _fire('4'), null),
            _key(context, '5', () => _fire('5'), null),
            _key(context, '6', () => _fire('6'), null),
          ]),
          _row(context, [
            _key(context, '7', () => _fire('7'), null),
            _key(context, '8', () => _fire('8'), null),
            _key(context, '9', () => _fire('9'), null),
          ]),
          _row(context, [
            _key(context, '.', () => _fire('.'), null),
            _key(context, '0', () => _fire('0'), null),
            _key(context, '', () => onDelete?.call(), Icons.backspace_outlined),
          ]),
          // 确定条。
          _row(context, [
            _key(context, ensureText, () => onPressEnsure?.call(), null, primary: primary),
            _key(context, '', () {}, null),
            _key(context, '', () {}, null),
          ]),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, List<Widget> keys) {
    final scheme = context.wotScheme;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0)
              Container(width: 0.5, color: scheme.borderLight),
            Expanded(child: keys[i]),
          ],
        ],
      ),
    );
  }

  Widget _key(BuildContext context, String label, VoidCallback onTap, IconData? icon,
      {Color? primary}) {
    final scheme = context.wotScheme;
    final bg = primary ??
        (icon != null ? scheme.filledStrong : scheme.filledContent);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : onTap,
      child: Container(
        color: bg,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 22, color: scheme.textMain)
            : Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: primary != null ? Colors.white : scheme.textMain,
                ),
              ),
      ),
    );
  }
}