import 'package:flutter/material.dart';

import '../../theme/wot_state.dart';
import '../../theme/wot_theme.dart';
import '../form/wot_form.dart';

/// 开关，对应 wot `wd-switch`。受控（v-model:value，true/false）。
class WotSwitch extends StatelessWidget {
  const WotSwitch({
    super.key,
    this.modelValue = false,
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

  /// 当前开关状态（v-model，true/false）。
  final bool modelValue;

  /// 开关状态变化时触发的回调，参数为最新状态。
  final ValueChanged<bool>? onChange;

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
    final on = modelValue;
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled || readonly || loading
          ? null
          : () {
              wotFormPushValue(context, name, !on);
              onChange?.call(!on);
            },
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
  }
}
