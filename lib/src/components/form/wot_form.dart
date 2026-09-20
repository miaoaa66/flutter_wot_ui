import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../toast/wot_toast.dart';

/// 表单项校验规则，对齐 wot `FormRule`。
///
/// 返回值语义同时兼容两种写法：
/// - `null` 或 `true` —— 校验通过
/// - `false` —— 校验失败，使用默认文案「{label}校验未通过」
/// - 非空字符串 —— 校验失败，并以该字符串作为错误提示（自定义消息）
///
/// 入参声明为 `dynamic`，因此既有的 `(v) => v != null && v.isNotEmpty`
/// 这类针对 String 的写法无需改动即可继续编译。
typedef WotFormRule = Object? Function(dynamic value);

/// 触发校验的时机。
enum WotFormTrigger {
  /// 值变化时立即校验。
  change,

  /// 失焦时校验（需录入控件在失焦时调用 [WotFormControl.validateField]）。
  blur,

  /// 提交或手动调用 validate 时校验。
  submit,
}

/// 校验失败的展示方式。
enum WotFormErrorType {
  /// 表单项下方内联展示错误文案（默认）。
  message,

  /// 除内联展示外，额外用 toast 提示首个错误。
  toast,

  /// 不展示错误（调用方自行处理 validate 的返回值）。
  none,
}

/// 通过 [BuildContext] 访问当前表单 [WotFormControl]（供子控件注册/取值）。
class WotFormScope extends InheritedWidget {
  const WotFormScope({super.key, required this.control, required super.child});

  final WotFormControl? control;

  static WotFormControl? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WotFormScope>()?.control;
  }

  /// 在非 build 阶段（如点击回调）读取控制器，**不建立**依赖关系。
  ///
  /// 录入控件在值变化回调里登记数据时应走这里，避免把回调变成依赖方。
  static WotFormControl? read(BuildContext context) {
    final el = context.getElementForInheritedWidgetOfExactType<WotFormScope>();
    return (el?.widget as WotFormScope?)?.control;
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
///
/// 值类型为 [Object]，因此 switch（bool）、rate / slider（num）、
/// input（String）等控件都能登记同一个字段。
class WotFormControl extends ChangeNotifier {
  WotFormControl({
    Map<String, WotFormRule> rules = const {},
    Map<String, Object?> model = const {},
    Set<WotFormTrigger> validateTrigger = const {WotFormTrigger.submit},
    this.errorType = WotFormErrorType.message,
  })  : _rules = Map<String, WotFormRule>.of(rules),
        _trigger = Set<WotFormTrigger>.of(validateTrigger),
        _initialModel = Map<String, Object?>.of(model) {
    _values.addAll(_initialModel);
  }

  final Map<String, WotFormRule> _rules;
  final Set<WotFormTrigger> _trigger;
  Map<String, Object?> _initialModel;

  /// 错误展示方式（由 [WotForm] 下发，供 [WotFormItem] 读取）。
  WotFormErrorType errorType;

  final Map<String, Object?> _values = {};
  final Map<String, String> _errors = {};
  final Map<String, _WotFormFieldEntry> _fields = {};

  /// 已被校验过的字段名。
  ///
  /// 用于区分「尚未校验」与「校验不通过」：仅标记过的字段才允许展示
  /// 必填类错误，避免刚进入页面就满屏红字。
  final Set<String> _validated = {};

  /// 该字段是否已被校验过（至少跑过一次规则）。
  bool wasValidated(String name) => _validated.contains(name);

  /// 当前全部字段值（只读副本）。
  Map<String, Object?> get values => Map<String, Object?>.unmodifiable(_values);

  /// 当前全部错误（只读副本）。
  Map<String, String> get errors => Map<String, String>.unmodifiable(_errors);

  void register(String name, String label) =>
      _fields[name] = _WotFormFieldEntry(name: name, label: label);

  void unregister(String name) {
    _fields.remove(name);
    _values.remove(name);
    _errors.remove(name);
  }

  Object? valueOf(String name) => _values[name];

  String? errorOf(String name) => _errors[name];

  /// 写入字段值。若触发时机包含 [WotFormTrigger.change] 则立即校验该字段。
  void setValue(String name, Object? v) {
    _values[name] = v;
    if (_trigger.contains(WotFormTrigger.change)) {
      validateField(name);
      return;
    }
    _errors.remove(name);
    notifyListeners();
  }

  /// 整体替换校验规则。
  void setRules(Map<String, WotFormRule> r) {
    _rules
      ..clear()
      ..addAll(r);
  }

  /// 更新初始 model：合并新键，已存在的键保持不变（避免覆盖用户输入）。
  void setModel(Map<String, Object?> model) {
    _initialModel = Map<String, Object?>.of(model);
    for (final e in model.entries) {
      _values.putIfAbsent(e.key, () => e.value);
    }
    notifyListeners();
  }

  void clearValidate() {
    _errors.clear();
    // 必须一并清除：否则清空错误后，必填字段会因「已校验 + 值为空」立刻重新报错。
    _validated.clear();
    notifyListeners();
  }

  /// 重置到初始 model 并清空错误。
  void reset() {
    _values
      ..clear()
      ..addAll(_initialModel);
    _errors.clear();
    _validated.clear();
    notifyListeners();
  }

  /// 校验单个字段；返回错误文案，通过返回 null。
  String? validateField(String name) {
    final entry = _fields[name];
    if (entry == null) return null;
    _validated.add(name);
    final rule = _rules[name];
    if (rule == null) {
      _errors.remove(name);
      notifyListeners();
      return null;
    }
    final msg = _evalRule(rule, _values[name], entry.label);
    if (msg == null) {
      _errors.remove(name);
    } else {
      _errors[name] = msg;
    }
    notifyListeners();
    return msg;
  }

  /// 校验全部字段（或 [prop] 指定的单个字段），返回「字段名 → 错误文案」。
  ///
  /// 与 [validate] 的区别是它返回完整错误表，便于调用方自行处理。
  Map<String, String> validateFields([String? prop]) {
    if (prop != null) {
      final m = validateField(prop);
      return m == null ? <String, String>{} : <String, String>{prop: m};
    }
    final out = <String, String>{};
    for (final e in _fields.values) {
      _validated.add(e.name);
      final rule = _rules[e.name];
      if (rule == null) continue;
      final msg = _evalRule(rule, _values[e.name], e.label);
      if (msg == null) {
        _errors.remove(e.name);
      } else {
        _errors[e.name] = msg;
        out[e.name] = msg;
      }
    }
    notifyListeners();
    return out;
  }

  /// 校验并给出首个错误文案；全部通过返回 null。
  ///
  /// 传入 [prop] 时只校验该字段。注意：无 [prop] 时会遍历全部字段，
  /// 因此多个字段失败时它们的错误会同步展示。
  String? validate([String? prop]) {
    final errs = validateFields(prop);
    return errs.isEmpty ? null : errs.values.first;
  }

  static String? _evalRule(WotFormRule rule, Object? value, String label) {
    final r = rule(value);
    if (r == null || r == true) return null;
    if (r == false) return '$label校验未通过';
    return r.toString();
  }
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
    this.model = const {},
    this.validateTrigger = const {WotFormTrigger.submit},
    this.errorType = WotFormErrorType.message,
    this.onError,
    this.submitButtonText,
    this.showSubmitButton = false,
    this.onSubmit,
    this.children = const [],
    this.disabled = false,
  });

  /// 校验规则：`{ 'field': (value) => ... }`。
  ///
  /// 返回 `null`/`true` 通过；`false` 用默认文案；返回字符串则用该字符串作为提示。
  final Map<String, WotFormRule> rules;

  /// 初始表单数据（wot `model` 语义）。
  final Map<String, Object?> model;

  /// 触发校验的时机集合，默认仅提交时。
  final Set<WotFormTrigger> validateTrigger;

  /// 错误展示方式，默认 [WotFormErrorType.message]。
  final WotFormErrorType errorType;

  /// 校验失败回调（参数为「字段名 → 错误文案」），与 [errorType] 独立。
  final ValueChanged<Map<String, String>>? onError;

  /// 底部提交按钮文字；为空则不渲染提交块。
  final String? submitButtonText;

  /// 是否显示底部提交按钮。
  final bool showSubmitButton;

  /// 提交按钮点击（校验通过后回调）。
  final ValueChanged<WotFormControl>? onSubmit;

  /// 子组件列表。
  final List<Widget> children;

  /// 是否禁用整个表单。命中时经 [WotFieldScope] 下发，令所有 `WotFormItem`
  /// 及其内部录入控件一并进入禁用态（对齐 Vue `wd-form` 的 disabled）。
  final bool disabled;

  @override
  State<WotForm> createState() => WotFormState();
}

