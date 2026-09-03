import 'package:flutter/material.dart';

/// 转 HEX ARGB（8位, `#RRGGBBAA`）字符串为 [Color]。
/// wot-ui 的 SCSS 色值统一为 8 位十六进制（含透明度）。
Color wotHex(String argbHex) {
  return Color(int.parse(argbHex.substring(1), radix: 16));
}

// 便捷常量别名，供 `WotPalette` 字段初始化使用（`wotHex` 非 const，故字段为 final）。
final Color _black = wotHex('#000000FF');
final Color _white = wotHex('#FFFFFFFF');

/// 基础色板：对应 `wot-ui/src/uni_modules/wot-ui/styles/theme/base/color.scss`。
/// 每种色系含 10 级梯度 + 一个 8% 透明原色（用于 feedback-accent）。
class WotPalette {
  const WotPalette._();

  static final Color baseBlack = _black;
  static final Color baseWhite = _white;

  // 蓝色（主色）
  static final Color blue1 = wotHex('#F5F8FFFF');
  static final Color blue2 = wotHex('#E5EDFFFF');
  static final Color blue3 = wotHex('#B8CFFFFF');
  static final Color blue4 = wotHex('#7CA4FFFF');
  static final Color blue5 = wotHex('#4480FFFF');
  static final Color blue6 = wotHex('#1C64FDFF');
  static final Color blue7 = wotHex('#164ED1FF');
  static final Color blue8 = wotHex('#1341ADFF');
  static final Color blue9 = wotHex('#0F3285FF');
  static final Color blue10 = wotHex('#0A235CFF');
  static final Color blueOpac = wotHex('#1C64FD14');

  // 红色（危险）
  static final Color red1 = wotHex('#FFF5F5FF');
  static final Color red2 = wotHex('#FFE3E3FF');
  static final Color red3 = wotHex('#FFC9C9FF');
  static final Color red4 = wotHex('#FFA8A8FF');
  static final Color red5 = wotHex('#FB7C7CFF');
  static final Color red6 = wotHex('#F14646FF');
  static final Color red7 = wotHex('#DC2C2CFF');
  static final Color red8 = wotHex('#BC2626FF');
  static final Color red9 = wotHex('#A01515FF');
  static final Color red10 = wotHex('#790909FF');
  static final Color redOpac = wotHex('#F1464614');

  // 绿色（成功）
  static final Color green1 = wotHex('#F3FBF9FF');
  static final Color green2 = wotHex('#E7F8F3FF');
  static final Color green3 = wotHex('#B8EADBFF');
  static final Color green4 = wotHex('#88DBC3FF');
  static final Color green5 = wotHex('#59CDAAFF');
  static final Color green6 = wotHex('#12B886FF');
  static final Color green7 = wotHex('#0F956CFF');
  static final Color green8 = wotHex('#0B6F51FF');
  static final Color green9 = wotHex('#074A36FF');
  static final Color green10 = wotHex('#04251BFF');
  static final Color greenOpac = wotHex('#12B88614');

  // 橙色（警告）
  static final Color orange1 = wotHex('#FFF6EBFF');
  static final Color orange2 = wotHex('#FFE8CCFF');
  static final Color orange3 = wotHex('#FFD8A8FF');
  static final Color orange4 = wotHex('#FFC078FF');
  static final Color orange5 = wotHex('#FFA94DFF');
  static final Color orange6 = wotHex('#F57F00FF');
  static final Color orange7 = wotHex('#D05706FF');
  static final Color orange8 = wotHex('#A94605FF');
  static final Color orange9 = wotHex('#813604FF');
  static final Color orange10 = wotHex('#592503FF');
  static final Color orangeOpac = wotHex('#F57F0014');

  // 冷灰色（中性文字/边框/填充）
  static final Color coolgrey1 = wotHex('#F7F8FAFF');
  static final Color coolgrey2 = wotHex('#F2F3F5FF');
  static final Color coolgrey3 = wotHex('#E5E6EBFF');
  static final Color coolgrey4 = wotHex('#C9CBD4FF');
  static final Color coolgrey5 = wotHex('#A9ACB8FF');
  static final Color coolgrey6 = wotHex('#868A9CFF');
  static final Color coolgrey7 = wotHex('#6B7085FF');
  static final Color coolgrey8 = wotHex('#4E5369FF');
  static final Color coolgrey9 = wotHex('#272B3BFF');
  static final Color coolgrey10 = wotHex('#1D1F29FF');

