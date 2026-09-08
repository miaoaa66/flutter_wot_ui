import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTable 表格示例页。
class WotTablePage extends StatelessWidget {
  const WotTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTable 表格',
      children: [
        demoSection('基础（border / stripe / 列宽 / 对齐 / onRowClick）'),
        demoBlock('斑马纹 + 行点击',
            WotTable(
              border: true,
              stripe: true,
              data: [
                {'name': '张三', 'age': 28, 'city': '北京'},
                {'name': '李四', 'age': 25, 'city': '上海'},
                {'name': '王五', 'age': 30, 'city': '广州'},
              ],
              columns: const [
                WotTableColumn(prop: 'name', label: '姓名', align: WotTableAlign.center),
                WotTableColumn(prop: 'age', label: '年龄', align: WotTableAlign.center, width: 60),
                WotTableColumn(prop: 'city', label: '城市', align: WotTableAlign.center),
              ],
              onRowClick: (row, i) => demoToast(context, '点击：${row['name']}'),
            )),
        demoSection('maxHeight 滚动 + formatter 格式化'),
        demoBlock('多行滚动 + 自定义格式化',
            WotTable(
              border: true,
              maxHeight: 200,
              data: List.generate(8, (i) => {'name': '用户${i + 1}', 'amount': (i + 1) * 12.5, 'status': i.isEven ? '已支付' : '待支付'}),
              columns: [
                WotTableColumn(prop: 'name', label: '订单', width: 90, align: WotTableAlign.left),
                WotTableColumn(prop: 'amount', label: '金额', width: 90, align: WotTableAlign.right, formatter: (v, _) => '¥$v'),
                WotTableColumn(prop: 'status', label: '状态', align: WotTableAlign.center, formatter: (v, _) => v == '已支付' ? '✔ $v' : '$v'),
              ],
            )),
      ],
    );
  }
}