class WotFormState extends State<WotForm> {
  late final WotFormControl _control;

  @override
  void initState() {
    super.initState();
    _control = WotFormControl(
      rules: widget.rules,
      model: widget.model,
      validateTrigger: widget.validateTrigger,
      errorType: widget.errorType,
    );
  }

  @override
  void didUpdateWidget(WotForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rules != widget.rules) _control.setRules(widget.rules);
    if (oldWidget.model != widget.model) _control.setModel(widget.model);
    if (oldWidget.errorType != widget.errorType) {
      _control.errorType = widget.errorType;
    }
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  /// 当前表单控制器。
  WotFormControl get control => _control;

  /// 校验全部字段（或 [prop] 指定的单个字段）；通过返回 null，失败返回首个错误信息。
  String? validate([String? prop]) {
    final errs = _control.validateFields(prop);
    if (errs.isEmpty) return null;
    final first = errs.values.first;
    if (widget.errorType == WotFormErrorType.toast) {
      WotToast.show(context, first);
    }
    widget.onError?.call(errs);
    return first;
  }

  /// 清除校验状态。
  void clearValidate() => _control.clearValidate();

  /// 重置到初始 model 并清空错误。
  void reset() => _control.reset();

  void _onSubmit() {
    final err = validate();
    if (err == null) widget.onSubmit?.call(_control);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return WotFormScope(
      control: _control,
      // 表单级三态下发：disabled 时整表（含内部录入控件）自动进入禁用态。
      child: WotFieldScope(
        state: widget.disabled ? WotFieldState.disabled : WotFieldState.editable,
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
                      backgroundColor:
                          widget.disabled ? scheme.filledExtraStrong : scheme.primaryOf(6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.disabled ? null : _onSubmit,
                    child: Text(widget.submitButtonText!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// 供录入控件把当前值登记到所属表单（wot `name` 语义）。
///
/// 值类型为 [Object]，因此 switch（bool）、rate / slider（num）、input（String）
/// 等不同控件都能共用同一个字段槽位。
void wotFormPushValue(BuildContext context, String? name, Object? value) {
  if (name == null) return;
  WotFormScope.read(context)?.setValue(name, value);
}
