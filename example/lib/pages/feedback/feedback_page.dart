import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 反馈 feedback 组件演示页。
class WotFeedbackPage extends StatefulWidget {
  const WotFeedbackPage({super.key});

  @override
  State<WotFeedbackPage> createState() => _WotFeedbackPageState();
}

class _WotFeedbackPageState extends State<WotFeedbackPage> {
  bool _popup = false;
  final int _progress = 60;
  final double _circle = 75;
  String _sortValue = '综合';
  String _priceValue = '不限';

  // 引导高亮目标：分别定位到页内的“轻提示/确认框/弹出层”按钮。
  final GlobalKey _tourKey1 = GlobalKey();
  final GlobalKey _tourKey2 = GlobalKey();
  final GlobalKey _tourKey3 = GlobalKey();

  /// 启动新手引导，依次高亮三个目标控件。
  void _startTour() {
    WotTour.show(
      context,
      steps: [
        WotTourStep(
          target: _tourKey1,
          title: '第一步 · 轻提示',
          description: '这里使用 WotToast 命令式弹出轻提示，点击文本按钮可触发。',
        ),
        WotTourStep(
          target: _tourKey2,
          title: '第二步 · 确认框',
          description: '通过 WotDialog.confirm 弹出删除确认框，返回结果后 Toast 提示。',
        ),
        WotTourStep(
          target: _tourKey3,
          title: '第三步 · 弹出层',
          description: '点击该按钮从屏幕底部弹出 WotPopup 面板。',
        ),
      ],
      onFinish: () => _toast('引导完成'),
      onSkip: () => _toast('已跳过引导'),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('反馈组件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('WotToast 轻提示（命令式，Overlay+队列）'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WotButton(text: '文本', key: _tourKey1, size: WotButtonSize.small, onClick: () => WotToast.text(context, '轻提示')),
              WotButton(text: '成功', size: WotButtonSize.small, type: WotButtonType.success, onClick: () => WotToast.success(context, '操作成功')),
              WotButton(text: '失败', size: WotButtonSize.small, type: WotButtonType.danger, onClick: () => WotToast.error(context, '操作失败')),
              WotButton(text: '加载中', size: WotButtonSize.small, onClick: () => WotToast.loading(context, '加载中')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            WotButton(text: '顶部', size: WotButtonSize.small, onClick: () => WotToast.text(context, '顶部提示', position: 'top')),
            WotButton(text: '居中', size: WotButtonSize.small, onClick: () => WotToast.text(context, '居中提示', position: 'center')),
            WotButton(text: '底部', size: WotButtonSize.small, onClick: () => WotToast.text(context, '底部提示', position: 'bottom')),
            WotButton(text: '自定义图标', size: WotButtonSize.small, type: WotButtonType.primary, onClick: () => WotToast.show(context, '自定义图标', icon: Icons.favorite)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            WotButton(text: '警告(便捷)', size: WotButtonSize.small, type: WotButtonType.warning, onClick: () => WotToast.warning(context, '警告便捷方法', position: 'bottom')),
            WotButton(text: '信息(便捷)', size: WotButtonSize.small, type: WotButtonType.info, onClick: () => WotToast.info(context, '信息便捷方法', position: 'top')),
          ]),
          const SizedBox(height: 20),
          _section('WotNotify 顶部通知'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            WotButton(text: '通知', size: WotButtonSize.small, onClick: () => WotNotify.success(context, '这是顶部通知')),
            WotButton(text: '警告', size: WotButtonSize.small, type: WotButtonType.warning, onClick: () => WotNotify.warning(context, '请注意')),
            WotButton(text: '错误', size: WotButtonSize.small, type: WotButtonType.danger, onClick: () => WotNotify.error(context, '出错了')),
            WotButton(text: '自定义type', size: WotButtonSize.small, type: WotButtonType.info, onClick: () => WotNotify.show(context, message: 'primary 类型通知', type: WotNotifyType.primary, onClose: () => _toast('通知已关闭'))),
          ]),
          const SizedBox(height: 8),
          WotButton(
            text: 'onClose 回调查看',
            size: WotButtonSize.small,
            type: WotButtonType.warning,
            onClick: () => WotNotify.show(
              context,
              message: '3 秒后自动关闭并触发 onClose',
              type: WotNotifyType.info,
              onClose: () => _toast('onClose 已触发'),
            ),
          ),
          const SizedBox(height: 20),
          _section('WotDialog 对话框（命令式 confirm / alert）'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            WotButton(text: '确认框', key: _tourKey2, size: WotButtonSize.small, onClick: () async {
              final ok = await WotDialog.confirm(context, message: '确定要删除吗？', title: '提示');
              _toast('结果：$ok');
            }),
            WotButton(text: '提示框', size: WotButtonSize.small, onClick: () {
              WotDialog.alert(context, message: '这是一个提示消息');
            }),
            WotButton(text: '显示关闭', size: WotButtonSize.small, onClick: () {
              WotDialog.alert(
                context,
                title: '提示',
                message: '右上角有关闭按钮',
                showClose: true,
                onClose: () => _toast('点击了关闭'),
              );
            }),
            WotButton(text: '隐藏确定', size: WotButtonSize.small, onClick: () async {
              final ok = await WotDialog.confirm(context, title: '提示', message: '仅保留取消按钮', showConfirmButton: false);
              _toast('结果：$ok');
            }),
            WotButton(text: '自定义按钮文案', size: WotButtonSize.small, onClick: () async {
              final ok = await WotDialog.confirm(
                context,
                title: '提示',
                message: '自定义确定/取消文案',
                showClose: true,
                confirmButtonText: '保存',
                cancelButtonText: '暂不',
                onConfirm: () => _toast('点了保存'),
                onCancel: () => _toast('点了暂不'),
                onClose: () => _toast('点了关闭'),
              );
              _toast('结果：$ok');
            }),
          ]),
          const SizedBox(height: 20),
          _section('WotActionSheet 操作菜单'),
          WotButton(
            text: '弹出选项',
            size: WotButtonSize.small,
            onClick: () async {
              final r = await WotActionSheet.show(context, actions: const [
                WotActionSheetItem(name: '分享'),
                WotActionSheetItem(name: '编辑', color: Color(0xFF4480FF)),
                WotActionSheetItem(name: '删除', color: Color(0xFFF14646)),
              ], title: '请选择操作');
              if (r != null) _toast('选择：${r.name}');
            },
          ),
          const SizedBox(height: 8),
          WotButton(
            text: 'showCancel=false + 回调',
            size: WotButtonSize.small,
            type: WotButtonType.primary,
            onClick: () async {
              final r = await WotActionSheet.show(
                context,
                actions: const [
                  WotActionSheetItem(name: '拍照'),
                  WotActionSheetItem(name: '相册'),
                ],
                title: '选择图片来源',
                showCancel: false,
                onSelect: (item) => _toast('选中：${item.name}'),
                onCancel: () => _toast('已取消'),
              );
              if (r != null) _toast('选择返回：${r.name}');
            },
          ),
          const SizedBox(height: 20),
          _section('WotProgress / WotCircle'),
          WotProgress(modelValue: _progress),
          const SizedBox(height: 8),
          WotProgress(modelValue: _progress, textInside: true, showText: true),
          const SizedBox(height: 8),
          WotCircle(modelValue: _circle, size: 200),
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: WotCircle(modelValue: _circle,)
          ),
          const SizedBox(height: 20),
          _section('WotPopup 弹出层 / WotNoticeBar 公告'),
          WotButton(text: '打开弹出层', key: _tourKey3, size: WotButtonSize.small, onClick: () => setState(() => _popup = true)),
          if (_popup)
            WotPopup(
              visible: _popup,
              onClose: () => setState(() => _popup = false),
              child: SizedBox(height: 200, width: double.infinity, child: Center(child: WotText('弹出内容'))),
            ),
          const SizedBox(height: 12),
          WotNoticeBar(text: '这是一条公告消息，用于提示用户重要信息。', closeable: true),
          const SizedBox(height: 20),
          _section('WotCountDown / WotCountTo / WotSortButton'),
          WotCountDown(value: 3600 * 1000),
          const SizedBox(height: 8),
          WotCountTo(modelValue: 1234567, prefix: '¥ ', suffix: ' 元'),
          const SizedBox(height: 8),
          WotSortButton(text: '年龄'),
          WotSortButton(),
          const SizedBox(height: 20),
          _section('WotTooltip / WotPopover 气泡'),
          WotTooltip(content: '这是一个气泡提示', child: WotButton(text: '悬停我', size: WotButtonSize.small)),
          const SizedBox(height: 4),
          WotTooltip(content: '点击触发', trigger: 'click', child: WotButton(text: '点击我', size: WotButtonSize.small)),
          const SizedBox(height: 8),
          WotPopover(
            content: const [Text('选项一'), Text('选项二')],
            child: WotButton(text: '弹出气泡', size: WotButtonSize.small),
            onClick: (i) => _toast('点击 $i'),
          ),
          const SizedBox(height: 20),
          _section('WotDropMenu 下拉菜单'),
          WotDropMenu(menus: [
            WotDropMenuItem(
              title: '综合排序',
              panel: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _dropOption('综合', 0),
                  _dropOption('销量', 1),
                  _dropOption('价格', 2),
                ]),
              ),
            ),
            WotDropMenuItem(
              title: '筛选',
              panel: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: const WotText('筛选面板内容'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _section('WotDropMenu 下拉菜单（options 驱动）'),
          WotDropMenu(menus: [
            WotDropMenuItem(
              modelValue: _sortValue,
              onChange: (v) => setState(() => _sortValue = v as String),
              options: const [
                WotDropMenuOption(label: '综合', value: '综合'),
                WotDropMenuOption(label: '销量', value: '销量'),
                WotDropMenuOption(label: '价格', value: '价格'),
              ],
            ),
            WotDropMenuItem(
              title: '价格',
              modelValue: _priceValue,
              closeOnClick: false,
              onChange: (v) => setState(() => _priceValue = v as String),
              options: const [
                WotDropMenuOption(label: '不限', value: '不限'),
                WotDropMenuOption(label: '10-50元', value: '10-50'),
                WotDropMenuOption(label: '50-100元', value: '50-100'),
                WotDropMenuOption(label: '100元以上', value: '100+'),
              ],
            ),
          ]),
          const SizedBox(height: 20),
          _section('WotFloatingPanel 底部浮动面板'),
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                Container(color: scheme.filledStrong),
                WotFloatingPanel(
                  header: const Text('浮动面板'),
                  child: const Center(child: WotText('拖动把手调整高度')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _section('WotSwipeAction 左滑操作（左滑内容）'),
          WotSwipeAction(
            actions: wotSwipeActions(onDelete: () => _toast('已删除')),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: scheme.filledOppo,
              child: const Row(
                children: [WotIcon(name: 'user', size: 16), SizedBox(width: 8), WotText('左滑显示操作')],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _section('WotEmpty 空状态'),
          const WotEmpty(description: '暂无数据'),
          const SizedBox(height: 20),
          _section('WotTour 新手引导（高亮页内控件）'),
          WotButton(
            text: '开始引导',
            size: WotButtonSize.small,
            type: WotButtonType.primary,
            onClick: _startTour,
          ),
          const SizedBox(height: 8),
          WotText(
            '点击“开始引导”，会依次高亮上方「轻提示」「确认框」「弹出层」三个按钮并展示说明。',
            type: WotTextType.wotDefault,
          ),
        ],
      ),
    );
  }

  Widget _dropOption(String t, int i) {
    return InkWell(
      onTap: () => _toast('选择 $t'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.centerLeft,
        child: Text(t, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(title, type: WotTextType.wotDefault, bold: true),
    );
  }
}