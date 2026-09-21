import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// a11y 数字基线（T1.1）：逐组件断言语义角色与状态，防回退。
///
/// 基线原则同 golden（T4.1）：组件语义被意外删除 / 降级 / 角色变化时，
/// 对应用例直接变红。覆盖核心交互组件。
///
/// **守护分层**（2026-09-21 实测定案）：
/// - 自建语义（Semantics widget 显式声明的 checked / onTap / onIncrease 等）：
///   精确断言角色 + 状态 + 动作（checkbox / radio / switch / slider）
/// - 框架内建语义（InkWell 的 button / TextField 的 text field）：只断言角色标志——
///   Flutter 3.41 起内建动作不走旧位掩码（SemanticsData.actions 读不到，
///   实测 hasAction(tap/setText) 为 false），角色与动作由框架保证伴生；
///   组件退化为裸 GestureDetector 时角色标志消失，同样变红
///
/// 基线对应 2026-09-20/21 a11y 批次（T1.2 / T1.3 + 批次 6）完成后的状态。
///
/// API 说明：Flutter 3.41 起 SemanticsNode.hasFlag 已弃用，
/// flags 走 [SemanticsNode.flagsCollection]（结构化字段；isChecked 为 CheckedState 枚举）。
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

Future<void> _pump(WidgetTester tester, Widget child) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(400, 400));
  await tester.pumpWidget(_wrap(child));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('WotButton：button 角色（tap 动作由 InkWell 内建，不重复守护）', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotButton(text: '确定'));
    final node = tester.getSemantics(find.text('确定'));
    // 守护策略：框架内建组件只断言角色标志——角色与动作由框架保证伴生，
    // 若 InkWell 被换成裸 GestureDetector，isButton 消失、此处变红。
    // 动作位掩码（SemanticsData.actions）读不到框架内建动作，故不断言动作。
    expect(node.flagsCollection.isButton, isTrue);
    handle.dispose();
  });

  testWidgets('WotCheckbox：checked 状态 + tap 动作', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotCheckbox(label: '正常选中', modelValue: true));
    final node = tester.getSemantics(find.byType(WotCheckbox));
    expect(node.flagsCollection.isChecked, CheckedState.isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('WotRadio：checked 状态', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotRadio(label: '选项一', modelValue: true));
    final node = tester.getSemantics(find.byType(WotRadio));
    expect(node.flagsCollection.isChecked, CheckedState.isTrue);
    handle.dispose();
  });

  testWidgets('WotSwitch：checked 状态', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotSwitch(modelValue: true));
    final node = tester.getSemantics(find.byType(WotSwitch));
    expect(node.flagsCollection.isChecked, CheckedState.isTrue);
    handle.dispose();
  });

  testWidgets('WotSlider：increase / decrease 动作', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotSlider(modelValue: 50));
    final node = tester.getSemantics(find.byType(WotSlider));
    final data = node.getSemanticsData();
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);
    handle.dispose();
  });

  testWidgets('WotInput：文本字段角色（setText 由 TextField 内建，不重复守护）', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotInput(value: '输入内容'));
    final node = tester.getSemantics(find.byType(TextField));
    expect(node.flagsCollection.isTextField, isTrue);
    handle.dispose();
  });

  testWidgets('WotSearch：文本字段角色（setText 由 TextField 内建，不重复守护）', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const WotSearch(modelValue: '搜索词'));
    final node = tester.getSemantics(find.byType(TextField));
    expect(node.flagsCollection.isTextField, isTrue);
    handle.dispose();
  });
}