  // 青色（分类色）
  static final Color cyan1 = wotHex('#F4FBFDFF');
  static final Color cyan2 = wotHex('#E9F8FAFF');
  static final Color cyan3 = wotHex('#BDEAF1FF');
  static final Color cyan4 = wotHex('#90DBE7FF');
  static final Color cyan5 = wotHex('#64CDDDFF');
  static final Color cyan6 = wotHex('#22B8CFFF');
  static final Color cyan7 = wotHex('#1C98ABFF');
  static final Color cyan8 = wotHex('#167988FF');
  static final Color cyan9 = wotHex('#115A65FF');
  static final Color cyan10 = wotHex('#0B3A42FF');

  // 紫色（分类色）
  static final Color purple1 = wotHex('#F9F8FFFF');
  static final Color purple2 = wotHex('#E5DBFFFF');
  static final Color purple3 = wotHex('#D0BFFFFF');
  static final Color purple4 = wotHex('#B197FCFF');
  static final Color purple5 = wotHex('#9775FAFF');
  static final Color purple6 = wotHex('#8059F3FF');
  static final Color purple7 = wotHex('#5B29EFFF');
  static final Color purple8 = wotHex('#4511DFFF');
  static final Color purple9 = wotHex('#390EB9FF');
  static final Color purple10 = wotHex('#2D0B93FF');

  // 靛色（分类色）
  static final Color grape1 = wotHex('#FBF6FDFF');
  static final Color grape2 = wotHex('#F3D9FAFF');
  static final Color grape3 = wotHex('#EEBEFAFF');
  static final Color grape4 = wotHex('#E599F7FF');
  static final Color grape5 = wotHex('#DA77F2FF');
  static final Color grape6 = wotHex('#AE3EC9FF');
  static final Color grape7 = wotHex('#9731AFFF');
  static final Color grape8 = wotHex('#7B288FFF');
  static final Color grape9 = wotHex('#601F70FF');
  static final Color grape10 = wotHex('#451650FF');

  // 粉红色（分类色）
  static final Color pink1 = wotHex('#FFF0F6FF');
  static final Color pink2 = wotHex('#FFDEEBFF');
  static final Color pink3 = wotHex('#FCC2D7FF');
  static final Color pink4 = wotHex('#FAA2C1FF');
  static final Color pink5 = wotHex('#F783ACFF');
  static final Color pink6 = wotHex('#FF357CFF');
  static final Color pink7 = wotHex('#FF0A60FF');
  static final Color pink8 = wotHex('#E0004FFF');
  static final Color pink9 = wotHex('#B80040FF');
  static final Color pink10 = wotHex('#8F0032FF');

  // 黄色（分类色）
  static final Color yellow1 = wotHex('#FFFAF1FF');
  static final Color yellow2 = wotHex('#FDE5B4FF');
  static final Color yellow3 = wotHex('#FDD78CFF');
  static final Color yellow4 = wotHex('#FCC964FF');
  static final Color yellow5 = wotHex('#FBBB3CFF');
  static final Color yellow6 = wotHex('#FAAD14FF');
  static final Color yellow7 = wotHex('#E19705FF');
  static final Color yellow8 = wotHex('#B97C04FF');
  static final Color yellow9 = wotHex('#916103FF');
  static final Color yellow10 = wotHex('#694702FF');
}

/// 由透明度变量派生的黑色系遮罩（`--wot-opac-*`）。
class WotBlackAlpha {
  const WotBlackAlpha._();

  static final Color a8 = wotHex('#00000014'); // opac-3_08
  static final Color a15 = wotHex('#00000026'); // opac-4_15
  static final Color a20 = wotHex('#00000033'); // opac-5_20
  static final Color a30 = wotHex('#0000004D'); // opac-6_30
  static final Color a55 = wotHex('#0000008C'); // opac-7_55
  static final Color a75 = wotHex('#000000BF'); // opac-9_75
  static final Color a85 = wotHex('#000000D9'); // opac-10_85
  static final Color a4 = wotHex('#0000000A'); // opac-2_04
}