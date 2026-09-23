import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';
import '../icon/wot_icon.dart';

/// 表单项，对应 wot `wd-form-item`。
///
/// 提供标签、必填星号、错误提示。构造时按 [name] 向父级 [WotForm] 登记字段
/// 用于校验；错误来自父级控制器的校验结果或外部 [errorMessage]。
class WotFormItem extends StatefulWidget {
  const WotFormItem({
    super.key,
    required this.name,
    this.label,
    this.required = false,
    this.labelAlign = Alignment.centerLeft,
    this.labelWidth,
    this.errorMessage,
    this.showMessage = true,
    this.border = true,
    this.childrenPadding = const EdgeInsets.fromLTRB(16, 10, 16, 10),
    this.clickable = false,
    this.isLink = false,
    this.onTap,
    this.disabled = false,
    this.readonly = false,
    required this.child,
  });

  /// 字段名，用于表单登记/取值/校验。
  final String name;

  /// 标签文案。
  final String? label;

  /// 是否必填（显示星号）。
  final bool required;

  /// 标签对齐方式，默认左对齐。
  final Alignment labelAlign;

  /// 标签宽度。
  final double? labelWidth;

  /// 外部自定义错误信息。
  final String? errorMessage;

  /// 是否显示错误提示。
  final bool showMessage;

  /// 是否会话底部边框。
  final bool border;

  /// 整体内边距，默认 (16, 10, 16, 10)。
  final EdgeInsets childrenPadding;

  /// 是否可点击（为 true 时整行包裹点击手势并带水波纹）。
  final bool clickable;

  /// 是否展示右侧箭头（配合 [clickable] 表达「跳转」语义）。
  final bool isLink;

  /// 点击整行的回调；需要 [clickable] 为 true 才会触发。
  final VoidCallback? onTap;

  /// 是否禁用整项。命中时标签灰化，并通过 [WotFieldScope] 下发，令内部录入控件
  /// （如 `WotInput`）自动进入禁用态。
  final bool disabled;

  /// 是否只读整项。内部控件保持正常字色（内容有效可读），仅去除输入区边框——
  /// 与 [disabled] 的灰化明确区分，详见三态语义规范。
  final bool readonly;

  /// 表单项内容（录入控件）。
  final Widget child;

  @override
  State<WotFormItem> createState() => _WotFormItemState();
}

class _WotFormItemState extends State<WotFormItem> {
  WotFormControl? _control;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = WotFormScope.of(context);
    if (c != _control) {
      _control?.removeListener(_onControlChanged);
      _control?.unregister(widget.name);
      _control = c;
      if (c != null) {
        // 订阅控制器：值/校验结果变化时重建以实时显示错误。
        c.addListener(_onControlChanged);
        c.register(widget.name, widget.label ?? widget.name);
      }
    }
  }

  void _onControlChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _control?.removeListener(_onControlChanged);
    _control?.unregister(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final control = _control;
    final err = widget.errorMessage ??
        control?.errorOf(widget.name) ??
        // 必填空值提示只在「该字段已被校验过」后才展示，
        // 否则进入页面就会满屏红字。
        (widget.required &&
                (control?.wasValidated(widget.name) ?? false) &&
                _isEmpty(control?.valueOf(widget.name))
            ? '${widget.label ?? widget.name}不能为空'
            : null);
    final showErr = widget.showMessage &&
        err != null &&
        (control?.errorType ?? WotFormErrorType.message) !=
            WotFormErrorType.none;

    // 三态：显式 disabled / readonly 优先，其次继承外层 WotFieldScope。
    final parentScope = WotFieldScope.of(context);
    final state = widget.disabled
        ? WotFieldState.disabled
        : widget.readonly
            ? WotFieldState.readonly
            : (parentScope?.state ?? WotFieldState.editable);
    final style = wotFieldStyle(scheme, state, error: showErr);
    final isDisabled = state == WotFieldState.disabled;

    final labelWidget = widget.label == null
        ? null
        : SizedBox(
            width: widget.labelWidth,
            child: Align(
              alignment: widget.labelAlign,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.required) ...[
                    Text(
                      '*',
                      style: TextStyle(
                        color: isDisabled ? scheme.textDisabled : scheme.dangerMain,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    widget.label!,
                    style: TextStyle(fontSize: 14, color: style.label),
                  ),
                ],
              ),
            ),
          );

    // 把三态下发到内部录入控件（如 WotInput）：一处配置、内部跟随。
    return WotFieldScope(
      state: state,
      error: showErr,
      child: Container(
        padding: widget.childrenPadding,
        decoration: widget.border
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: scheme.borderLight, width: 0.5),
                ),
              )
            : null,
        child: _wrapTappable(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (labelWidget != null) ...[
                Padding(padding: const EdgeInsets.only(bottom: 6), child: labelWidget),
              ],
              Row(
                children: [
                  Expanded(child: widget.child),
                  if (widget.isLink) ...[
                    const SizedBox(width: 6),
                    WotIcon(
                      name: 'arrow-right',
                      size: 16,
                      color: isDisabled ? scheme.iconDisabled : scheme.iconAuxiliary,
                    ),
                  ],
                ],
              ),
              if (showErr) ...[
                const SizedBox(height: 6),
                Text(
                  err,
                  style: TextStyle(fontSize: 12, color: scheme.dangerMain),
                ),
              ],
            ],
          ),
          disabled: isDisabled,
        ),
      ),
    );
  }

  /// [clickable] 为 true 且未禁用时，给整行加点击手势与水波纹。
  Widget _wrapTappable(Widget content, {required bool disabled}) {
    if (!widget.clickable || disabled) return content;
    return InkWell(onTap: widget.onTap, child: content);
  }

  /// 判定「值为空」：兼容 String / Iterable / Map / null。
  static bool _isEmpty(Object? v) {
    if (v == null) return true;
    if (v is String) return v.isEmpty;
    if (v is Iterable) return v.isEmpty;
    if (v is Map) return v.isEmpty;
    return false;
  }
}