import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 键盘模式。
enum WotKeyboardMode {
  /// 纯数字键盘（含小数点）。
  number,

  /// 身份证键盘（将小数点位置替换为「X」）。
  idcard,
}

/// 数字键盘，对应 wot `wd-keyboard`。为密码/支付输入提供软键盘。
///
/// 通过 [onKeypress] 回调数字键，[onDelete] 删除键，[onPressEnsure] / [onClose] 完成键。
class WotKeyboard extends StatefulWidget {
  const WotKeyboard({
    super.key,
    this.onKeypress,
    this.onDelete,
    this.onPressEnsure,
    this.onClose,
    this.title = '安全键盘',
    this.showTitle = false,
    this.ensureText = '完成',
    this.mode = WotKeyboardMode.number,
    this.randomOrder = false,
    this.loading = false,
    this.show = true,
    this.showDeleteKey = true,
    this.color,
    this.disabled = false,
  });

  /// 点击数字（含小数点）键时回调，参数为按键文本。
  final ValueChanged<String>? onKeypress;

  /// 点击删除键时回调。
  final VoidCallback? onDelete;

  /// 点击确定（完成）键时回调。
  final VoidCallback? onPressEnsure;

  /// 点击关闭（完成）键或遮罩关闭时回调。
  final VoidCallback? onClose;

  /// 标题文本；默认“安全键盘”，需 [showTitle] 为 true 时展示。
  final String title;

  /// 是否显示标题栏。
  final bool showTitle;

  /// 确定键文案；默认“完成”。
  final String ensureText;

  /// 键盘模式；`number` 常规数字键盘，`idcard` 身份证键盘（小数点换为 X）。
  final WotKeyboardMode mode;

  /// 是否随机排序数字按键（1-9），默认 false。
  final bool randomOrder;

  /// 确定键是否显示加载状态（期间不触发完成回调），默认 false。
  final bool loading;

  /// 是否展示键盘；为 false 时不渲染任何内容，默认 true。
  final bool show;

  /// 是否显示删除键，默认 true。
  final bool showDeleteKey;

  /// 确定键高亮色；不传时用主题主色。
  final Color? color;

  /// 是否禁用整个键盘（点击不触发任何回调）。
  final bool disabled;

  @override
  State<WotKeyboard> createState() => _WotKeyboardState();
}

class _WotKeyboardState extends State<WotKeyboard> {
  final Random _random = Random();
  late List<String> _digits;

  @override
  void initState() {
    super.initState();
    _digits = _buildDigits();
  }

  @override
  void didUpdateWidget(WotKeyboard old) {
    super.didUpdateWidget(old);
    if (old.randomOrder != widget.randomOrder) {
      _digits = _buildDigits();
    }
  }

  /// 生成 1-9 数字键；开启随机顺序时打乱顺序。
  List<String> _buildDigits() {
    final list = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    if (!widget.randomOrder) return list;
    return list..shuffle(_random);
  }

  /// 额外键（数字键盘为小数点，身份证键盘为 X）。
  String get _extraKey => widget.mode == WotKeyboardMode.idcard ? 'X' : '.';

  void _fire(String k) {
    if (widget.disabled) return;
    widget.onKeypress?.call(k);
  }

  void _fireDelete() {
    if (widget.disabled) return;
    widget.onDelete?.call();
  }

  void _fireEnsure() {
    if (widget.disabled || widget.loading) return;
    widget.onPressEnsure?.call();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    final scheme = context.wotScheme;
    final primary = widget.color ?? scheme.primaryOf(6);

    return Container(
      color: scheme.filledBottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(widget.title,
                  style: TextStyle(fontSize: 14, color: scheme.textSecondary)),
            ),
          _row(context, _keysForRow(0)),
          _row(context, _keysForRow(1)),
          _row(context, _keysForRow(2)),
          // 底部行：额外键 / 0 / 删除。
          _row(context, [
            _key(context, _extraKey, () => _fire(_extraKey), null),
            _key(context, '0', () => _fire('0'), null),
            if (widget.showDeleteKey)
              _key(context, '', _fireDelete, Icons.backspace_outlined)
            else
              _key(context, '', () {}, null),
          ]),
          // 确定条。
          _row(context, [
            _ensureKey(context, primary),
            _key(context, '', () {}, null),
            _key(context, '', () {}, null),
          ]),
        ],
      ),
    );
  }

  List<Widget> _keysForRow(int row) {
    return [
      _key(context, _digits[row * 3], () => _fire(_digits[row * 3]), null),
      _key(context, _digits[row * 3 + 1], () => _fire(_digits[row * 3 + 1]), null),
      _key(context, _digits[row * 3 + 2], () => _fire(_digits[row * 3 + 2]), null),
    ];
  }

  Widget _ensureKey(BuildContext context, Color primary) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _fireEnsure,
      child: Container(
        color: primary,
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.ensureText,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
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
            if (i > 0) Container(width: 0.5, color: scheme.borderLight),
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
      onTap: widget.disabled ? null : onTap,
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