import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 加载更多状态。
enum WotLoadmoreState { loading, loadingFailed, noMore, finished }

/// 加载更多，对应 wot `wd-loadmore`。
///
/// 参数对齐 wot：`state`（当前状态）、`loadingText`/`loadingSpinner`（加载中）、
/// `loadingFailedText`/`loadingFailedIcon`（加载失败状态文案与提示）、
/// `noMoreText`（没有更多文案）、`finishedText`（完成文案）、`line`（是否显示分割线）、
/// `onLoadmore`（点击加载更多回调）。
class WotLoadmore extends StatelessWidget {
  const WotLoadmore({
    super.key,
    this.state,
    this.loading,
    this.loadingText = '加载中...',
    this.loadingSpinner = true,
    this.loadingFailedText = '加载失败，重新加载',
    this.noMoreText = '没有更多了',
    this.finishedText = '已完成',
    this.line = false,
    this.onLoadmore,
  });

  /// 加载状态；为空时用 [loading] 推导（true → loading, false → nomore）。
  final WotLoadmoreState? state;

  /// 兼容 wot `loading` 布尔参数。
  final bool? loading;

  final String loadingText;
  final bool loadingSpinner;
  final String loadingFailedText;
  final String noMoreText;
  final String finishedText;

  /// 是否显示上下分割线。
  final bool line;

  /// 加载失败点击重试回调。
  final VoidCallback? onLoadmore;

  WotLoadmoreState get _state {
    if (state != null) return state!;
    if (loading != null) return loading! ? WotLoadmoreState.loading : WotLoadmoreState.noMore;
    return WotLoadmoreState.loading;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final s = _state;

    Widget content;
    switch (s) {
      case WotLoadmoreState.loading:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loadingSpinner)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(scheme.textAuxiliary),
                ),
              ),
            if (loadingSpinner) const SizedBox(width: 6),
            Text(loadingText, style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
          ],
        );
      case WotLoadmoreState.loadingFailed:
        content = GestureDetector(
          onTap: onLoadmore,
          child: Text(loadingFailedText, style: TextStyle(fontSize: 12, color: scheme.dangerMain)),
        );
      case WotLoadmoreState.noMore:
        content = Text(noMoreText, style: TextStyle(fontSize: 12, color: scheme.textAuxiliary));
      case WotLoadmoreState.finished:
        content = Text(finishedText, style: TextStyle(fontSize: 12, color: scheme.textAuxiliary));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: line
            ? Border(
                bottom: BorderSide(color: scheme.borderLight),
                top: BorderSide(color: scheme.borderLight),
              )
            : null,
      ),
      child: content,
    );
  }
}