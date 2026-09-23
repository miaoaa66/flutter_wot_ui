import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/wot_state.dart';
import '../../locale/wot_messages.dart';
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
    this.error = false,
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

  /// 是否处于校验失败态（error 态）。命中时格子边框转危险色。
  final bool error;

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

class _WotPasswordInputState extends State<WotPasswordInput>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus;
  late final TextEditingController _controller;
  final GlobalKey<EditableTextState> _fieldKey = GlobalKey<EditableTextState>();
  String _value = '';

  /// 光标闪烁动画：聚焦时周期往复，模拟输入框光标闪动。
  late final AnimationController _blink;

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
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_onBlink);
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
    _blink
      ..removeListener(_onBlink)
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

  /// 光标闪烁一帧后通知重建，驱动 `'|'` 显隐。
  void _onBlink() {
    if (mounted) setState(() {});
  }

  void _tap() {
    if (widget.disabled || widget.readonly) return;
    if (_focus.hasFocus) {
      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
      if (keyboardVisible) {
        // 键盘在、点击已聚焦的格子：保持现状（对齐真实 TextField 行为）。
        return;
      }
      // 焦点残留而键盘已收起（didChangeDependencies 的 viewInsets 检测可能因
      // 设备差异/时序漏触发）：先释放焦点复位聚焦样式，下一帧重新取焦点并
      // 强制重连输入连接唤起键盘——保证「再点一次」必然能恢复输入。
      _focus.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focus.hasFocus) {
          _focus.requestFocus();
          _fieldKey.currentState?.requestKeyboard();
        }
      });
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

    // 三态：显式传参 > WotFieldScope 下发 > 默认。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final readonly = widget.readonly || (fieldScope?.state == WotFieldState.readonly);
    final hasError = widget.error || (fieldScope?.error ?? false);
    final style = wotFieldStyle(
      scheme,
      disabled ? WotFieldState.disabled : WotFieldState.editable,
      error: hasError,
      baseBorder: scheme.borderStrong,
    );
    // 锁定时不再显示聚焦光标态。
    final focus = _isFocused && !disabled && !readonly;
    // 光标闪烁：聚焦时周期往复，失焦/锁定即停并复位到可见。
    if (focus && !_blink.isAnimating) {
      _blink.repeat(reverse: true);
    } else if (!focus && _blink.isAnimating) {
      _blink.stop();
    }
    final cursorVisible = _blink.value >= 0.5;
    final mask = widget.maskable ?? widget.obscure;

    final field = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (disabled || readonly) ? null : _tap,
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
                  enabled: !disabled && !readonly,
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
                color: disabled ? style.background : null,
                border: Border.all(
                  color: (focus && i == _value.length)
                      ? (widget.focusColor ?? scheme.primaryOf(6))
                      : style.border,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: i < _value.length
                  ? (mask
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: style.text,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Text(
                          _value[i],
                          style: TextStyle(fontSize: 16, color: style.text),
                        ))
                  : Text(
                      i == _value.length && focus && cursorVisible ? '|' : '',
                      style: TextStyle(
                        fontSize: 16,
                        color: focus ? (widget.focusColor ?? scheme.primaryOf(6)) : style.border,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );

    // 无障碍：可见格子是自绘的，隐藏 TextField 不产生可读语义；
    // 读屏需要知道这是密码框、当前已输入几位（value 用纯数字避免语言问题）。
    return Semantics(
      label: tr(context, 'wot.passwordInput.field'),
      value: '${_value.length} / ${widget.maxLength}',
      onTap: (disabled || readonly) ? null : _tap,
      child: field,
    );
  }
}
