import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 表单项校验规则，对齐 wot `FormRule`：给定当前值返回是否通过。
typedef WotFormRule = bool Function(String? value);

/// 通过 [BuildContext] 访问当前表单 [WotFormControl]（供子控件注册/取值）。
class WotFormScope extends InheritedWidget {
  const WotFormScope({super.key, required this.control, required super.child});

  final WotFormControl? control;

  static WotFormControl? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WotFormScope>()?.control;
  }

  @override
  bool updateShouldNotify(WotFormScope oldWidget) =>
      control != oldWidget.control;
}

/// 表项登记信息。
class _WotFormFieldEntry {
  _WotFormFieldEntry({required this.name, required this.label});
  final String name;
  final String label;
}

/// 表单控制器：维护各字段值、错误与校验规则。
class WotFormControl extends ChangeNotifier {
  WotFormControl({this.rules = const {}});

  final Map<String, WotFormRule> rules;
  final Map<String, String> _values = {};
  final Map<String, String?> _errors = {};
  final Map<String, _WotFormFieldEntry> _fields = {};

  void register(String name, String label) => _fields[name] = _WotFormFieldEntry(name: name, label: label);
  void unregister(String name) {
    _fields.remove(name);
    _values.remove(name);
    _errors.remove(name);
  }

  String? valueOf(String name) => _values[name];

  void setValue(String name, String? v) {
    _values[name] = v ?? '';
    _errors.remove(name);
    notifyListeners();
  }

  void clearValidate() {
    _errors.clear();
    notifyListeners();
  }

  /// 校验全部字段；返回首个失败信息，无则 null。
  String? validate() {
    for (final e in _fields.values) {
      final rule = rules[e.name];
      if (rule == null) continue;
      if (!rule(_values[e.name])) {
        final msg = '${e.label}校验未通过';
        _errors[e.name] = msg;
        notifyListeners();
        return msg;
      }
      _errors.remove(e.name);
    }
    notifyListeners();
    return null;
  }

  String? errorOf(String name) => _errors[name];
}

/// 表单组件，对应 wot `wd-form`。
///
/// 通过 [WotFormScope] 向下级联一个 [WotFormControl]。典型用法：
/// 用 [GlobalKey]<[WotFormState]> 持有表单，调用 `formKey.currentState!.validate()`
/// 触发校验；各录入组件（.[WotFormItem].child 或支持 `name` 的控件）会自动登记。
class WotForm extends StatefulWidget {
  const WotForm({
    super.key,
    this.rules = const {},
    this.submitButtonText,
    this.showSubmitButton = false,
    this.onSubmit,
    this.children = const [],
  });

  /// 校验规则：`{ 'field': (value) => ok }`。
  final Map<String, WotFormRule> rules;

  /// 底部提交按钮文字；为空则不渲染提交块。
  final String? submitButtonText;

  /// 是否显示底部提交按钮。
  final bool showSubmitButton;

  /// 提交按钮点击（校验通过后回调）。
  final ValueChanged<WotFormControl>? onSubmit;

  final List<Widget> children;

  @override
  State<WotForm> createState() => WotFormState();
}

class WotFormState extends State<WotForm> {
  late final WotFormControl _control;

  @override
  void initState() {
    super.initState();
    _control = WotFormControl(rules: widget.rules);
  }

  @override
  void didUpdateWidget(WotForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rules != widget.rules) {
      _control.rules..clear()..addAll(widget.rules);
    }
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  /// 当前表单控制器。
  WotFormControl get control => _control;

  /// 校验全部字段；通过返回 null，失败返回首个错误信息。
  String? validate() => _control.validate();

  /// 清除校验状态。
  void clearValidate() => _control.clearValidate();

  void _onSubmit() {
    final err = _control.validate();
    if (err == null) widget.onSubmit?.call(_control);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return WotFormScope(
      control: _control,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.children,
          if (widget.showSubmitButton && widget.submitButtonText != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 44,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: scheme.primaryOf(6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _onSubmit,
                  child: Text(widget.submitButtonText!),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}