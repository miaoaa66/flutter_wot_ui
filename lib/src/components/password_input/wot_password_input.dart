import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 密码输入框，对应 wot `wd-password-input`。
///
/// 相比 [WotInput]，本组件绘制密码点阵（`●`），不显示明文；受控（v-model:value）。
class WotPasswordInput extends StatefulWidget {
  const WotPasswordInput({
    super.key,
    this.modelValue = '',
    this.onChange,
    this.maxLength = 6,
    this.focusColor,
    this.disabled = false,
    this.readonly = false,
    this.gutter = 8,
    this.obscure = true,
  });

  final String modelValue;
  final ValueChanged<String>? onChange;
  final int maxLength;
  final Color? focusColor;
  final bool disabled;
  final bool readonly;
  final double gutter;
  final bool obscure;

  @override
  State<WotPasswordInput> createState() => _WotPasswordInputState();
}

class _WotPasswordInputState extends State<WotPasswordInput> {
  late final FocusNode _focus;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue;
    _focus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(WotPasswordInput old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _value = widget.modelValue;
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.disabled || widget.readonly) return;
    _focus.requestFocus();
    // 模拟键盘：无原生键盘时由外部物理/软键盘输入；web/桌面可用键盘。
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final focus = _focus.hasFocus;
    final borderColor = focus
        ? (widget.focusColor ?? scheme.primaryOf(6))
        : scheme.borderStrong;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.maxLength; i++) ...[
              if (i > 0) SizedBox(width: widget.gutter),
              Container(
                width: 40,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: i < _value.length
                    ? (widget.obscure
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: scheme.textMain,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Text(
                            _value[i],
                            style: TextStyle(fontSize: 16, color: scheme.textMain),
                          ))
                    : Text(
                        i == _value.length && focus ? '|' : '',
                        style: TextStyle(fontSize: 16, color: borderColor),
                      ),
              ),
            ],
          ],
        ),
    );
  }
}