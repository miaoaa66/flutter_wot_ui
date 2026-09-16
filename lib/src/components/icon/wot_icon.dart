import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../../icon/iconfont_map.dart';

/// wot 官方图标字体的默认字体族名。
///
/// 仅供使用者在自行注册 wot 官方 `iconfont.ttf` 后用于构造 [IconData]。
/// 注意：本项目默认不打包 wot 图标字体二进制，故 [WotIcon] 使用 [WotIconResolver]
/// 的 Material 兜底渲染；名→码点对应关系见 [WotIconFont]。
const String kWotIconFontFamily = 'WotIcons';

/// wot 图标名称到 Flutter 内置 [IconData] 的兜底映射。
///
/// 本项目默认不打包 wot 的 iconfont.ttf 二进制（保持仓库洁净、规避字体许可证风险），
/// 因而 [WotIcon] 以 Flutter 内置 Material Icons 渲染；未命中的名称回退到 [WotIconResolver.fallback]。
class WotIconResolver {
  WotIconResolver._();

  static const Map<String, IconData> _map = {
    // 常用图标（wot 惯用名）
    'add': Icons.add,
    'add-circle': Icons.add_circle,
    'minus': Icons.remove,
    'close': Icons.close,
    'delete': Icons.delete,
    'search': Icons.search,
    'refresh': Icons.refresh,
    'loading': Icons.autorenew,
    'success': Icons.check_circle,
    'success-outline': Icons.check_circle_outline,
    'warning': Icons.warning_amber_rounded,
    'info': Icons.info,
    'error': Icons.cancel,
    'arrow-left': Icons.arrow_back_ios_new,
    'arrow-right': Icons.arrow_forward_ios,
    'arrow-down': Icons.keyboard_arrow_down,
    'arrow-up': Icons.keyboard_arrow_up,
    'back': Icons.arrow_back_ios_new,
    'close-copy': Icons.cancel,
    'check': Icons.check,
    'checked': Icons.check_circle,
    'ellipsis': Icons.more_horiz,
    'more': Icons.more_vert,
    'star': Icons.star,
    'star-o': Icons.star_border,
    'heart': Icons.favorite,
    'heart-o': Icons.favorite_border,
    'eye': Icons.visibility,
    'eye-close': Icons.visibility_off,
    'setting': Icons.settings,
    'settings': Icons.settings,
    'home': Icons.home,
    'user': Icons.person,
    'person': Icons.person,
    'phone': Icons.phone,
    'location': Icons.location_on,
    'calendar': Icons.calendar_today,
    'calendar-line': Icons.calendar_today,
    'clock': Icons.access_time,
    'scan': Icons.qr_code_scanner,
    'qr': Icons.qr_code,
    'qrcode': Icons.qr_code,
    'edit': Icons.edit,
    'filter': Icons.filter_list,
    'sort': Icons.swap_vert,
    'image': Icons.image,
    'camera': Icons.camera_alt,
    'video': Icons.videocam,
    'play': Icons.play_arrow,
    'pause': Icons.pause,
    'record': Icons.fiber_manual_record,
    'send': Icons.send,
    'share': Icons.share,
    'double-left': Icons.skip_previous,
    'double-right': Icons.skip_next,
    'minus-circle': Icons.remove_circle_outline,
    'wrong': Icons.error_outline,
    'empty': Icons.inbox_outlined,
    'text': Icons.notes,
    'view': Icons.visibility,
    'message': Icons.chat_bubble_outline,
    'chat': Icons.mail_outline,
    'question': Icons.help_outline,
    'info-circle': Icons.info_outline,
    'close-circle': Icons.cancel,
    'right': Icons.chevron_right,
    'left': Icons.chevron_left,
    'up': Icons.keyboard_arrow_up,
    'down': Icons.keyboard_arrow_down,
    'category': Icons.grid_view,
    'management': Icons.apps,
    'mine': Icons.person,
    'goods': Icons.shopping_bag_outlined,
    'cart': Icons.shopping_cart,
    'service': Icons.support_agent,
    'coupon': Icons.local_activity,
    'exchange': Icons.swap_horiz,
    'list': Icons.list,
    'newspaper': Icons.article_outlined,
    'scanning': Icons.qr_code_scanner,
    'play-fill': Icons.play_circle_fill,
    'download': Icons.download,
    'upload': Icons.upload,
    'moon': Icons.dark_mode_outlined,
    'sun': Icons.light_mode_outlined,
  };

  /// 兜底图标。
  static const IconData fallback = Icons.square;

  /// 将 wot 名称解析为 [IconData]。
  static IconData resolve(String? name) {
    if (name == null || name.isEmpty) return fallback;
    // 归一化分隔符：下划线与空格都按中划线处理，再转小写。
    final normalized = normalizeName(name);
    return _map[normalized] ?? _map[name.trim()] ?? fallback;
  }

  /// 名称归一化：去首尾空格，`_` / 空格 → `-`，并转小写。
  static String normalizeName(String name) =>
      name.trim().replaceAll('_', '-').replaceAll(' ', '-').toLowerCase();
}

/// 图标组件，对应 wot `wd-icon`。
///
/// 参数对齐 wot：`name`（图标名）、`size`、`color`、`classPrefix`（兼容保留）。
/// 通过 [WotIconResolver] 渲染（Material 兜底）；如需 wot 官方字形，
/// 请自行注册 `iconfont.ttf` 并用 [WotIconFont.codePointOf] 构造 [IconData]。
class WotIcon extends StatelessWidget {
  const WotIcon({
    super.key,
    this.name,
    this.size,
    this.color,
    @Deprecated('classPrefix 从未生效，将在后续版本移除。') this.classPrefix = 'wot-icon',
    this.onClick,
  });

  /// 图标名称（wot 命名的中划线名，如 `arrow-left`）；含 `/` 时视为图片路径（暂不支持）。
  final String? name;

  /// 图标尺寸（逻辑像素）。
  final double? size;

  /// 图标颜色；为空时取语义图标主色。
  final Color? color;

  /// **已废弃**：wot 的 CSS class 前缀，Flutter 没有 class 概念，该参数从未参与解析。
  @Deprecated('classPrefix 从未生效（Flutter 无 CSS class 语义），将在后续版本移除。')
  final String classPrefix;

  /// 点击回调。
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final icon = Icon(
      WotIconResolver.resolve(name),
      size: size,
      color: color ?? scheme.iconMain,
    );
    if (onClick == null) return icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
      child: icon,
    );
  }
}