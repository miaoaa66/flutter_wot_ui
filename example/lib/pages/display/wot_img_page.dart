import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

import '../../common/demo_scaffold.dart';

/// 演示用图片源（固定 seed 保证多次加载结果一致）。
const String _img = 'https://picsum.photos/seed/wotimg/200/200';
const String _imgWide = 'https://picsum.photos/seed/wotwide/400/200';
const String _imgBroken = 'https://invalid.example.com/not-exist.png';

/// WotImg 图片示例页。
///
/// 覆盖：基础尺寸 / 14 种填充模式 / round / radius / loading 与 error 插槽 /
/// preview 与 previewList / lazyLoad / 三类回调。
class WotImgPage extends StatefulWidget {
  const WotImgPage({super.key});

  @override
  State<WotImgPage> createState() => _WotImgPageState();
}

class _WotImgPageState extends State<WotImgPage> {
  bool _round = false;
  bool _lazyLoad = false;
  String _lastEvent = '（尚无回调）';

  void _log(String msg) => setState(() => _lastEvent = msg);

  /// 单个填充模式的演示单元。
  Widget _modeItem(WotImgMode mode) {
    return SizedBox(
      width: 78,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WotImg(src: _imgWide, width: 64, height: 64, mode: mode, radius: 4),
          const SizedBox(height: 4),
          Text(
            mode.name,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WotDemoScaffold(
      title: 'WotImg 图片',
      children: [
        demoSection('基础（src / width / height）'),
        demoBlock('固定尺寸 100×100', const WotImg(src: _img, width: 100, height: 100)),
        demoBlock('撑满宽度 + 固定高（width 不传）',
            const WotImg(src: _imgWide, height: 120)),

        demoSection('圆角（radius）与圆形（round）'),
        demoBlock('radius: 16', const WotImg(src: _img, width: 100, height: 100, radius: 16)),
        demoBlock('round 开关（可现场切换，验证受控响应）',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('round'),
                  value: _round,
                  onChanged: (v) => setState(() => _round = v),
                ),
                WotImg(src: _img, width: 100, height: 100, round: _round),
              ],
            )),

        demoSection('填充模式（mode，共 14 种）'),
        demoBlock(
          '同一张 400×200 宽图在 64×64 容器内的表现',
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final mode in WotImgMode.values) _modeItem(mode),
            ],
          ),
        ),
        demoBlock(
          'fit 直传 BoxFit（优先于 mode 推导）',
          const Wrap(
            spacing: 12,
            children: [
              WotImg(src: _imgWide, width: 100, height: 80, fit: BoxFit.cover),
              WotImg(src: _imgWide, width: 100, height: 80, fit: BoxFit.contain),
              WotImg(src: _imgWide, width: 100, height: 80, fit: BoxFit.fill),
            ],
          ),
        ),

        demoSection('加载态（loading 插槽）'),
        demoBlock('默认加载占位（灰底）', const WotImg(src: _img, width: 100, height: 100)),
        demoBlock('自定义 loading（转圈 + 文案）',
            const WotImg(
              src: _img,
              width: 100,
              height: 100,
              loading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(height: 6),
                  Text('加载中', style: TextStyle(fontSize: 12)),
                ],
              ),
            )),
        demoBlock('placeholder（与 loading 同义，loading 优先）',
            const WotImg(
              src: _img,
              width: 100,
              height: 100,
              placeholder: Center(child: Text('占位', style: TextStyle(fontSize: 12))),
            )),

        demoSection('失败态（error 插槽）'),
        demoBlock('默认失败占位（error 图标）',
            const WotImg(src: _imgBroken, width: 100, height: 100)),
        demoBlock('自定义 error',
            const WotImg(
              src: _imgBroken,
              width: 100,
              height: 100,
              error: ColoredBox(
                color: Color(0xFFFFEBEE),
                child: Center(child: Text('加载失败', style: TextStyle(fontSize: 12))),
              ),
            )),

        demoSection('预览（preview / previewList）'),
        demoBlock('preview: true（单图预览，点击图片）',
            WotImg(src: _img, width: 100, height: 100, preview: true, onClick: () => _log('onClick 触发'))),
        demoBlock('previewList（多图预览，从第 1 张打开）',
            WotImg(
              src: _img,
              width: 100,
              height: 100,
              preview: true,
              previewList: const [_img, _imgWide],
              onClick: () => _log('多图预览'),
            )),
        // TODO: previewSrc（展示图与预览图不同）待组件支持，见 COMPONENT_AUDIT.md

        demoSection('懒加载（lazyLoad）'),
        demoBlock('切换后重新进入页面可见效果（渲染到屏幕才发起请求）',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('lazyLoad'),
                  value: _lazyLoad,
                  onChanged: (v) => setState(() => _lazyLoad = v),
                ),
                WotImg(src: _imgWide, height: 100, lazyLoad: _lazyLoad),
              ],
            )),

        demoSection('回调（onLoad / onError / onClick）'),
        demoBlock('最近一次回调：$_lastEvent',
            Wrap(
              spacing: 12,
              children: [
                WotImg(
                  src: _img,
                  width: 80,
                  height: 80,
                  onLoad: () => _log('onLoad'),
                  onClick: () => _log('onClick（正常图）'),
                ),
                WotImg(
                  src: _imgBroken,
                  width: 80,
                  height: 80,
                  onError: () => _log('onError'),
                ),
              ],
            )),

        // TODO: showLoading / showError（关闭默认占位）待组件支持后补演示
        demoSection('新增（D 类 P1）：showLoading / showError 开关'),
        demoBlock(
            'showError=false：加载失败渲染空白（显式 error slot 优先）',
            WotImg(
              src: 'https://invalid.example.com/not-exist.png',
              width: 120,
              height: 90,
              showError: false,
            )),
        demoBlock(
            'showLoading=false：加载中渲染空白',
            WotImg(
              src: 'https://picsum.photos/240/180',
              width: 120,
              height: 90,
              showLoading: false,
            )),
      ],
    );
  }
}
