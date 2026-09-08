import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotPagination 分页示例页。
class WotPaginationPage extends StatefulWidget {
  const WotPaginationPage({super.key});

  @override
  State<WotPaginationPage> createState() => _WotPaginationPageState();
}

class _WotPaginationPageState extends State<WotPaginationPage> {
  int _m1 = 1;
  int _m2 = 1;
  int _m3 = 1;
  int _m4 = 1;

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotPagination 分页',
      children: [
        demoSection('三种模式（mode: multi / button / simple）'),
        demoBlock('多页 multi',
            WotPagination(modelValue: _m1, total: 86, onChange: (p) => setState(() => _m1 = p))),
        demoBlock('按钮 button',
            WotPagination(modelValue: _m2, total: 38, mode: WotPaginationMode.button, onChange: (p) => setState(() => _m2 = p))),
        demoBlock('简单 simple',
            WotPagination(modelValue: _m3, total: 18, mode: WotPaginationMode.simple, onChange: (p) => setState(() => _m3 = p))),
        demoSection('pageSize / 页容量'),
        demoBlock('pageSize=5（total=30 → 6 页）',
            WotPagination(modelValue: _m4, total: 30, pageSize: 5, pagerCount: 3, onChange: (p) => setState(() => _m4 = p))),
      ],
    );
  }
}