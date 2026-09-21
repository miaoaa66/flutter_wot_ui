import 'package:flutter/material.dart';

import '../components/config_provider/wot_config_provider.dart';

/// 内置多语言文案表（对齐 wot 的 locale 机制）。
///
/// key 采用 `wot.<组件>.<条目>` 命名；`zh_CN` 为默认语言（缺 key 时回退），
/// `en_US` 为第二语言。自定义语言包通过 [WotConfigProvider.localeMessages]
/// 传入，**覆盖优先级高于内置表**（即可只覆盖个别 key 做微调）。
///
/// 用法（组件内）：
/// ```dart
/// Text(tr(context, 'wot.common.confirm'))
/// ```
///
/// 应用侧切换语言 / 自定义文案：
/// ```dart
/// WotConfigProvider(
///   locale: 'en_US',
///   localeMessages: {'wot.common.confirm': 'OK'}, // 覆盖任意 key
///   child: app,
/// )
/// ```
///
/// 本卡（T2.1）只定义表与取值函数，**不改任何组件**；组件内硬编码文案的
/// 替换见后续批次（T2.2 首批：calendar / table / input / video_preview / img_cropper）。
class WotMessages {
  const WotMessages._();

  /// 默认语言（缺失 key 的最终回退）。
  static const String defaultLocale = 'zh_CN';

  /// 语言代码归一化：兼容 `zh-CN` / `zh_CN` / `en-US` 等写法。
  static String normalize(String? locale) {
    if (locale == null || locale.isEmpty) return defaultLocale;
    final l = locale.replaceAll('-', '_');
    if (_builtin.containsKey(l)) return l;
    // 只匹配语言主码（zh-CN-TW -> zh_CN 也可能没有，再退主码）。
    final main = l.split('_').first;
    for (final key in _builtin.keys) {
      if (key.split('_').first == main) return key;
    }
    return defaultLocale;
  }

  /// 内置文案：locale -> key -> 文案。
  static const Map<String, Map<String, String>> _builtin = {
    'zh_CN': {
      'wot.common.confirm': '确定',
      'wot.common.cancel': '取消',
      'wot.common.done': '完成',
      'wot.common.clear': '清空',
      'wot.common.add': '添加',
      'wot.common.revoke': '撤销',
      'wot.common.restore': '恢复',
      'wot.common.loading': '加载中...',
      'wot.common.increase': '增加',
      'wot.common.decrease': '减少',
      'wot.common.search': '搜索',
      'wot.common.retry': '重试',
      'wot.table.empty': '暂无数据',
      'wot.signature.area': '手写签名区域',
      'wot.passwordInput.field': '密码输入框',
      'wot.sort.ascending': '升序',
      'wot.sort.descending': '降序',
      'wot.sort.unsorted': '未排序',
      'wot.loadmore.loading': '加载中...',
      'wot.loadmore.loadingFailed': '加载失败，重新加载',
      'wot.loadmore.noMore': '没有更多了',
      'wot.loadmore.finished': '已完成',
      'wot.common.pleaseSelect': '请选择',
      'wot.cascader.title': '选择地区',
      'wot.common.close': '关闭',
      'wot.form.validateFailed': '{label}校验未通过',
      'wot.pagination.prev': '上一页',
      'wot.pagination.next': '下一页',
      'wot.pagination.settings': '分页设置',
      'wot.pagination.total': '共 {total} 条，共 {pages} 页',
      'wot.pagination.perPage': '每页显示',
      'wot.pagination.perPageItem': '{n} 条/页',
      'wot.pagination.jumpTo': '跳转到',
      'wot.pagination.pagePrefix': '第',
      'wot.pagination.pageSuffix': '页',
      'wot.pagination.invalidPage': '请输入有效数字',
      'wot.pagination.pageRange': '请输入 1~{max} 之间的页码',
      'wot.calendar.start': '开始',
      'wot.calendar.end': '结束',
      'wot.calendar.to': '至',
      'wot.calendar.startTime': '开始时间',
      'wot.calendar.endTime': '结束时间',
      'wot.calendar.selectYearMonth': '选择年月',
      'wot.calendar.title': '选择日期',
      'wot.keyboard.title': '安全键盘',
      'wot.video.title': '视频预览',
      'wot.video.fullscreen': '全屏',
      'wot.video.close': '关闭',
      'wot.video.loadFailed': '视频加载失败',
      'wot.video.forward15': '快进15秒',
      'wot.video.rewind15': '快退15秒',
    },
    'en_US': {
      'wot.common.confirm': 'Confirm',
      'wot.common.cancel': 'Cancel',
      'wot.common.done': 'Done',
      'wot.common.clear': 'Clear',
      'wot.common.add': 'Add',
      'wot.common.revoke': 'Undo',
      'wot.common.restore': 'Redo',
      'wot.common.loading': 'Loading...',
      'wot.common.increase': 'Increase',
      'wot.common.decrease': 'Decrease',
      'wot.common.search': 'Search',
      'wot.common.retry': 'Retry',
      'wot.table.empty': 'No Data',
      'wot.signature.area': 'Signature Area',
      'wot.passwordInput.field': 'Password Input',
      'wot.sort.ascending': 'Ascending',
      'wot.sort.descending': 'Descending',
      'wot.sort.unsorted': 'Unsorted',
      'wot.loadmore.loading': 'Loading...',
      'wot.loadmore.loadingFailed': 'Load failed, tap to retry',
      'wot.loadmore.noMore': 'No more data',
      'wot.loadmore.finished': 'Finished',
      'wot.common.pleaseSelect': 'Please Select',
      'wot.cascader.title': 'Select Region',
      'wot.common.close': 'Close',
      'wot.form.validateFailed': '{label} validation failed',
      'wot.pagination.prev': 'Previous Page',
      'wot.pagination.next': 'Next Page',
      'wot.pagination.settings': 'Pagination Settings',
      'wot.pagination.total': 'Total {total} items in {pages} pages',
      'wot.pagination.perPage': 'Per Page',
      'wot.pagination.perPageItem': '{n} / page',
      'wot.pagination.jumpTo': 'Jump to',
      'wot.pagination.pagePrefix': ' ',
      'wot.pagination.pageSuffix': 'Page',
      'wot.pagination.invalidPage': 'Please enter a valid number',
      'wot.pagination.pageRange': 'Please enter a page number between 1 and {max}',
      'wot.calendar.start': 'Start',
      'wot.calendar.end': 'End',
      'wot.calendar.to': 'To',
      'wot.calendar.startTime': 'Start Time',
      'wot.calendar.endTime': 'End Time',
      'wot.calendar.selectYearMonth': 'Select Year & Month',
      'wot.calendar.title': 'Select Date',
      'wot.keyboard.title': 'Secure Keyboard',
      'wot.video.title': 'Video Preview',
      'wot.video.fullscreen': 'Fullscreen',
      'wot.video.close': 'Close',
      'wot.video.loadFailed': 'Failed to load video',
      'wot.video.forward15': 'Forward 15s',
      'wot.video.rewind15': 'Rewind 15s',
    },
  };

