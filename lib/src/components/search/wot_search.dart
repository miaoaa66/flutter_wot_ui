import 'package:flutter/material.dart';

import '../../locale/wot_messages.dart';
import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 搜索框，对应 wot `wd-search`。
class WotSearch extends StatefulWidget {
  const WotSearch({
    super.key,
    this.modelValue,
    this.onChange,
    this.onInput,
    this.onFocus,
    this.onBlur,
    this.onClear,
    this.placeholder,
    this.disabled = false,
    this.readonly = false,
    this.error = false,
    this.clearable = true,
    this.shape = 'round',
    this.background,
    this.showAction = false,
    this.actionText,
    this.onSearch,
    this.onClickAction,
    this.onClickInput,
    this.searchIconColor,
  });

  /// 输入框内容（受控）。
  final String? modelValue;

  /// 输入内容变化回调（与 [onInput] 一并触发）。
  final ValueChanged<String>? onChange;

  /// 输入内容变化回调（每次输入即触发，与 [onChange] 一并触发）。
  final ValueChanged<String>? onInput;

  /// 输入框获得焦点时触发的回调。
  final VoidCallback? onFocus;

  /// 输入框失去焦点时触发的回调。
  final VoidCallback? onBlur;

  /// 点击清除按钮时触发的回调。
  final VoidCallback? onClear;

  /// 输入框占位符，默认「搜索」。
  final String? placeholder;

  /// 是否禁用，默认 false。禁用时底色变浅、文字与图标灰化。
  final bool disabled;

  /// 是否只读，默认 false。只读仅锁编辑，保持正常配色。
  final bool readonly;

  /// 是否处于校验失败态（error 态）。命中时搜索框描红边。
  final bool error;

  /// 是否显示清除按钮，默认 true。
  final bool clearable;

  /// 形状：round（胶囊/圆角）/square，默认 round。
  final String shape;

  /// 背景颜色，默认使用主题填充色。
  final Color? background;

  /// 是否显示右侧操作按钮，默认 false。
  final bool showAction;

  /// 右侧操作按钮文案，默认「搜索」。
  final String? actionText;

  /// 搜索回调（提交或有搜索动作时触发）。
  final VoidCallback? onSearch;

  /// 点击右侧操作按钮回调。
  final VoidCallback? onClickAction;

  /// 点击输入框回调。
  final VoidCallback? onClickInput;

  /// 搜索图标颜色，默认使用主题辅助图标色。
  final Color? searchIconColor;

  @override
  State<WotSearch> createState() => _WotSearchState();
}

class _WotSearchState extends State<WotSearch> {
  late final TextEditingController _c;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.modelValue ?? '');
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(WotSearch old) {
    super.didUpdateWidget(old);
    if (widget.modelValue != null && widget.modelValue != _c.text) {
      _c.value = _c.value.copyWith(text: widget.modelValue);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _c.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
    if (_focus.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  void _search() {
    widget.onSearch?.call();
    widget.onClickAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final radius = widget.shape == 'round'
        ? const BorderRadius.all(Radius.circular(18))
        : const BorderRadius.all(Radius.circular(6));

    // 三态：显式传参 > WotFieldScope 下发 > 默认。
    // 搜索框为「无边框浅灰底」形态，故 readonly 仅锁编辑、不改配色；
    // disabled 变浅底 + 灰字 + 图标灰；error 额外描红边。
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final readonly = widget.readonly || (fieldScope?.state == WotFieldState.readonly);
    final hasError = widget.error || (fieldScope?.error ?? false);
    final style = wotFieldStyle(
      scheme,
      disabled ? WotFieldState.disabled : WotFieldState.editable,
      error: hasError,
    );
    final bg = disabled ? style.background : (widget.background ?? scheme.filledStrong);
    final auxIconColor = disabled ? scheme.iconDisabled : scheme.iconAuxiliary;

    // 行高显式钉死为 20px（配合下方 contentPadding 8×2 恰为容器高 36）。
    // 不钉行高时 isDense 的 InputDecorator 按「fontSize+padding」算行盒，
    // 与实际字形行高不一致，文字会偏离垂直中线。
    final textStyle = TextStyle(fontSize: 14, height: 20 / 14, color: style.text);

    final field = TextField(
      controller: _c,
      focusNode: _focus,
      enabled: !disabled,
      readOnly: readonly,
      onChanged: (v) {
        widget.onChange?.call(v);
        widget.onInput?.call(v);
      },
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: textStyle,
      decoration: InputDecoration(
        hintText: widget.placeholder ?? tr(context, 'wot.common.search'),
        hintStyle: TextStyle(
            fontSize: 14, height: 20 / 14, color: style.placeholder),
        border: InputBorder.none,
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );

    final box = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        // 搜索框本身无边框，仅在 error（且未禁用）时补一圈红边以醒目。
        border: hasError && !disabled ? Border.all(color: scheme.dangerMain) : null,
      ),
      child: Row(
        children: [
          WotIcon(
            name: 'search',
            size: 16,
            color: disabled ? scheme.iconDisabled : (widget.searchIconColor ?? scheme.iconAuxiliary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(onTap: widget.onClickInput, child: field),
          ),
          if (widget.clearable && _c.text.isNotEmpty && !disabled && !readonly)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _c.clear();
                widget.onChange?.call('');
                widget.onInput?.call('');
                widget.onClear?.call();
                setState(() {});
              },
              child: WotIcon(name: 'close-circle', size: 14, color: auxIconColor),
            ),
        ],
      ),
    );

    final action = widget.showAction
        ? InkWell(
            onTap: disabled ? null : _search,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                widget.actionText ?? tr(context, 'wot.common.search'),
                style: TextStyle(fontSize: 14, color: scheme.primaryOf(6)),
              ),
            ),
          )
        : null;

    return Row(
      children: [
        Expanded(child: box),
        ?action,
      ],
    );
  }
}