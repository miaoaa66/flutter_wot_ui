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

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)));
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
              WotTag(text: '可关闭', closable: true, onClose: () => _toast('关闭')),
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
              WotBadge(slot: const Icon(Icons.star, color: Colors.amber, size: 18), child: SizedBox(width: 40, height: 40, child: _box(scheme))),
            ],
          ),
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
          const SizedBox(height: 20),
          _section('WotGrid 宫格（点击图标）'),
          WotGrid(
            columnNum: 4,
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
          _section('WotCollapse 折叠面板'),
          WotCollapse(
            modelValue: _collapsed,
            accordion: true,
            onChange: (v) => setState(() => _collapsed
              ..clear()
              ..addAll(v)),
            children: [
              WotCollapseItem(data: WotCollapseItemData(name: '1', title: '标题一', content: '内容一：这里是折叠面板的内容。')),
              WotCollapseItem(data: WotCollapseItemData(name: '2', title: '标题二', content: '内容二：这里是折叠面板的内容。')),
              WotCollapseItem(data: WotCollapseItemData(name: '3', title: '标题三（带图标）', iconName: 'star', content: '内容三')),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotSteps 步骤条'),
          WotSteps(active: 1, children: const [
            WotStep(data: WotStepData(title: '第一步', description: '填写信息')),
            WotStep(data: WotStepData(title: '第二步', description: '确认订单')),
            WotStep(data: WotStepData(title: '第三步', description: '完成支付')),
          ]),
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
          _section('WotSwiper 轮播'),
          SizedBox(
            height: 150,
            child: WotSwiper(
              autoplay: true,
              onChange: (i) {},
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
          const SizedBox(height: 20),
          _section('WotTable 表格'),
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
                    WotText('活动公告', strong: true, size: 16),
                    SizedBox(height: 12),
                    WotText('这是一则全屏幕布活动公告内容。', type: WotTextType.secondary),
                  ],
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
      child: WotText(title, type: WotTextType.secondary, strong: true),
    );
  }
}