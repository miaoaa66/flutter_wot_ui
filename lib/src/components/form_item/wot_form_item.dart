import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

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
      _control?.unregister(widget.name);
      _control = c;
      if (c != null) {
        c.register(widget.name, widget.label ?? widget.name);
        // 延迟一帧避免在 build 中同步触发通知。
      }
    }
  }

  @override
  void dispose() {
    _control?.unregister(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final control = _control;
    final err = widget.errorMessage ??
        control?.errorOf(widget.name) ??
        (widget.required && control?.valueOf(widget.name)?.isEmpty == true
            ? '${widget.label ?? widget.name}不能为空'
            : null);
    final showErr = widget.showMessage && err != null;

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
                    Text('*', style: TextStyle(color: scheme.dangerMain, fontSize: 14)),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    widget.label!,
                    style: TextStyle(fontSize: 14, color: scheme.textMain),
                  ),
                ],
              ),
            ),
          );

    return Container(
      padding: widget.childrenPadding,
      decoration: widget.border
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: scheme.borderLight, width: 0.5),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labelWidget != null) ...[
            Padding(padding: const EdgeInsets.only(bottom: 6), child: labelWidget),
          ],
          widget.child,
          if (showErr) ...[
            const SizedBox(height: 6),
            Text(
              err,
              style: TextStyle(fontSize: 12, color: scheme.dangerMain),
            ),
          ],
        ],
      ),
    );
  }
}