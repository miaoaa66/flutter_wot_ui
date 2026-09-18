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
  late final TextEditingController _controller;
  final GlobalKey<EditableTextState> _fieldKey = GlobalKey<EditableTextState>();
  String _value = '';

  /// 上一帧键盘可见高度，用于探测「键盘被系统收起」。
  double _lastViewInsets = 0;

  /// 内部 / 受控聚焦态。
  bool get _isFocused => widget.focused ?? _focus.hasFocus;

  @override
  void initState() {
    super.initState();
    _value = widget.modelValue;
    _focus = FocusNode()..addListener(_onFocusChange);
    _controller = TextEditingController(text: widget.modelValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final wasVisible = _lastViewInsets > 0;
    final visible = insets > 0;
    _lastViewInsets = insets;
    // 系统返回/手势收起键盘不会释放 FocusNode（hasFocus 仍为 true），
    // 聚焦样式会残留、且后续 requestFocus 成为 no-op 导致键盘唤不起。
    // 故键盘从可见转隐藏且仍持焦点时主动失焦，复位样式并让下次点击可重新唤起。
    if (wasVisible && !visible && _focus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focus.hasFocus) _focus.unfocus();
      });
    }
  }

  @override
  void didUpdateWidget(WotPasswordInput old) {
    super.didUpdateWidget(old);
    if (old.modelValue != widget.modelValue) {
      _value = widget.modelValue;
      if (_controller.text != widget.modelValue) {
        _controller.text = widget.modelValue;
      }
    }
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
    _controller.dispose();
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
    if (_focus.hasFocus) {
      // 已持焦点时 requestFocus 是 no-op（键盘收起后点击框弹不出键盘的场景），
      // 直接重连输入连接唤起键盘，对齐真实 TextField 的 onTap 行为。
      _fieldKey.currentState?.requestKeyboard();
    } else {
      _focus.requestFocus();
    }
  }

  void _onChanged(String text) {
    if (widget.disabled || widget.readonly) return;
    // 只保留数字/字符，截断到 maxLength。
    final clamped = text.length > widget.maxLength ? text.substring(0, widget.maxLength) : text;
    setState(() => _value = clamped);
    // 同步 controller 避免不一致。
    if (_controller.text != clamped) {
      _controller.text = clamped;
    }
    widget.onChange?.call(clamped);
    widget.onInput?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final focus = _isFocused;
    final mask = widget.maskable ?? widget.obscure;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 隐藏的 TextField，用于唤起软键盘和接收输入。
          SizedBox(
            width: 0,
            height: 0,
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  key: _fieldKey,
                  controller: _controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.number,
                  enabled: !widget.disabled && !widget.readonly,
                  maxLength: widget.maxLength,
                  onChanged: _onChanged,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(widget.maxLength),
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 1),
                ),
              ),
            ),
          ),
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
                      : scheme.borderStrong,
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
                      style: TextStyle(
                        fontSize: 16,
                        color: focus
                            ? (widget.focusColor ?? scheme.primaryOf(6))
                            : scheme.borderStrong,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
