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
              WotButton(text: '文本', size: WotButtonSize.small, onClick: () => WotToast.text(context, '轻提示')),
              WotButton(text: '成功', size: WotButtonSize.small, type: WotButtonType.success, onClick: () => WotToast.success(context, '操作成功')),
              WotButton(text: '失败', size: WotButtonSize.small, type: WotButtonType.danger, onClick: () => WotToast.error(context, '操作失败')),
              WotButton(text: '加载中', size: WotButtonSize.small, onClick: () => WotToast.loading(context, '加载中')),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotNotify 顶部通知'),
          Wrap(spacing: 8, children: [
            WotButton(text: '通知', size: WotButtonSize.small, onClick: () => WotNotify.success(context, '这是顶部通知')),
            WotButton(text: '警告', size: WotButtonSize.small, type: WotButtonType.warning, onClick: () => WotNotify.warning(context, '请注意')),
            WotButton(text: '错误', size: WotButtonSize.small, type: WotButtonType.danger, onClick: () => WotNotify.error(context, '出错了')),
          ]),
          const SizedBox(height: 20),
          _section('WotDialog 对话框（命令式 confirm / alert）'),
          Wrap(spacing: 8, children: [
            WotButton(text: '确认框', size: WotButtonSize.small, onClick: () async {
              final ok = await WotDialog.confirm(context, message: '确定要删除吗？', title: '提示');
              _toast('结果：$ok');
            }),
            WotButton(text: '提示框', size: WotButtonSize.small, onClick: () {
              WotDialog.alert(context, message: '这是一个提示消息');
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
          WotButton(text: '打开弹出层', size: WotButtonSize.small, onClick: () => setState(() => _popup = true)),
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
              panel: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: const WotText('筛选面板内容'),
                )
              ),
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
      child: WotText(title, type: WotTextType.secondary, strong: true),
    );
  }
}