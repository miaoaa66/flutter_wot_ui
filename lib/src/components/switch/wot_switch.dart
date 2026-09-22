import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

/// 开关，对应 wot `wd-switch`。
///
/// 泛型支持自定义值域（D 类 P1）：对接 `'1'/'0'` 后端协议时使用
/// `WotSwitch<String>(modelValue: '1', activeValue: '1', inactiveValue: '0')`，
/// 此时 [modelValue] 与 [onChange] 均为 String；默认值域为 bool
/// （不传 activeValue/inactiveValue，`WotSwitch(modelValue: true)` 用法不变）。
class WotSwitch<T> extends StatelessWidget {
  const WotSwitch({
    super.key,
    this.modelValue,
    this.activeValue,
    this.inactiveValue,
    this.beforeChange,
    this.onChange,
    this.disabled = false,
    this.readonly = false,
    this.loading = false,
    this.activeColor,
    this.inactiveColor,
    this.activeText,
    this.inactiveText,
    this.size = 24,
    this.name,
  });

  /// 当前开关绑定的值。未配置 [activeValue] 时按 bool 使用（true 为开）。
  final T? modelValue;

  /// 打开时对应的值（如 `'1'`），需与 [inactiveValue] 成对使用；缺省为 true。
  final T? activeValue;

  /// 关闭时对应的值（如 `'0'`）；缺省为 false。
  final T? inactiveValue;

  /// 切换前确认：返回 false 阻止本次切换（可用于二次确认弹窗等场景）。
  final Future<bool> Function(T val)? beforeChange;

  /// 开关状态变化时触发的回调，参数为最新值（自定义值域时为 activeValue/inactiveValue 之一）。
  final ValueChanged<T>? onChange;

  /// 是否禁用，默认 false。禁用时轨道灰化且不可切换。
  final bool disabled;

  /// 是否只读：不可切换，但保持正常配色（内容有效可读），默认 false。
  final bool readonly;

  /// 是否为加载中状态，加载中不可点击切换，默认 false。
  final bool loading;

  /// 激活状态颜色（开启时轨道颜色），缺省取主题主色。
  final Color? activeColor;

  /// 非激活状态颜色（关闭时轨道颜色），缺省取主题填充色。
  final Color? inactiveColor;

  /// 开启时显示的文本（轨道内文字）。
  final String? activeText;

  /// 关闭时显示的文本（轨道内文字）。
  final String? inactiveText;

  /// 开关尺寸（高度），单位 px，默认 24。
  final double size;

  /// 表单字段名（用于原生表单提交示例）。
  final String? name;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    // 三态：显式 disabled 优先，其次取父级 WotFieldScope 下发；
    // readonly 仅禁切换、保持正常配色（区别于 disabled 的灰化）。
    final fieldScope = WotFieldScope.of(context);
    final disabled = this.disabled || (fieldScope?.state == WotFieldState.disabled);
    // 值域判定：配置了 activeValue 时按自定义值域比较，否则按 bool（true 为开）。
    final on = modelValue == (activeValue ?? true);
    final trackColor = on
        ? (disabled ? scheme.filledExtraStrong : (activeColor ?? scheme.primaryOf(6)))
        : (inactiveColor ?? scheme.filledStrong);
    final width = size * 2;
    final height = size;
    final knobSize = height * 0.7;
    final pad = height * 0.15;
    final switchText = on ? activeText : inactiveText;

    final knob = loading
        ? SizedBox(
            width: knobSize,
            height: knobSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: trackColor == Colors.white ? scheme.textMain : Colors.white,
            ),
          )
        : Container(
            width: knobSize,
            height: knobSize,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          );

    final semanticOnTap = (disabled || readonly || loading)
        ? null
        : () async {
            // 切换目标：自定义值域取对立值；默认 bool 值域取 !on。
            // 约定：自定义值域需成对传 activeValue/inactiveValue，
            // 未成对时 fallback 的 bool cast 会在运行时暴露误用。
            final T next = on
                ? (inactiveValue ?? (false as T))
                : (activeValue ?? (true as T));
            if (beforeChange != null) {
              final ok = await beforeChange!(next);
              if (!ok) return;
            }
            // beforeChange 异步确认期间组件可能已随页面卸载。
            if (!context.mounted) return;
            wotFormPushValue(context, name, next);
            onChange?.call(next);
          };

    // 无障碍：裸 GestureDetector 不产生语义节点，屏幕阅读器读不出「开 / 关」。
    // switch 语义用 checked 表达（与 Flutter 官方 Switch 一致）。
    final toggle = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: semanticOnTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (switchText != null && switchText.isNotEmpty)
              Align(
                alignment: on ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad * 0.5),
                  child: Text(
                    switchText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: height * 0.4),
                  ),
                ),
              ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: on ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: knob,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      checked: on,
      enabled: !disabled,
      onTap: semanticOnTap,
      child: toggle,
    );
  }
}
