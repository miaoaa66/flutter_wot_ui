import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/wot_theme.dart';

/// 密码输入框，对应 wot `wd-password-input`。
///
/// 相比 [WotInput]，本组件绘制密码点阵（`●`），不显示明文；受控（v-model:value）。
class WotPasswordInput extends StatefulWidget {
  const WotPasswordInput({
    super.key,
    this.modelValue = '',
    this.onChange,
    this.onInput,
    this.onFocus,
    this.onBlur,
    this.maxLength = 6,
    this.focusColor,
    this.disabled = false,
    this.readonly = false,
    this.gutter = 8,
    this.obscure = true,
    this.maskable,
    this.focused,
  });

  /// 当前已输入的密码值（受控，v-model:value）。
  final String modelValue;

  /// 密码值变化时回调。
  final ValueChanged<String>? onChange;

  /// 每输入一个字符后回调，参数为新的完整值（含满位时的触发）。
  final ValueChanged<String>? onInput;

  /// 输入框获得焦点时回调（点击格子弹起键盘）。
  final VoidCallback? onFocus;

  /// 输入框失去焦点时回调。
  final VoidCallback? onBlur;

  /// 密码位数（格子数量），对应 wot 的 `length`；默认 6。
  final int maxLength;

  /// 聚焦时格子边框颜色；不传时用主题主色。
  final Color? focusColor;

  /// 是否禁用（不可聚焦输入）。
  final bool disabled;

  /// 是否只读（不可聚焦输入）。
  final bool readonly;

  /// 格子之间的间距（逻辑像素）；默认 8。
  final double gutter;

  /// 是否用密点（●）遮罩已输入内容；为 false 时明文展示。
  final bool obscure;

  /// 是否遮罩已输入内容（密点）；显式设置时覆盖 [obscure]。
  final bool? maskable;

  /// 受控聚焦状态；显式传入时作为聚焦态来源，否则取内部焦点。
  final bool? focused;

  @override
  State<WotPasswordInput> createState() => _WotPasswordInputState();
}

class _WotPasswordInputState extends State<WotPasswordInput> {
  late final FocusNode _focus;
  String _value = '';

  /// 内部 / 受控聚焦态。
  bool get _isFocused => widget.focused ?? _focus.hasFocus;

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue;
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(WotPasswordInput old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) _value = widget.modelValue;
    // 受控聚焦态变化时同步硬件焦点。
    if (widget.focused != null && old.focused != widget.focused) {
      if (widget.focused!) {
        _focus.requestFocus();
      } else {
        _focus.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focused != null) return;
    setState(() {});
    if (_focus.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  void _tap() {
    if (widget.disabled || widget.readonly) return;
    _focus.requestFocus();
    widget.onFocus?.call();
  }

  /// 处理物理/软键盘按键：输入字符或退格，并回调解密变化。
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.disabled || widget.readonly) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final character = event.character;
    if (character == null || character.isEmpty) return KeyEventResult.ignored;

    final handled = character == '\b' || character.runes.length == 1;
    if (character == '\b') {
      if (_value.isNotEmpty) {
        setState(() => _value = _value.substring(0, _value.length - 1));
        widget.onChange?.call(_value);
      }
      return KeyEventResult.handled;
    }
    if (_value.length >= widget.maxLength) return KeyEventResult.handled;
    setState(() => _value = _value + character);
    widget.onChange?.call(_value);
    widget.onInput?.call(_value);
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final focus = _isFocused;
    final borderColor = focus
        ? (widget.focusColor ?? scheme.primaryOf(6))
        : scheme.borderStrong;
    final mask = widget.maskable ?? widget.obscure;

    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
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
                  border: Border.all(
                    color: (focus && i == _value.length)
                        ? (widget.focusColor ?? scheme.primaryOf(6))
                        : borderColor,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: i < _value.length
                    ? (mask
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
      ),
    );
  }
}