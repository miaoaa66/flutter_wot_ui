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
    this.showWordLimit = false,
    this.onFocus,
    this.onBlur,
    this.prefix,
    this.suffix,
    this.autosize = false,
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

  /// 是否展示字数/限制数提示（需同时设置 [maxLength]）。
  final bool showWordLimit;

  /// 输入框聚焦时回调。
  final VoidCallback? onFocus;

  /// 输入框失焦时回调。
  final VoidCallback? onBlur;

  /// 前置内容插槽，优先于 [prefixIcon] 展示。
  final Widget? prefix;

  /// 后置内容插槽，展示在末位。
  final Widget? suffix;

  /// 多行输入是否随内容自动增高（minLines 为 [maxLines]，行数不设上限）。
  final bool autosize;

  @override
  State<_WotTextInput> createState() => _WotTextInputState();
}

class _WotTextInputState extends State<_WotTextInput> {
  late final TextEditingController _c;
  late final FocusNode _focusNode;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    _obscure = widget.password;
  }

  /// 聚焦/失焦状态变化时触发对应回调。
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
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
    _focusNode.dispose();
    _c.dispose();
    super.dispose();
  }

  /// 是否展示字数/限制数提示（需要 [maxLength] 且未禁用）。
  bool showWordLimitEnabled() =>
      widget.showWordLimit && widget.maxLength != null && widget.maxLength! > 0 && !widget.disabled;

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

    final Widget? prefix = widget.prefix ??
        (widget.prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 4),
                child: WotIcon(name: widget.prefixIcon, size: 16, color: scheme.iconAuxiliary),
              ));

    // 后置图标组，可同时展示密码/清除/后置图标/字数统计/自定义后缀。
    final List<Widget> suffixWidgets = [];
    if (widget.password) {
      suffixWidgets.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.disabled ? null : _togglePw,
        child: WotIcon(
          name: _obscure ? 'eye-close' : 'eye',
          size: 16,
          color: scheme.iconAuxiliary,
        ),
      ));
    }
    if (!widget.password && widget.suffixIcon != null) {
      suffixWidgets.add(WotIcon(name: widget.suffixIcon, size: 16, color: scheme.iconAuxiliary));
    }
    if (!widget.password && widget.suffixIcon == null && widget.clearable && _c.text.isNotEmpty) {
      suffixWidgets.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.disabled ? null : _clear,
        child: WotIcon(name: 'close-circle', size: 16, color: scheme.iconAuxiliary),
      ));
    }
    if (showWordLimitEnabled()) {
      suffixWidgets.add(Text(
        '${_c.text.characters.length}/${widget.maxLength}',
        style: TextStyle(fontSize: 12, color: scheme.textPlaceholder),
      ));
    }
    if (widget.suffix != null) {
      suffixWidgets.add(widget.suffix!);
    }

    final border = widget.decorated
        ? UnderlineInputBorder(borderSide: BorderSide(color: scheme.borderLight))
        : InputBorder.none;
    final focusBorder = widget.decorated
        ? UnderlineInputBorder(borderSide: BorderSide(color: scheme.primaryOf(6)))
        : InputBorder.none;

    final field = TextField(
      controller: _c,
      focusNode: _focusNode,
      enabled: !widget.disabled,
      readOnly: widget.readonly,
      obscureText: _obscure,
      maxLines: widget.autosize ? null : widget.maxLines,
      minLines: widget.autosize ? widget.maxLines : null,
      maxLength: widget.maxLength,
      keyboardType: widget.inputType,
      textAlign: TextAlign.left,
      onChanged: (v) {
        _pushValue(v);
        if (widget.clearable || showWordLimitEnabled()) setState(() {});
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

    if (prefix == null && suffixWidgets.isEmpty) return field;
    return Row(
      children: [
        ?prefix,
        Expanded(child: field),
        for (final s in suffixWidgets)
          Padding(padding: const EdgeInsets.only(left: 4), child: s),
      ],
    );
  }
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
    this.showWordLimit = false,
    this.onFocus,
    this.onBlur,
    this.prefix,
    this.suffix,
  });

  /// 表单字段名；传入后在 [WotFormScope] 中按该名称关联取值。
  final String? name;

  /// 输入值（受控，外部回填）。
  final String? value;

  /// 输入内容变化时回调。
  final ValueChanged<String>? onChange;

  /// 占位提示文本。
  final String? placeholder;

  /// 前置图标名称（wot icon 名称）。
  final String? prefixIcon;

  /// 后置图标名称（wot icon 名称）。
  final String? suffixIcon;

  /// 是否在可清空条件下显示清空按钮。
  final bool clearable;

  /// 点击清空按钮时回调。
  final VoidCallback? onClear;

  /// 是否作为密码框（显示密文并支持切换显隐）。
  final bool password;

  /// 是否禁用输入。
  final bool disabled;

  /// 是否只读（不可编辑但保留展示样式）。
  final bool readonly;

  /// 最大输入长度。
  final int? maxlength;

  /// 文本行数（多行时生效）。
  final int maxLines;

  /// 输入框类型（透传备用，当前未影响键盘类型）。
  final String? type;

  /// 是否使用数字键盘（允许小数）。
  final bool number;

  /// 是否展示字数/限制数提示（需同时设置 [maxlength]，禁用/只读时不展示）。
  final bool showWordLimit;

  /// 输入框聚焦时回调。
  final VoidCallback? onFocus;

  /// 输入框失焦时回调。
  final VoidCallback? onBlur;

  /// 前置内容插槽，可放置自定义图标/文案，优先于 [prefixIcon] 展示。
  final Widget? prefix;

  /// 后置内容插槽，可放置自定义图标/文案，展示在末位。
  final Widget? suffix;

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
      showWordLimit: showWordLimit,
      onFocus: onFocus,
      onBlur: onBlur,
      prefix: prefix,
      suffix: suffix,
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
    this.showWordLimit = false,
    this.onFocus,
    this.onBlur,
  });

  /// 表单字段名；传入后在 [WotFormScope] 中按该名称关联取值。
  final String? name;

  /// 输入值（受控，外部回填）。
  final String? value;

  /// 输入内容变化时回调。
  final ValueChanged<String>? onChange;

  /// 占位提示文本。
  final String? placeholder;

  /// 最大输入长度。
  final int? maxlength;

  /// 文本行数（决定高度）。
  final int rows;

  /// 是否禁用输入。
  final bool disabled;

  /// 是否只读（不可编辑但保留展示样式）。
  final bool readonly;

  /// 是否随内容自动调整高度（以 [rows] 为最小行数，高度随内容增高）。
  final bool autosize;

  /// 是否展示字数/限制数提示（需同时设置 [maxlength]，禁用/只读时不展示）。
  final bool showWordLimit;

  /// 输入框聚焦时回调。
  final VoidCallback? onFocus;

  /// 输入框失焦时回调。
  final VoidCallback? onBlur;

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
        showWordLimit: showWordLimit,
        onFocus: onFocus,
        onBlur: onBlur,
        autosize: autosize,
      ),
    );
  }
}