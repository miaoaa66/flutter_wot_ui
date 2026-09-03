import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';
import '../icon/wot_icon.dart';

/// 文本基类：WotInput 与 WotTextarea 的公共实现（内部管理 [TextEditingController]）。
class _WotTextInput extends StatefulWidget {
  const _WotTextInput({
    required this.name,
    this.value,
    this.onChange,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.clearable = false,
    this.onClear,
    this.password = false,
    this.disabled = false,
    this.readonly = false,
    this.maxLength,
    this.maxLines = 1,
    this.inputType,
    this.decorated = true,
  });

  final String? name;
  final String? value;
  final ValueChanged<String>? onChange;
  final String? placeholder;
  final String? prefixIcon;
  final String? suffixIcon;
  final bool clearable;
  final VoidCallback? onClear;
  final bool password;
  final bool disabled;
  final bool readonly;
  final int? maxLength;
  final int maxLines;
  final TextInputType? inputType;

  /// 是否绘制下划线装饰（Textarea 场景传 false，由外层包装）。
  final bool decorated;

  @override
  State<_WotTextInput> createState() => _WotTextInputState();
}

class _WotTextInputState extends State<_WotTextInput> {
  late final TextEditingController _c;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.value ?? '');
    _obscure = widget.password;
  }

  @override
  void didUpdateWidget(_WotTextInput old) {
    super.didUpdateWidget(old);
    if (widget.value != null && widget.value != _c.text) {
      _c.value = _c.value.copyWith(text: widget.value, selection: _c.selection);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _togglePw() => setState(() => _obscure = !_obscure);

  void _clear() {
    _c.clear();
    widget.onClear?.call();
    _pushValue('');
    setState(() {});
  }

  /// 值变更时联动表单控制器（按 name 写入）。
  void _pushValue(String v) {
    widget.onChange?.call(v);
    final form = WotFormScope.of(context);
    if (widget.name != null && form != null) form.setValue(widget.name!, v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;

    final prefix = widget.prefixIcon == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(right: 4),
            child: WotIcon(name: widget.prefixIcon, size: 16, color: scheme.iconAuxiliary),
          );

    Widget? suffix;
    if (widget.password) {
      suffix = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.disabled ? null : _togglePw,
        child: WotIcon(
          name: _obscure ? 'eye-close' : 'eye',
          size: 16,
          color: scheme.iconAuxiliary,
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffix = WotIcon(name: widget.suffixIcon, size: 16, color: scheme.iconAuxiliary);
    } else if (widget.clearable && _c.text.isNotEmpty) {
      suffix = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.disabled ? null : _clear,
        child: WotIcon(name: 'close-circle', size: 16, color: scheme.iconAuxiliary),
      );
    }

    final border = widget.decorated
        ? UnderlineInputBorder(borderSide: BorderSide(color: scheme.borderLight))
        : InputBorder.none;
    final focusBorder = widget.decorated
        ? UnderlineInputBorder(borderSide: BorderSide(color: scheme.primaryOf(6)))
        : InputBorder.none;

    final field = TextField(
      controller: _c,
      enabled: !widget.disabled,
      readOnly: widget.readonly,
      obscureText: _obscure,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.inputType,
      textAlign: TextAlign.left,
      onChanged: (v) {
        _pushValue(v);
        if (widget.clearable && suffixIconGuard()) setState(() {});
      },
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: TextStyle(
        fontSize: 14,
        color: widget.disabled ? scheme.textDisabled : scheme.textMain,
      ),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(fontSize: 14, color: scheme.textPlaceholder),
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        border: border,
        enabledBorder: border,
        focusedBorder: focusBorder,
        disabledBorder: border,
      ),
    );

    if (prefix == null && suffix == null) return field;
    return Row(
      children: [
        ?prefix,
        Expanded(child: field),
        if (suffix != null) Padding(padding: const EdgeInsets.only(left: 4), child: suffix),
      ],
    );
  }

  bool suffixIconGuard() => widget.clearable && !widget.password && widget.suffixIcon == null;
}

/// 输入框，对应 wot `wd-input`。
class WotInput extends StatelessWidget {
  const WotInput({
    super.key,
    this.name,
    this.value,
    this.onChange,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.clearable = false,
    this.onClear,
    this.password = false,
    this.disabled = false,
    this.readonly = false,
    this.maxlength,
    this.maxLines = 1,
    this.type,
    this.number = false,
  });

  final String? name;
  final String? value;
  final ValueChanged<String>? onChange;
  final String? placeholder;
  final String? prefixIcon;
  final String? suffixIcon;
  final bool clearable;
  final VoidCallback? onClear;
  final bool password;
  final bool disabled;
  final bool readonly;
  final int? maxlength;
  final int maxLines;
  final String? type;
  final bool number;

  @override
  Widget build(BuildContext context) {
    return _WotTextInput(
      name: name,
      value: value,
      onChange: onChange,
      placeholder: placeholder,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      clearable: clearable,
      onClear: onClear,
      password: password,
      disabled: disabled,
      readonly: readonly,
      maxLength: maxlength,
      maxLines: maxLines,
      inputType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : (password ? TextInputType.visiblePassword : TextInputType.text),
    );
  }
}

/// 多行文本域，对应 wot `wd-textarea`。
class WotTextarea extends StatelessWidget {
  const WotTextarea({
    super.key,
    this.name,
    this.value,
    this.onChange,
    this.placeholder,
    this.maxlength,
    this.rows = 3,
    this.disabled = false,
    this.readonly = false,
    this.autosize = false,
  });

  final String? name;
  final String? value;
  final ValueChanged<String>? onChange;
  final String? placeholder;
  final int? maxlength;
  final int rows;
  final bool disabled;
  final bool readonly;
  final bool autosize;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.filledStrong,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _WotTextInput(
        name: name,
        value: value,
        onChange: onChange,
        placeholder: placeholder,
        maxLength: maxlength,
        maxLines: rows,
        disabled: disabled,
        readonly: readonly,
        decorated: false,
      ),
    );
  }
}