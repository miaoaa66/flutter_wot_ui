import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// WotImagePreview 图片预览示例页。
///
/// 该组件是**命令式全屏服务**（`WotImagePreview.show`），没有可内嵌的 widget 形态，
/// 因此本页用按钮触发，并逐个演示它的配置项。
class WotImagePreviewPage extends StatefulWidget {
  const WotImagePreviewPage({super.key});

  @override
  State<WotImagePreviewPage> createState() => _WotImagePreviewPageState();
}

class _WotImagePreviewPageState extends State<WotImagePreviewPage> {
  static const List<String> _urls = [
    'https://picsum.photos/seed/wotpv1/600/800',
    'https://picsum.photos/seed/wotpv2/800/600',
    'https://picsum.photos/seed/wotpv3/600/600',
  ];

  int _initialIndex = 0;
  bool _showIndex = true;
  bool _closeable = true;
  bool _closeOnClickOverlay = true;
  WotImagePreviewIndicatorPosition _indicator =
      WotImagePreviewIndicatorPosition.bottom;
  WotImagePreviewClosePosition _closePos =
      WotImagePreviewClosePosition.topLeft;

  String _log = '（尚无回调）';

  void _open() {
    WotImagePreview.show(
      _urls,
      context: context,
      initialIndex: _initialIndex,
      showIndex: _showIndex,
      indicatorPosition: _indicator,
      closeable: _closeable,
      closeIconPosition: _closePos,
      closeOnClickOverlay: _closeOnClickOverlay,
      onChange: (i) {
        if (!mounted) return;
        setState(() => _log = 'onChange: $i');
      },
      onOpen: () {
        if (!mounted) return;
        setState(() => _log = 'onOpen');
      },
      onClose: () {
        if (!mounted) return;
        setState(() => _log = 'onClose');
      },
    );
  }

  Widget _switchRow<T>({
    required String label,
    required T value,
    required List<T> options,
    required List<String> labels,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 116, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: [
                for (var i = 0; i < options.length; i++)
                  ChoiceChip(
                    label: Text(labels[i], style: const TextStyle(fontSize: 12)),
                    selected: value == options[i],
                    onSelected: (_) => onChanged(options[i]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotImagePreview 图片预览',
      children: [
        demoSection('配置后点击下方按钮打开预览'),
        demoBlock(
            '初始索引 initialIndex',
            Wrap(
              spacing: 6,
              children: [
                for (var i = 0; i < _urls.length; i++)
                  ChoiceChip(
                    label: Text('第 ${i + 1} 张'),
                    selected: _initialIndex == i,
                    onSelected: (_) => setState(() => _initialIndex = i),
                  ),
              ],
            )),
        _switchRow<bool>(
          label: 'showIndex 页码',
          value: _showIndex,
          options: const [true, false],
          labels: const ['true', 'false'],
          onChanged: (v) => setState(() => _showIndex = v),
        ),
        _switchRow<WotImagePreviewIndicatorPosition>(
          label: 'indicatorPosition',
          value: _indicator,
          options: WotImagePreviewIndicatorPosition.values,
          labels: const ['top', 'bottom'],
          onChanged: (v) => setState(() => _indicator = v),
        ),
        _switchRow<bool>(
          label: 'closeable 关闭按钮',
          value: _closeable,
          options: const [true, false],
          labels: const ['true', 'false'],
          onChanged: (v) => setState(() => _closeable = v),
        ),
        if (_closeable)
          _switchRow<WotImagePreviewClosePosition>(
            label: 'closeIconPosition',
            value: _closePos,
            options: WotImagePreviewClosePosition.values,
            labels: const ['topLeft', 'topRight', 'bottomLeft', 'bottomRight'],
            onChanged: (v) => setState(() => _closePos = v),
          ),
        _switchRow<bool>(
          label: '点遮罩关闭',
          value: _closeOnClickOverlay,
          options: const [true, false],
          labels: const ['true', 'false'],
          onChanged: (v) => setState(() => _closeOnClickOverlay = v),
        ),
        demoSection('打开预览'),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _open,
                child: const Text('WotImagePreview.show()'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        demoBlock('回调日志', Text(_log, style: const TextStyle(fontSize: 12))),
        demoSection('说明'),
        demoBlock(
            '组件形态',
            const Text(
              'WotImagePreview 是命令式服务，无内嵌 widget。'
              'WotImg 的 preview / previewList 内部也是调用它，'
              '详见 img 示例页的「预览」小节。',
              style: TextStyle(fontSize: 12),
            )),
        demoBlock(
            'closeable: false 时',
            const Text(
              '关闭按钮消失，只能点击遮罩退出（需 closeOnClickOverlay: true），'
              '否则无法退出预览。',
              style: TextStyle(fontSize: 12),
            )),
      ],
    );
  }
}
