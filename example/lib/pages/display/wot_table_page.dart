import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotTable 表格示例页。
class WotTablePage extends StatelessWidget {
  WotTablePage({super.key});

  /// 大数据 + 虚拟滚动 / 固定表头 / 左右固定列 / 多选 / 排序 / 插槽的数据。
  final List<Map<String, dynamic>> bigData =
      List.generate(1000 * 300, (i) {
    return {
      'id': 'U001$i',
      'name': '用户${i + 1}',
      'dept': ['研发', '产品', '设计', '运营'][i % 4],
      'amount': (i + 1) * 3.7,
      'status': i.isEven ? '已支付' : '待支付',
      'op': i,
    };
  });

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotTable 表格',
      children: [
        demoSection('基础（border / stripe / 列宽 / 对齐 / onRowClick）'),
        demoBlock('斑马纹 + 行点击',
            WotTable(
              border: false,
              stripe: false,
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
        demoSection('大数据：固定表头 / 虚拟滚动 / 左右固定列 / 多选 / 排序 / 插槽'),
        demoBlock('首列固定 + 末列操作插槽 + 金额列排序',
            WotTable(
              border: true,
              stripe: true,
              maxHeight: 320,
              rowSelection: WotTableRowSelection.multiple,
              showOverflowTooltip: true,
              data: bigData,
              columns: [
                WotTableColumn(
                    prop: 'id',
                    label: '编号',
                    width: 70,
                    align: WotTableAlign.center,
                    fixed: WotTableFixed.left),
                WotTableColumn(prop: 'name', label: '姓名', width: 100, align: WotTableAlign.left,sortable: true),
                WotTableColumn(prop: 'dept', label: '部门', width: 80, align: WotTableAlign.left),
                WotTableColumn(prop: 'amount', label: '金额', width: 150, align: WotTableAlign.left, sortable: true,
                    formatter: (v, _) => '¥${(v as num).toStringAsFixed(2)}'),
                WotTableColumn(prop: 'status', label: '状态', align: WotTableAlign.left,
                    formatter: (v, _) => v == '已支付' ? '✔ $v' : '$v'),
                WotTableColumn(
                    prop: 'op',
                    label: '操作',
                    width: 60,
                    align: WotTableAlign.center,
                    fixed: WotTableFixed.right,
                    builder: (_, row, i) => GestureDetector(
                          child: Text('删除',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 13)),
                          onTap: () async {
                            final ok = await WotDialog.confirm(context, message: '确认删除吗？');
                            if (ok == true) {
                              // ...
                            }
                          },
                        )),
              ],
              onSelectionChange: (sel) =>
                  demoToast(context, '选中 ${sel.length} 行'),
              footer: ['文案1', '合计', '文案2', '¥ 18535.00', '文案3', '文案4'],
            )),
        demoSection('loading 加载态'),
        demoBlock('加载中占位', WotTable(
              border: true,
              loading: true,
              maxHeight: 150,
              columns: const [
                WotTableColumn(prop: 'name', label: '姓名', width: 90),
                WotTableColumn(prop: 'age', label: '年龄'),
              ],
            )),
      ],
    );
  }
}