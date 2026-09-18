import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import 'basic/wot_button_page.dart';
import 'basic/wot_cell_group_page.dart';
import 'basic/wot_cell_page.dart';
import 'basic/wot_divider_page.dart';
import 'basic/wot_fab_page.dart';
import 'basic/wot_gap_page.dart';
import 'basic/wot_icon_page.dart';
import 'basic/wot_loading_page.dart';
import 'basic/wot_overlay_page.dart';
import 'basic/wot_row_col_page.dart';
import 'basic/wot_text_page.dart';
import 'nav/wot_backtop_page.dart';
import 'nav/wot_index_bar_page.dart';
import 'nav/wot_navbar_page.dart';
import 'nav/wot_pagination_page.dart';
import 'nav/wot_segmented_page.dart';
import 'nav/wot_sidebar_page.dart';
import 'nav/wot_tabbar_page.dart';
import 'nav/wot_tabs_page.dart';
import 'nav/wot_transition_page.dart';
import 'feedback/wot_action_sheet_page.dart';
import 'feedback/wot_circle_page.dart';
import 'feedback/wot_count_down_page.dart';
import 'feedback/wot_count_to_page.dart';
import 'feedback/wot_dialog_page.dart';
import 'feedback/wot_drop_menu_page.dart';
import 'feedback/wot_empty_page.dart';
import 'feedback/wot_floating_panel_page.dart';
import 'feedback/wot_notice_bar_page.dart';
import 'feedback/wot_notify_page.dart';
import 'feedback/wot_popover_page.dart';
import 'feedback/wot_popup_page.dart';
import 'feedback/wot_progress_page.dart';
import 'feedback/wot_sort_button_page.dart';
import 'feedback/wot_swipe_action_page.dart';
import 'feedback/wot_toast_page.dart';
import 'feedback/wot_tooltip_page.dart';
import 'feedback/wot_tour_page.dart';
import 'display/wot_avatar_page.dart';
import 'display/wot_badge_page.dart';
import 'display/wot_barcode_page.dart';
import 'display/wot_card_page.dart';
import 'display/wot_collapse_page.dart';
import 'display/wot_curtain_page.dart';
import 'display/wot_expand_page.dart';
import 'display/wot_grid_page.dart';
import 'display/wot_img_cropper_page.dart';
import 'display/wot_img_page.dart';
import 'display/wot_theme_btn_page.dart';
import 'display/wot_image_preview_page.dart';
import 'display/wot_loadmore_page.dart';
import 'display/wot_qr_code_page.dart';
import 'display/wot_skeleton_page.dart';
import 'display/wot_steps_page.dart';
import 'display/wot_swiper_page.dart';
import 'display/wot_table_page.dart';
import 'display/wot_tag_page.dart';
import 'display/wot_video_preview_page.dart';
import 'display/wot_watermark_page.dart';
import 'form/wot_calendar_page.dart';
import 'form/wot_cascader_page.dart';
import 'form/wot_checkbox_page.dart';
import 'form/wot_datetime_picker_page.dart';
import 'form/wot_form_page.dart';
import 'form/wot_input_number_page.dart';
import 'form/wot_input_page.dart';
import 'form/wot_keyboard_page.dart';
import 'form/wot_password_input_page.dart';
import 'form/wot_picker_page.dart';
import 'form/wot_picker_view_page.dart';
import 'form/wot_radio_page.dart';
import 'form/wot_rate_page.dart';
import 'form/wot_search_page.dart';
import 'form/wot_select_picker_page.dart';
import 'form/wot_signature_page.dart';
import 'form/wot_slide_verify_page.dart';
import 'form/wot_slider_page.dart';
import 'form/wot_switch_page.dart';
import 'form/wot_upload_page.dart';

/// 示例 App 首页：按 wot 分组（基础/导航/录入/反馈/展示）以折叠面板列出各组件入口。
class WotIndexPage extends StatefulWidget {
  const WotIndexPage({
    super.key,
    required this.dark,
    required this.onToggleDark,
  });

  final bool dark;
  final VoidCallback onToggleDark;

  @override
  State<WotIndexPage> createState() => _WotIndexPageState();
}

class _WotIndexPageState extends State<WotIndexPage> {
  /// 折叠面板当前展开的分组名集合；初始化为全部分组 => 默认全部展开。
  final Set<String> _activeGroups = {
    'basic',
    'nav',
    'form',
    'feedback',
    'display',
  };

