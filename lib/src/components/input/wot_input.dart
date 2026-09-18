import 'dart:async';

// defaultTargetPlatform 定义在 foundation.dart，material.dart 不会导出它。
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// TextInputFormatter / FilteringTextInputFormatter 定义在 services.dart，
// material.dart 不会导出它们，必须显式引入。
import 'package:flutter/services.dart';

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
    this.controller,
    this.focusNode,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
    this.textInputAction,
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

  /// 外部文本控制器；传入后由调用方持有与销毁，组件不再内部创建。
  ///
  /// **传入 [controller] 后 [value] 仅作为初始值，后续外部回填不再生效**——
  /// controller 即唯一数据源，避免「外部改 controller → 组件用旧 value 覆盖」的回弹。
  final TextEditingController? controller;

  /// 外部焦点节点；传入后由调用方销毁，组件只挂/摘 listener。
  final FocusNode? focusNode;

  /// 输入格式化器（如 `FilteringTextInputFormatter.digitsOnly`）。
  final List<TextInputFormatter>? inputFormatters;

  /// 是否自动聚焦，默认 false。
  final bool autofocus;

  /// 提交（键盘完成键）回调。
  final ValueChanged<String>? onSubmitted;

  /// 键盘动作按钮类型；与 [onSubmitted] 配合使用。
  final TextInputAction? textInputAction;

  @override
  State<_WotTextInput> createState() => _WotTextInputState();
}

class _WotTextInputState extends State<_WotTextInput> {
  late final TextEditingController _c;
  late final FocusNode _focusNode;

  /// 是否由本组件创建（决定 dispose 时是否销毁——外部传入的对象不能代管）。
  late final bool _ownsController;
  late final bool _ownsFocusNode;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _c = widget.controller ?? TextEditingController(text: widget.value ?? '');
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    // 外部直接改 controller.text 时（不经过键盘输入），onChanged 不会触发，
    // 清空按钮与字数统计会停在旧值——这里补一个监听保证它们同步。
    _c.addListener(_handleControllerChange);
    _obscure = widget.password;
  }

  /// 聚焦/失焦状态变化时触发对应回调。
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _ensureKeyboardVisible();
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  /// 获得焦点后补发「弹出软键盘」请求（仅 Android）。
  ///
  /// **这是 Android 系统输入法的坑，不是本组件的逻辑问题**：华为 / 荣耀 / 小米 /
  /// OPPO 等机型的系统设置里默认开启「安全输入 / 安全键盘」，密码框
  /// （`obscureText: true`，如 `WotInput(password: true)`）被聚焦时，系统会把输入法
  /// 切换到内置安全键盘。这次输入法切换会**吞掉 Flutter 引擎在聚焦瞬间发出的首次
  /// `showSoftInput`**，于是表现为：
  /// 第一次点击输入框时「已经有聚焦样式（下划线高亮 + 光标）但键盘不弹出」，
  /// 必须再点一次才出现；一页有多个输入框、来回切换焦点时同样容易触发。
  /// 参见 flutter/flutter#68571、flutter/flutter#160582（均为开放中的框架问题）。
  ///
  /// 兜底做法：焦点落到本框后先在**下一帧**补发一次 `TextInput.show`；考虑到输入法
  /// 切换可能慢于一帧、首帧补发仍被吞掉，再在 160ms 后补一次。两次都以「本框仍持有
  /// 焦点」为前提，键盘已正常弹出时该调用是幂等的（平台侧对已显示的软键盘无副作用），
  /// 因此不会造成重复弹出或闪烁。仅 Android 生效，不影响 iOS / 桌面 / Web 既有行为。
  void _ensureKeyboardVisible() {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    void retry() {
      if (!mounted || !_focusNode.hasFocus) return;
      // 静态 `TextInput.show()` 在新版本 Flutter 中已移除，这里走原始通道；
      // 引擎侧仍是同一个 'TextInput.show' 处理器（等价于 TextInputConnection.show()）。
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => retry());
    Future<void>.delayed(const Duration(milliseconds: 160), retry);
  }

  /// 文本被程序化修改时刷新依赖 [TextEditingController.text] 的后置区。
  void _handleControllerChange() {
    if (!mounted) return;
    if (widget.clearable || showWordLimitEnabled()) setState(() {});
  }

  @override
  void didUpdateWidget(_WotTextInput old) {
    super.didUpdateWidget(old);
    // 外部持有 controller 时不再用 value 回填——controller 是唯一数据源，
    // 否则「外部改 controller」会被旧 value 覆盖回去。
    if (!_ownsController) return;
    if (widget.value != null && widget.value != _c.text) {
      _c.value = _c.value.copyWith(text: widget.value, selection: _c.selection);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_handleControllerChange);
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _c.dispose();
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
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
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
    this.controller,
    this.focusNode,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
    this.textInputAction,
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

  /// 输入框类型，对应 wot `type`。可选 `text` / `number` / `digit` / `tel` / `email` / `url` / `password`。
  ///
  /// 会映射为 [TextInputType]；显式传入 [inputType] 时以 [inputType] 为准。
  final String? type;

  /// [type] → [TextInputType] 映射；未识别的类型返回 null（保持默认键盘）。
  static TextInputType? _keyboardTypeOf(String? type) {
    switch (type) {
      case 'number':
        return const TextInputType.numberWithOptions(decimal: true);
      case 'digit':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'text':
      case 'password':
        return TextInputType.text;
      default:
        return null;
    }
  }

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

  /// 外部文本控制器；**传入后由调用方持有与销毁**，且 [value] 仅作为初始值，
  /// 后续外部回填不再生效（controller 即唯一数据源）。
  final TextEditingController? controller;

  /// 外部焦点节点；传入后由调用方销毁。
  final FocusNode? focusNode;

  /// 输入格式化器，如 `FilteringTextInputFormatter.digitsOnly`。
  final List<TextInputFormatter>? inputFormatters;

  /// 是否自动聚焦，默认 false。
  final bool autofocus;

  /// 提交（键盘完成键）回调。
  final ValueChanged<String>? onSubmitted;

  /// 键盘动作按钮类型，与 [onSubmitted] 配合使用。
  final TextInputAction? textInputAction;

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
          : (password
              ? TextInputType.visiblePassword
              : (_keyboardTypeOf(type) ?? TextInputType.text)),
      showWordLimit: showWordLimit,
      onFocus: onFocus,
      onBlur: onBlur,
      prefix: prefix,
      suffix: suffix,
      controller: controller,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
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
    this.controller,
    this.focusNode,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
    this.textInputAction,
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

  /// 外部文本控制器；**传入后由调用方持有与销毁**，且 [value] 仅作为初始值。
  final TextEditingController? controller;

  /// 外部焦点节点；传入后由调用方销毁。
  final FocusNode? focusNode;

  /// 输入格式化器。
  final List<TextInputFormatter>? inputFormatters;

  /// 是否自动聚焦，默认 false。
  final bool autofocus;

  /// 提交（键盘完成键）回调。
  final ValueChanged<String>? onSubmitted;

  /// 键盘动作按钮类型。
  final TextInputAction? textInputAction;

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
        controller: controller,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        autofocus: autofocus,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
      ),
    );
  }
}