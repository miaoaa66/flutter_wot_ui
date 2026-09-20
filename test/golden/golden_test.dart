import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// Golden 基线测试（T4.1）。
///
/// 覆盖高频组件的基础态，以及三态语义（disabled / readonly / error）的关键视觉。
/// 基线图与平台绑定——**生成 / 更新基线必须固定在同一平台执行**：
///
/// ```
/// flutter test --update-goldens test/golden
/// ```
///
/// 日常验证（对比基线，不一致即失败）：
///
/// ```
/// flutter test test/golden
/// ```
///
/// 说明：测试环境文本用 Ahem 字体渲染（块状字形），跨平台一致是 golden 的设计前提；
/// 动画组件统一 pump 300ms 到稳定态，避免帧相位差导致基线抖动。
Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WotConfigProvider(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// 统一泵到稳定态后返回；surface 固定 400x120，保证基线尺寸一致。
Future<void> _pump(WidgetTester tester, Widget child) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(400, 120));
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(child));
  // 跳过 AnimatedContainer / AnimatedAlign 等入场动画到稳定态。
  await tester.pump(const Duration(milliseconds: 300));
}

/// 以固定 key 包裹内容，便于 expectLater 精确定位。
Widget _keyed(Key key, Widget child) =>
    KeyedSubtree(key: key, child: child);

void main() {
  testWidgets('WotButton 基础态', (tester) async {
    await _pump(tester, const WotButton(text: '确定'));
    await expectLater(
      find.byType(WotButton),
      matchesGoldenFile('goldens/button.png'),
    );
  });

  testWidgets('WotCheckbox 三态（正常 / 只读 / 禁用 / 校验失败）', (tester) async {
    await _pump(
      tester,
      _keyed(
        const Key('checkbox-states'),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            WotCheckbox(label: '正常选中', modelValue: true),
            WotCheckbox(label: '只读锁定', modelValue: true, readonly: true),
            WotCheckbox(label: '禁用灰化', modelValue: true, disabled: true),
            WotCheckbox(label: '校验失败', modelValue: false, error: true),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('checkbox-states')),
      matchesGoldenFile('goldens/checkbox_states.png'),
    );
  });

  testWidgets('WotRadio 三态（正常 / 只读 / 禁用 / 校验失败）', (tester) async {
    await _pump(
      tester,
      _keyed(
        const Key('radio-states'),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            WotRadio(label: '正常选中', modelValue: true),
            WotRadio(label: '只读锁定', modelValue: true, readonly: true),
            WotRadio(label: '禁用灰化', modelValue: true, disabled: true),
            WotRadio(label: '校验失败', modelValue: false, error: true),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('radio-states')),
      matchesGoldenFile('goldens/radio_states.png'),
    );
  });

  testWidgets('WotSwitch 状态（开 / 关 / 禁用 / 只读）', (tester) async {
    await _pump(
      tester,
      _keyed(
        const Key('switch-states'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            WotSwitch(modelValue: true),
            SizedBox(width: 12),
            WotSwitch(modelValue: false),
            SizedBox(width: 12),
            WotSwitch(modelValue: true, disabled: true),
            SizedBox(width: 12),
            WotSwitch(modelValue: true, readonly: true),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('switch-states')),
      matchesGoldenFile('goldens/switch_states.png'),
    );
  });

  testWidgets('WotSlider 状态（默认 / 禁用 / 只读 / 校验失败）', (tester) async {
    await _pump(
      tester,
      _keyed(
        const Key('slider-states'),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WotSlider(modelValue: 50),
            WotSlider(modelValue: 50, disabled: true),
            WotSlider(modelValue: 50, readonly: true),
            WotSlider(modelValue: 50, error: true),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('slider-states')),
      matchesGoldenFile('goldens/slider_states.png'),
    );
  });

  testWidgets('WotRate 状态（评分 / 禁用 / 只读 / 校验失败）', (tester) async {
    await _pump(
      tester,
      _keyed(
        const Key('rate-states'),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WotRate(modelValue: 3),
            WotRate(modelValue: 3, disabled: true),
            WotRate(modelValue: 3, readonly: true),
            WotRate(modelValue: 3, error: true),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('rate-states')),
      matchesGoldenFile('goldens/rate_states.png'),
    );
  });

  testWidgets('WotInput 三态（可编辑 / 只读 / 禁用 / 校验失败）', (tester) async {
    await _pump(
      tester,
      _keyed(
        const Key('input-states'),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            WotInput(value: '可编辑文本'),
            WotInput(value: '只读文本', readonly: true),
            WotInput(value: '禁用文本', disabled: true),
            WotInput(value: '校验失败', error: true),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('input-states')),
      matchesGoldenFile('goldens/input_states.png'),
    );
  });

  testWidgets('WotInputNumber 基础态', (tester) async {
    await _pump(tester, WotInputNumber(modelValue: 5));
    await expectLater(
      find.byType(WotInputNumber),
      matchesGoldenFile('goldens/input_number.png'),
    );
  });

  testWidgets('WotSearch 基础态', (tester) async {
    await _pump(tester, const WotSearch(modelValue: '搜索词'));
    await expectLater(
      find.byType(WotSearch),
      matchesGoldenFile('goldens/search.png'),
    );
  });

  testWidgets('WotCell 基础态', (tester) async {
    await _pump(
      tester,
      const WotCell(title: '单元格标题', value: '说明文字'),
    );
    await expectLater(
      find.byType(WotCell),
      matchesGoldenFile('goldens/cell.png'),
    );
  });
}