  @override
  Widget build(BuildContext context) {
    final groups = [
      _Group('basic', '基础 Basic', [
        _Entry('Button', '按钮', () => _push(context, const WotButtonPage())),
        _Entry('Icon', '图标', () => _push(context, const WotIconPage())),
        _Entry('Text', '文本', () => _push(context, const WotTextPage())),
        _Entry('Cell', '单元格', () => _push(context, const WotCellPage())),
        _Entry('CellGroup', '单元格分组', () => _push(context, const WotCellGroupPage())),
        _Entry('Row/Col', '栅格', () => _push(context, const WotRowColPage())),
        _Entry('Gap', '间距', () => _push(context, const WotGapPage())),
        _Entry('Divider', '分割线', () => _push(context, const WotDividerPage())),
        _Entry('Overlay', '遮罩', () => _push(context, const WotOverlayPage())),
        _Entry('Loading', '加载', () => _push(context, const WotLoadingPage())),
        _Entry('Fab', '悬浮按钮', () => _push(context, const WotFabPage())),
      ]),
      _Group('nav', '导航 Navigation', [
        _Entry('Navbar', '顶部导航栏', () => _push(context, const WotNavbarPage())),
        _Entry('Tabs', '标签页', () => _push(context, const WotTabsPage())),
        _Entry('Tabbar', '底部标签栏', () => _push(context, const WotTabbarPage())),
        _Entry('Segmented', '分段控制器', () => _push(context, const WotSegmentedPage())),
        _Entry('Sidebar', '侧边导航', () => _push(context, const WotSidebarPage())),
        _Entry('Pagination', '分页', () => _push(context, const WotPaginationPage())),
        _Entry('IndexBar', '索引栏', () => _push(context, const WotIndexBarPage())),
        _Entry('Backtop', '回到顶部', () => _push(context, const WotBacktopPage())),
        _Entry('Transition', '过渡动画', () => _push(context, const WotTransitionPage())),
      ]),
      _Group('form', '录入 Form', [
        _Entry('Form', '表单·校验·动态字段', () => _push(context, const WotFormPage())),
        _Entry('Input/Textarea', '输入框·文本域', () => _push(context, const WotInputPage())),
        _Entry('InputNumber', '数字输入框', () => _push(context, const WotInputNumberPage())),
        _Entry('Search', '搜索框', () => _push(context, const WotSearchPage())),
        _Entry('Checkbox', '复选框', () => _push(context, const WotCheckboxPage())),
        _Entry('Radio', '单选框', () => _push(context, const WotRadioPage())),
        _Entry('Switch', '开关', () => _push(context, const WotSwitchPage())),
        _Entry('Rate', '评分', () => _push(context, const WotRatePage())),
        _Entry('Slider', '滑块', () => _push(context, const WotSliderPage())),
        _Entry('SelectPicker', '选择器', () => _push(context, const WotSelectPickerPage())),
        _Entry('Picker', '滚轮选择', () => _push(context, const WotPickerPage())),
        _Entry('PickerView', '滚轮视图', () => _push(context, const WotPickerViewPage())),
        _Entry('Cascader', '级联选择', () => _push(context, const WotCascaderPage())),
        _Entry('Calendar', '日历', () => _push(context, const WotCalendarPage())),
        _Entry('DatetimePicker', '日期时间', () => _push(context, const WotDatetimePickerPage())),
        _Entry('Signature', '手写签名', () => _push(context, const WotSignaturePage())),
        _Entry('Upload', '上传', () => _push(context, const WotUploadPage())),
        _Entry('PasswordInput', '密码输入', () => _push(context, const WotPasswordInputPage())),
        _Entry('SlideVerify', '滑动验证', () => _push(context, const WotSlideVerifyPage())),
        _Entry('Keyboard', '数字键盘', () => _push(context, const WotKeyboardPage())),
      ]),
      _Group('feedback', '反馈 Feedback', [
        _Entry('Toast', '轻提示', () => _push(context, const WotToastPage())),
        _Entry('Notify', '顶部通知', () => _push(context, const WotNotifyPage())),
        _Entry('Dialog', '对话框', () => _push(context, const WotDialogPage())),
        _Entry('ActionSheet', '操作菜单', () => _push(context, const WotActionSheetPage())),
        _Entry('Progress', '进度条', () => _push(context, const WotProgressPage())),
        _Entry('Circle', '环形进度', () => _push(context, const WotCirclePage())),
        _Entry('Popup', '弹出层', () => _push(context, const WotPopupPage())),
        _Entry('NoticeBar', '公告栏', () => _push(context, const WotNoticeBarPage())),
        _Entry('CountDown', '倒计时', () => _push(context, const WotCountDownPage())),
        _Entry('CountTo', '数字滚动', () => _push(context, const WotCountToPage())),
        _Entry('SortButton', '排序按钮', () => _push(context, const WotSortButtonPage())),
        _Entry('Tooltip', '气泡提示', () => _push(context, const WotTooltipPage())),
        _Entry('Popover', '气泡弹层', () => _push(context, const WotPopoverPage())),
        _Entry('DropMenu', '下拉菜单', () => _push(context, const WotDropMenuPage())),
        _Entry('FloatingPanel', '底部浮动面板', () => _push(context, const WotFloatingPanelPage())),
        _Entry('SwipeAction', '滑动操作', () => _push(context, const WotSwipeActionPage())),
        _Entry('Empty', '空状态', () => _push(context, const WotEmptyPage())),
        _Entry('Tour', '新手引导', () => _push(context, const WotTourPage())),
      ]),
      _Group('display', '展示 Display', [
        _Entry('Tag', '标签', () => _push(context, const WotTagPage())),
        _Entry('Badge', '徽标', () => _push(context, const WotBadgePage())),
        _Entry('Avatar', '头像', () => _push(context, const WotAvatarPage())),
        _Entry('Card', '卡片', () => _push(context, const WotCardPage())),
        _Entry('Grid', '宫格', () => _push(context, const WotGridPage())),
        _Entry('Collapse', '折叠面板', () => _push(context, const WotCollapsePage())),
        _Entry('Expand', '展开更多', () => _push(context, const WotExpandPage())),
        _Entry('Steps', '步骤条', () => _push(context, const WotStepsPage())),
        _Entry('Skeleton', '骨架屏', () => _push(context, const WotSkeletonPage())),
        _Entry('Loadmore', '加载更多', () => _push(context, const WotLoadmorePage())),
        _Entry('Img', '图片', () => _push(context, const WotImgPage())),
        _Entry('ImagePreview', '图片预览',
            () => _push(context, const WotImagePreviewPage())),
        _Entry('Swiper', '轮播', () => _push(context, const WotSwiperPage())),
        _Entry('Table', '表格', () => _push(context, WotTablePage())),
        _Entry('Watermark', '水印', () => _push(context, const WotWatermarkPage())),
        _Entry('QrCode', '二维码', () => _push(context, const WotQrCodePage())),
        _Entry('Barcode', '条形码', () => _push(context, const WotBarcodePage())),
        _Entry('Curtain', '幕布', () => _push(context, const WotCurtainPage())),
        _Entry('ImgCropper', '图片裁剪', () => _push(context, const WotImgCropperPage())),
        _Entry('VideoPreview', '视频预览', () => _push(context, const WotVideoPreviewPage())),
        _Entry('ThemeBtn', '主题切换按钮', () => _push(context, const WotThemeBtnPage())),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wot UI Flutter'),
        actions: [
          Tooltip(
            message: widget.dark ? '切换浅色' : '切换深色',
            child: WotThemeBtn(
              value: widget.dark,
              shadow: widget.dark ? WotThemeBtnShadow.light : WotThemeBtnShadow.dark,
              size: 100,
              onChanged: (_) => widget.onToggleDark(),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            clipBehavior: Clip.antiAlias,
            child: WotCollapse(
              accordion: false,
              showArrow: true,
              modelValue: _activeGroups.toList(),
              onChange: (names) => setState(() {
                _activeGroups
                  ..clear()
                  ..addAll(names);
              }),
              children: [
                for (final g in groups)
                  WotCollapseItem(
                    data: WotCollapseItemData(name: g.key, title: g.title),
                    children: g.entries.isEmpty
                        ? const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: WotText('待实现（后续 Phase 补充）',
                                  type: WotTextType.error, size: 13),
                            ),
                          ]
                        : [
                            for (final e in g.entries)
                              ListTile(
                                leading: const WotIcon(name: 'arrow-right', size: 16),
                                title: Text(e.name),
                                subtitle: Text(e.desc),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: e.onTap,
                              ),
                          ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _Group {
  const _Group(this.key, this.title, this.entries);
  final String key;
  final String title;
  final List<_Entry> entries;
}

class _Entry {
  const _Entry(this.name, this.desc, this.onTap);
  final String name;
  final String desc;
  final VoidCallback onTap;
}
