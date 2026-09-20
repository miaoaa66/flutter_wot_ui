import 'package:flutter/material.dart';

import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';

/// 加载更多状态。
enum WotLoadmoreState { loading, loadingFailed, noMore, finished }

/// 加载更多，对应 wot `wd-loadmore`。
///
/// 参数对齐 wot：`state`（当前状态，`loading`/`finished`/`loadingFailed`）、
/// `loadingText`/`loadMoreText`（加载文案）、`loadingSpinner`（加载中转圈）、
/// `loadingFailedText`/`failedText`（加载失败状态文案与提示）、
/// `finishedText`（完成文案）、`noMoreText`（没有更多文案）、`line`（是否显示分割线）、
/// `loadMore`/`onLoadMore`/`onLoadmore`（加载失败点击重试回调）。
class WotLoadmore extends StatelessWidget {
  const WotLoadmore({
    super.key,
    this.state,
    this.loading,
    this.loadingText,
    this.loadingSpinner = true,
    this.loadingFailedText,
    this.noMoreText,
    this.finishedText,
    this.line = false,
    this.onLoadmore,
    this.loadMoreText,
    this.failedText,
    this.onLoadMore,
  });

  /// 加载状态；为空时用 [loading] 推导（true → loading, false → nomore）。
  final WotLoadmoreState? state;

  /// 兼容 wot `loading` 布尔参数。
  final bool? loading;

  /// 加载中状态文案；默认“加载中...”。
  final String? loadingText;

  /// 加载中是否显示旋转动画指示器；默认 true。
  final bool loadingSpinner;

  /// 加载失败状态文案；默认“加载失败，重新加载”。
  final String? loadingFailedText;

  /// 没有更多状态文案；默认“没有更多了”。
  final String? noMoreText;

  /// 加载完成状态文案；默认“已完成”。
  final String? finishedText;

  /// 是否显示上下分割线。
  final bool line;

  /// 加载失败点击重试回调（旧名，保留兼容）。
  final VoidCallback? onLoadmore;

  /// 加载中展示的文案覆盖；为空时使用 [loadingText]。
  final String? loadMoreText;

  /// 加载失败展示的文案覆盖；为空时使用 [loadingFailedText]。
  final String? failedText;

  /// 加载失败点击重试回调（对齐 wot `loadMore`/`reload`）。
  final VoidCallback? onLoadMore;

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
            Text(loadMoreText ?? loadingText ?? tr(context, 'wot.loadmore.loading'),
                style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
          ],
        );
      case WotLoadmoreState.loadingFailed:
        content = GestureDetector(
          onTap: () {
            onLoadMore?.call();
            onLoadmore?.call();
          },
          child: Text(
              failedText ?? loadingFailedText ?? tr(context, 'wot.loadmore.loadingFailed'),
              style: TextStyle(fontSize: 12, color: scheme.dangerMain)),
        );
      case WotLoadmoreState.noMore:
        content = Text(noMoreText ?? tr(context, 'wot.loadmore.noMore'),
            style: TextStyle(fontSize: 12, color: scheme.textAuxiliary));
      case WotLoadmoreState.finished:
        content = Text(finishedText ?? tr(context, 'wot.loadmore.finished'),
            style: TextStyle(fontSize: 12, color: scheme.textAuxiliary));
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