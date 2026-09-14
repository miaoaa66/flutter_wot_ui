// 批次 E 冒烟：逐页渲染 + 滚动，捕获 RenderFlex 溢出 / 布局异常（非布局的插件/网络异常仅记录不 fail）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import 'package:flutter_wot_ui_example/pages/basic/wot_button_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_cell_group_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_cell_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_divider_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_fab_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_gap_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_icon_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_loading_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_overlay_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_row_col_page.dart';
import 'package:flutter_wot_ui_example/pages/basic/wot_text_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_backtop_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_index_bar_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_navbar_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_pagination_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_segmented_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_sidebar_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_tabbar_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_tabs_page.dart';
import 'package:flutter_wot_ui_example/pages/nav/wot_transition_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_action_sheet_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_circle_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_count_down_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_count_to_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_dialog_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_drop_menu_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_empty_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_floating_panel_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_notice_bar_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_notify_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_popover_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_popup_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_progress_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_sort_button_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_swipe_action_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_toast_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_tooltip_page.dart';
import 'package:flutter_wot_ui_example/pages/feedback/wot_tour_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_avatar_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_badge_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_barcode_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_card_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_collapse_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_expand_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_curtain_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_grid_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_img_cropper_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_img_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_loadmore_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_qr_code_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_skeleton_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_steps_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_swiper_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_table_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_tag_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_video_preview_page.dart';
import 'package:flutter_wot_ui_example/pages/display/wot_watermark_page.dart';

// 录入 form 分类（一组件一页）逐个冒烟。
import 'package:flutter_wot_ui_example/pages/form/wot_calendar_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_cascader_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_checkbox_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_datetime_picker_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_form_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_input_number_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_input_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_keyboard_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_password_input_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_picker_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_picker_view_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_radio_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_rate_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_search_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_select_picker_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_signature_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_slide_verify_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_slider_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_switch_page.dart';
import 'package:flutter_wot_ui_example/pages/form/wot_upload_page.dart';

Widget _app(Widget home) => WotConfigProvider(
      wotTheme: WotThemeData.light,
      child: MaterialApp(home: home, debugShowCheckedModeBanner: false),
    );

Future<void> _smoke(WidgetTester tester, String name, Widget home) async {
  await tester.pumpWidget(_app(home));
  await tester.pump(const Duration(milliseconds: 500));

  // 向下滚动触发 ListView 懒加载项渲染。
  final scroll = find.byType(Scrollable).first;
  for (var i = 0; i < 8; i++) {
    await tester.drag(scroll, const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 180));
  }
  // 滚动回顶。
  for (var i = 0; i < 8; i++) {
    await tester.drag(scroll, const Offset(0, 350));
    await tester.pump(const Duration(milliseconds: 120));
  }
  await tester.pump(const Duration(seconds: 1));

  // 消费所有异常，仅对布局溢出 fail；插件/网络异常记录不 fail。
  bool overflow = false;
  var other = 0;
  Object? ex;
  while ((ex = tester.takeException()) != null) {
    final s = ex.toString();
    if (s.contains('overflowed') || s.contains('RenderFlex')) {
      overflow = true;
      debugPrint('[$name] 布局溢出: $s');
    } else {
      other++;
    }
  }
  debugPrint('[$name] 渲染完成：overflow=$overflow, 非布局异常数=$other');
  if (overflow) {
    fail('$name 出现布局溢出');
  }
}