  /// 按 locale 与 key 取内置文案（供测试 / 自定义语言包派生使用）。
  static String? builtinValue(String? locale, String key) {
    final table = _builtin[normalize(locale)];
    return table?[key];
  }
}

/// 组件内取文案的统一入口。
///
/// [params] 用于占位符替换：文案中的 `{name}` 会被替换为 [params] 中同名键的字符串形式。
/// 例如内置文案「共 {total} 条，共 {pages} 页」配合
/// `tr(context, 'wot.pagination.total', params: {'total': 120, 'pages': 6})` 使用。
/// 占位符替换对自定义语言包同样生效。
///
/// 取值优先级：**自定义语言包（[WotConfigProvider.localeMessages]） >
/// 内置表（按当前 locale）> 内置默认语言表 > [fallback] > key 本身**。
///
/// 不依赖 [WotConfigProvider] 时（无 Provider 包裹）按默认语言 `zh_CN` 取值，
/// 因此组件内可以放心直接调用、不需要判空。
String tr(BuildContext context, String key,
    {String? fallback, Map<String, Object?> params = const {}}) {
  final scope = WotConfigProvider.of(context);
  final locale = WotMessages.normalize(scope.locale);

  // 1) 用户自定义语言包优先（可只覆盖个别 key）。
  var result = scope.messages?[key] ?? '';

  // 2) 内置表按当前 locale，缺 key 回退默认语言表。
  if (result.isEmpty) result = WotMessages.builtinValue(locale, key) ?? '';

  // 3) 显式回退 / key 本身（方便发现漏配的 key）。
  if (result.isEmpty) result = fallback ?? key;

  // 4) 占位符替换：文案中的 {name} 替换为 params 同名键的值。
  //    对自定义语言包与 fallback 同样生效（无对应占位符时原样保留）。
  if (params.isNotEmpty) {
    params.forEach((name, value) {
      result = result.replaceAll('{$name}', '$value');
    });
  }
  return result;
}
