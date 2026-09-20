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
  int _m5 = 1;
  int _pageSize5 = 10;
  int _m6 = 1;
  int _pageSize6 = 20;
  int _m7 = 1;
  final int _pageSize7 = 10;

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
        demoSection('设置弹框（showSettings）'),
        demoBlock('完整设置弹框（pageSize 选项 + 跳转页码）',
            WotPagination(
              modelValue: _m5,
              total: 100,
              pageSize: _pageSize5,
              showSettings: true,
              showPageSizeOptions: true,
              showJumper: true,
              pageSizeOptions: const [10, 20, 50, 100],
              onChange: (p) => setState(() => _m5 = p),
              onPageSizeChange: (size) => setState(() => _pageSize5 = size),
            )),
        demoBlock('仅 pageSize 选项（不显示跳转）',
            WotPagination(
              modelValue: _m6,
              total: 200,
              pageSize: _pageSize6,
              showSettings: true,
              showPageSizeOptions: true,
              showJumper: false,
              pageSizeOptions: const [5, 10, 20, 50],
              onChange: (p) => setState(() => _m6 = p),
              onPageSizeChange: (size) => setState(() => _pageSize6 = size),
            )),
        demoBlock('仅跳转页码（不显示 pageSize 选项）',
            WotPagination(
              modelValue: _m7,
              total: 50,
              pageSize: _pageSize7,
              showSettings: true,
              showPageSizeOptions: false,
              showJumper: true,
              onChange: (p) => setState(() => _m7 = p),
            )),
      ],
    );
  }
}