void main() {
  // 基础basic：一组件一页，逐页冒烟。
  final basicPages = <(String, Widget Function())>[
    ('button', () => const WotButtonPage()),
    ('icon', () => const WotIconPage()),
    ('text', () => const WotTextPage()),
    ('cell', () => const WotCellPage()),
    ('cell_group', () => const WotCellGroupPage()),
    ('row_col', () => const WotRowColPage()),
    ('gap', () => const WotGapPage()),
    ('divider', () => const WotDividerPage()),
    ('overlay', () => const WotOverlayPage()),
    ('loading', () => const WotLoadingPage()),
    ('fab', () => const WotFabPage()),
  ];
  for (final (name, builder) in basicPages) {
    testWidgets('基础页 $name 渲染 + 滚动无溢出', (t) => _smoke(t, 'basic/$name', builder()));
  }

  // 导航 nav：一组件一页，逐页冒烟。
  final navPages = <(String, Widget Function())>[
    ('navbar', () => const WotNavbarPage()),
    ('tabs', () => const WotTabsPage()),
    ('tabbar', () => const WotTabbarPage()),
    ('segmented', () => const WotSegmentedPage()),
    ('sidebar', () => const WotSidebarPage()),
    ('pagination', () => const WotPaginationPage()),
    ('index_bar', () => const WotIndexBarPage()),
    ('backtop', () => const WotBacktopPage()),
    ('transition', () => const WotTransitionPage()),
  ];
  for (final (name, builder) in navPages) {
    testWidgets('导航页 $name 渲染 + 滚动无溢出', (t) => _smoke(t, 'nav/$name', builder()));
  }

  // 反馈 feedback：一组件一页，逐页冒烟。
  final feedbackPages = <(String, Widget Function())>[
    ('toast', () => const WotToastPage()),
    ('notify', () => const WotNotifyPage()),
    ('dialog', () => const WotDialogPage()),
    ('action_sheet', () => const WotActionSheetPage()),
    ('progress', () => const WotProgressPage()),
    ('circle', () => const WotCirclePage()),
    ('popup', () => const WotPopupPage()),
    ('notice_bar', () => const WotNoticeBarPage()),
    ('count_down', () => const WotCountDownPage()),
    ('count_to', () => const WotCountToPage()),
    ('sort_button', () => const WotSortButtonPage()),
    ('tooltip', () => const WotTooltipPage()),
    ('popover', () => const WotPopoverPage()),
    ('drop_menu', () => const WotDropMenuPage()),
    ('floating_panel', () => const WotFloatingPanelPage()),
    ('swipe_action', () => const WotSwipeActionPage()),
    ('empty', () => const WotEmptyPage()),
    ('tour', () => const WotTourPage()),
  ];
  for (final (name, builder) in feedbackPages) {
    testWidgets('反馈页 $name 渲染 + 滚动无溢出', (t) => _smoke(t, 'feedback/$name', builder()));
  }

  // 展示 display：一组件一页，逐页冒烟。
  final displayPages = <(String, Widget Function())>[
    ('tag', () => const WotTagPage()),
    ('badge', () => const WotBadgePage()),
    ('avatar', () => const WotAvatarPage()),
    ('card', () => const WotCardPage()),
    ('grid', () => const WotGridPage()),
    ('collapse', () => const WotCollapsePage()),
    ('expand', () => const WotExpandPage()),
    ('steps', () => const WotStepsPage()),
    ('skeleton', () => const WotSkeletonPage()),
    ('loadmore', () => const WotLoadmorePage()),
    ('img', () => const WotImgPage()),
    ('swiper', () => const WotSwiperPage()),
    ('table', () => WotTablePage()),
    ('watermark', () => const WotWatermarkPage()),
    ('qrcode', () => const WotQrCodePage()),
    ('barcode', () => const WotBarcodePage()),
    ('curtain', () => const WotCurtainPage()),
    ('img_cropper', () => const WotImgCropperPage()),
    ('video_preview', () => const WotVideoPreviewPage()),
  ];
  for (final (name, builder) in displayPages) {
    testWidgets('展示页 $name 渲染 + 滚动无溢出', (t) => _smoke(t, 'display/$name', builder()));
  }

  // 录入 form：一组件一页，逐页冒烟。
  final formPages = <(String, Widget Function())>[
    ('form', () => const WotFormPage()),
    ('input', () => const WotInputPage()),
    ('input_number', () => const WotInputNumberPage()),
    ('search', () => const WotSearchPage()),
    ('checkbox', () => const WotCheckboxPage()),
    ('radio', () => const WotRadioPage()),
    ('switch', () => const WotSwitchPage()),
    ('rate', () => const WotRatePage()),
    ('slider', () => const WotSliderPage()),
    ('select_picker', () => const WotSelectPickerPage()),
    ('picker', () => const WotPickerPage()),
    ('picker_view', () => const WotPickerViewPage()),
    ('cascader', () => const WotCascaderPage()),
    ('calendar', () => const WotCalendarPage()),
    ('datetime_picker', () => const WotDatetimePickerPage()),
    ('signature', () => const WotSignaturePage()),
    ('upload', () => const WotUploadPage()),
    ('password_input', () => const WotPasswordInputPage()),
    ('slide_verify', () => const WotSlideVerifyPage()),
    ('keyboard', () => const WotKeyboardPage()),
  ];
  for (final (name, builder) in formPages) {
    testWidgets('录入页 $name 渲染 + 滚动无溢出', (t) => _smoke(t, 'form/$name', builder()));
  }
}