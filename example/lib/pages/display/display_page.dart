import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 展示 display 组件演示页。
class WotDisplayPage extends StatefulWidget {
  const WotDisplayPage({super.key});

  @override
  State<WotDisplayPage> createState() => _WotDisplayPageState();
}

class _WotDisplayPageState extends State<WotDisplayPage> {
  bool _loading = true;
  bool _curtain = false;
  final List<String> _collapsed = ['1'];
  int _step = 0;
  int _multiCollapsed = 0;
  int _swiperIndex = 0;
  bool _badgeHidden = false;
  final Set<String> _closedTags = {};
  final String _videoUrl = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  /// 图片裁剪组件控制器，用于命令式调用 `crop()` 导出裁剪结果。
  final GlobalKey<WotImgCropperState> _cropKey = GlobalKey();

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)));
  }

  /// 打开图片裁剪对话框，通过 GlobalKey 命令式调用 `crop()` 导出裁剪结果。
  Future<void> _openCropper() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                // 隐藏内置按钮，交由其外层统一处理“取消/裁剪”。
                child: WotImgCropper(
                  key: _cropKey,
                  src: 'https://picsum.photos/800',
                  showButtons: false,
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final r = await _cropKey.currentState?.crop();
                          if (!ctx.mounted) return;
                          if (r == null) {
                            _toast('裁剪失败');
                          } else {
                            _toast('已裁剪 ${r.width}x${r.height}，共 ${r.bytes.length} 字节');
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('展示组件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('WotTag 标签'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              WotTag(text: '默认'),
              WotTag(text: '成功', type: WotTagType.success),
              WotTag(text: '警告', type: WotTagType.warning),
              WotTag(text: '危险', type: WotTagType.danger),
              WotTag(text: '信息', type: WotTagType.info),
              WotTag(text: '描边', variant: WotTagVariant.plain),
              WotTag(text: '实心', variant: WotTagVariant.dark),
              WotTag(text: '浅色', variant: WotTagVariant.light),
              if (!_closedTags.contains('c1'))
                WotTag(text: '可关闭', closable: true, onClose: () => setState(() => _closedTags.add('c1'))),
              WotTag(text: '圆角', round: true, type: WotTagType.success),
              WotTag(text: '方角', round: false, type: WotTagType.warning),
              WotTag(text: '大号', size: WotTagSize.large),
              WotTag(text: '小号', size: WotTagSize.small),
              WotTag(text: '迷你', size: WotTagSize.mini, variant: WotTagVariant.plain),
              WotTag(text: '自定义色', color: const Color(0xFF8B5CF6), variant: WotTagVariant.plain),
              WotTag(text: '可点击', onClick: () => _toast('点击标签')),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotBadge 徽标'),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              WotBadge(modelValue: 5, child: SizedBox(width: 40, height: 40, child: _box(scheme))),
              WotBadge(modelValue: 120, max: 99, child: SizedBox(width: 40, height: 40, child: _box(scheme))),
              WotBadge(isDot: true, child: SizedBox(width: 40, height: 40, child: _box(scheme))),
              WotBadge(
                modelValue: 8,
                badgePosition: WotBadgePosition.topLeft,
                child: SizedBox(width: 40, height: 40, child: _box(scheme)),
              ),
              WotBadge(
                modelValue: 8,
                badgePosition: WotBadgePosition.bottomRight,
                child: SizedBox(width: 40, height: 40, child: _box(scheme)),
              ),
              WotBadge(
                hidden: _badgeHidden,
                modelValue: 10,
                child: InkWell(
                  onTap: () => setState(() => _badgeHidden = !_badgeHidden),
                  child: SizedBox(width: 40, height: 40, child: _box(scheme)),
                ),
              ),
              WotBadge(slot: const Icon(Icons.star, color: Colors.amber, size: 18), child: SizedBox(width: 40, height: 40, child: _box(scheme))),
            ],
          ),
          const SizedBox(height: 8),
          WotText(_badgeHidden ? '右上角徽标已隐藏' : '点击方框可切换角标显示/隐藏', type: WotTextType.wotDefault),
          const SizedBox(height: 20),
          _section('WotAvatar / WotAvatarGroup 头像'),
          Row(
            children: [
              WotAvatar(name: '张'),
              const SizedBox(width: 12),
              WotAvatar(src: 'https://picsum.photos/seed/a/80', size: 48),
              const SizedBox(width: 12),
              WotAvatar(shape: WotAvatarShape.square, name: '李', size: 48),
              const SizedBox(width: 12),
              WotAvatarGroup(
                avatarList: ['https://picsum.photos/seed/a1/80', 'https://picsum.photos/seed/a2/80', 'https://picsum.photos/seed/a3/80'],
                max: 3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _section('尺寸 / 形状 / 颜色 / 图标'),
          Row(
            children: [
              WotAvatar(name: 'S', size: 32),
              const SizedBox(width: 12),
              WotAvatar(name: 'M', size: 40),
              const SizedBox(width: 12),
              WotAvatar(name: 'L', size: 56),
              const SizedBox(width: 12),
              WotAvatar(
                name: '方',
                size: 48,
                shape: WotAvatarShape.square,
                round: true,
                bgColor: scheme.primaryOf(6),
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              WotAvatar(icon: 'star', size: 48, bgColor: const Color(0xFFFFE4B5), color: Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 16),
          _section('头像组：超出 max 显示 +N（maxInfo）'),
          Row(
            children: [
              WotAvatarGroup(
                avatarList: [
                  'https://picsum.photos/seed/g1/80',
                  'https://picsum.photos/seed/g2/80',
                  'https://picsum.photos/seed/g3/80',
                  'https://picsum.photos/seed/g4/80',
                  'https://picsum.photos/seed/g5/80',
                  'https://picsum.photos/seed/g6/80',
                ],
                max: 5,
                size: 44,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotCard 卡片'),
          WotCard(
            title: '商品标题',
            description: '这是一段商品描述，用于展示卡片的内容区域。',
            price: '99.00',
            image: 'https://picsum.photos/seed/card/90',
            showFooter: true,
            footer: WotButton(text: '加入购物车', size: WotButtonSize.small, onClick: () => _toast('已加入')),
          ),
          const SizedBox(height: 12),
          _section('卡片自定义内容（标题副标题 / 描述 / footer 插槽）'),
          WotCard(
            onClick: () => _toast('点击卡片'),
            children: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WotText('活动标题', bold: true, size: 16),
                          SizedBox(height: 4),
                          WotText('活动副标题', type: WotTextType.wotDefault),
                        ],
                      ),
                    ),
                    WotTag(text: 'NEW', type: WotTagType.danger, size: WotTagSize.mini),
                  ],
                ),
                const SizedBox(height: 8),
                WotText('标题下方描述：这里通过 children 自定义卡片内容，支持任意布局，' '点击整卡可触发点击回调。',
                    type: WotTextType.wotDefault),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    WotButton(text: '查看详情', size: WotButtonSize.small, variant: WotButtonVariant.text),
                    const SizedBox(width: 8),
                    WotButton(text: '立即参加', size: WotButtonSize.small, onClick: () => _toast('参加活动')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _section('WotGrid 宫格（点击图标）'),
          WotGrid(
            columnNum: 3,
            children: [
              for (final (name, label) in [
                ('home', '首页'),
                ('category', '分类'),
                ('user', '我的'),
                ('cart', '购物车'),
                ('star', '收藏'),
                ('service', '客服'),
              ])
                WotGridItem(iconName: name, text: label, onClick: () => _toast('点击 $label')),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotCollapse 折叠面板 - 手风琴（accordion）/ 受控 value'),
          WotCollapse(
            modelValue: _collapsed,
            accordion: true,
            onChange: (v) => setState(() => _collapsed
              ..clear()
              ..addAll(v)),
            children: [
              WotCollapseItem(data: WotCollapseItemData(name: '1', title: '标题一', content: '内容一：这里是折叠面板的内容。')),
              WotCollapseItem(data: WotCollapseItemData(name: '2', title: '标题二', content: '内容二：这里是折叠面板的内容。')),
              WotCollapseItem(
                data: WotCollapseItemData(name: '3', title: '标题三（禁用）', disabled: true, content: '内容三：禁用项无法展开')),
            ],
          ),
          const SizedBox(height: 16),
          _section('WotCollapse 折叠面板 - 多选 / 自定义内容'),
          WotCollapse(
            // 非受控：由组件内部维护多选展开状态（受控需在 onChange 同步传回 modelValue）。
            accordion: false,
            onChange: (v) => setState(() => _multiCollapsed = v.length),
            children: [
              WotCollapseItem(
                data: const WotCollapseItemData(name: 'm1', title: '收货地址'),
                children: [
                  WotText('四川省成都市高新区天府大道 1000 号', type: WotTextType.wotDefault),
                  const SizedBox(height: 8),
                  WotButton(text: '修改地址', size: WotButtonSize.small),
                ],
              ),
              WotCollapseItem(
                data: const WotCollapseItemData(name: 'm2', title: '发票信息（无内容展示光占位）'),
                children: const [WotText('企业增值税普通发票', type: WotTextType.wotDefault)],
              ),
              WotCollapseItem(data: const WotCollapseItemData(name: 'm3', title: '备注', content: '可同时展开多个面板')), 
            ],
          ),
          const SizedBox(height: 8),
          WotText('非手风琴模式同时展开 $_multiCollapsed 项', type: WotTextType.wotDefault),
          const SizedBox(height: 20),
          _section('WotSteps 步骤条 - 水平 / active / onChange'),
          WotSteps(
            active: _step,
            activeColor: scheme.primaryOf(6),
            onChange: (i) => setState(() => _step = i),
            children: [
              WotStep(data: const WotStepData(title: '第一步', description: '填写信息')),
              WotStep(data: const WotStepData(title: '第二步', description: '确认订单')),
              WotStep(data: const WotStepData(title: '第三步', description: '完成支付')),
            ],
          ),
          const SizedBox(height: 8),
          WotText('当前步骤：第 ${_step + 1} 步，点击步骤可切换', type: WotTextType.wotDefault),
          const SizedBox(height: 16),
          _section('WotSteps 步骤条 - 垂直排列（direction: vertical）'),
          WotSteps(
            direction: WotStepsDirection.vertical,
            active: 2,
            activeColor: scheme.successMain,
            children: const [
              WotStep(data: WotStepData(title: '查收快递', description: '物流已出发')),
              WotStep(data: WotStepData(title: '打包中', description: '正在打包商品')),
              WotStep(data: WotStepData(title: '下单成功', description: '订单已确认')),
              WotStep(data: WotStepData(title: '待付款', description: '等待支付')),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotSkeleton 骨架屏'),
          WotButton(
            text: _loading ? '显示内容' : '显示骨架',
            size: WotButtonSize.small,
            onClick: () => setState(() => _loading = !_loading),
          ),
          const SizedBox(height: 8),
          WotSkeleton(
            loading: _loading,
            avatar: true,
            title: true,
            row: 3,
            rowWidth: '100%',
            child: const Text('加载完成后的内容'),
          ),
          const SizedBox(height: 20),
          _section('WotLoadmore 加载更多'),
          const WotLoadmore(state: WotLoadmoreState.loading),
          const WotLoadmore(state: WotLoadmoreState.noMore),
          const WotLoadmore(state: WotLoadmoreState.loadingFailed, onLoadmore: null),
          const SizedBox(height: 20),
          _section('WotImg 图片'),
          const WotImg(
            src: 'https://picsum.photos/seed/swiper/400/200',
            width: double.infinity,
            height: 120,
            radius: 8,
            preview: true,
          ),
          const SizedBox(height: 20),
          _section('WotSwiper 轮播 - autoplay / interval / onChange'),
          SizedBox(
            height: 150,
            child: WotSwiper(
              autoplay: true,
              interval: 2500,
              onChange: (i) => setState(() => _swiperIndex = i),
              children: [
                for (var i = 0; i < 4; i++)
                  WotSwiperItem(
                    child: Container(
                      color: [Colors.teal, Colors.indigo, Colors.deepOrange, Colors.brown][i % 4],
                      alignment: Alignment.center,
                      child: Text('第${i + 1}页', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          WotText('当前页：${_swiperIndex + 1} / 4，自动播放、间隔 2500ms', type: WotTextType.wotDefault),
          const SizedBox(height: 16),
          _section('WotSwiper 轮播 - indicatorPosition 顶部 / loop 循环'),
          SizedBox(
            height: 150,
            child: WotSwiper(
              loop: true,
              indicatorPosition: WotSwiperIndicatorPosition.middleCenter,
              children: const [
                WotSwiperItem(child: ColoredBox(color: Color(0xFF4DB6AC), child: Center(child: Text('顶部指示点', style: TextStyle(color: Colors.white))))),
                WotSwiperItem(child: ColoredBox(color: Color(0xFF7986CB), child: Center(child: Text('循环轮播', style: TextStyle(color: Colors.white))))),
                WotSwiperItem(child: ColoredBox(color: Color(0xFFF06292), child: Center(child: Text('多子项示例', style: TextStyle(color: Colors.white))))),
                WotSwiperItem(child: ColoredBox(color: Color(0xFFFFB74D), child: Center(child: Text('可拖动切换', style: TextStyle(color: Colors.white))))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _section('WotTable 表格 - border / stripe / 列宽 / 对齐'),
          WotTable(
            border: true,
            stripe: true,
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
            onRowClick: (row, i) => _toast('点击：${row['name']}'),
          ),
          const SizedBox(height: 16),
          _section('WotTable 表格 - maxHeight 滚动 / 列宽 / 自定义格式化'),
          WotTable(
            border: true,
            maxHeight: 200,
            data: List.generate(
              8,
              (i) => {'name': '用户${i + 1}', 'amount': (i + 1) * 12.5, 'status': i.isEven ? '已支付' : '待支付'},
            ),
            columns: [
              WotTableColumn(prop: 'name', label: '订单', width: 90, align: WotTableAlign.left),
              WotTableColumn(
                prop: 'amount',
                label: '金额',
                width: 90,
                align: WotTableAlign.right,
                formatter: (v, _) => '¥$v',
              ),
              WotTableColumn(
                prop: 'status',
                label: '状态',
                align: WotTableAlign.center,
                formatter: (v, _) => v == '已支付' ? '✔ $v' : '$v',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotWatermark 水印'),
          WotWatermark(
            content: 'Wot UI Flutter',
            fontSize: 14,
            child: Container(
              height: 120,
              color: scheme.filledContent,
              alignment: Alignment.center,
              child: const WotText('水印底层内容'),
            ),
          ),
          const SizedBox(height: 20),
          _section('WotQrCode 二维码'),
          const WotQrCode(value: 'https://wot-design-uni.cn', size: 160),
          const SizedBox(height: 20),
          _section('WotCurtain 幕布（点击开启）'),
          WotButton(text: '开启幕布', size: WotButtonSize.small, onClick: () => setState(() => _curtain = true)),
          if (_curtain)
            WotCurtain(
              modelValue: _curtain,
              onModelUpdate: (v) => setState(() => _curtain = v),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WotText('活动公告', bold: true, size: 16),
                    SizedBox(height: 12),
                    WotText('这是一则全屏幕布活动公告内容。', type: WotTextType.wotDefault),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          _section('WotImgCropper 图片裁剪'),
          WotText(
            '点击后在对话框内拖动/缩放图片，裁剪框固定居中方框，确认后通过 GlobalKey 调 crop()。',
            type: WotTextType.wotDefault,
          ),
          const SizedBox(height: 8),
          WotButton(
            text: '打开裁剪',
            size: WotButtonSize.small,
            type: WotButtonType.primary,
            onClick: _openCropper,
          ),
          const SizedBox(height: 20),
          _section('WotVideoPreview 视频预览（命令式全屏）'),
          WotButton(
            text: '预览视频',
            size: WotButtonSize.small,
            type: WotButtonType.primary,
            onClick: () => WotVideoPreview.show(
              context,
              _videoUrl,
              title: '示例视频',
            ),
          ),
          const SizedBox(height: 12),
          _section('WotVideoPreview 内嵌播放器'),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: WotVideoPreview(
                src: _videoUrl,
                title: '内嵌视频示例',
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static Widget _box(WotScheme scheme) {
    return Container(color: scheme.filledStrong);
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(title, type: WotTextType.wotDefault, bold: true),
    );
  }
}