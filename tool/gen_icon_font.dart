// 图标映射生成工具：解析 wot-ui 的 iconfont.scss，生成名称→Unicode 码点的 Dart 映射。
//
// 用法：
//   dart run tool/gen_icon_font.dart
//
// 输入：wot-ui/src/uni_modules/wot-ui/components/wd-icon/iconfont.scss
// 输出：lib/src/icon/iconfont_map.dart
//
// 说明：wot-ui 通过 iconfont 渲染图标。本项目为保持零二进制资产与许可证洁净，
// 默认使用 Flutter 内置 Material Icons 渲染（见 WotIconResolver）。本映射保留官方
// 名称→码点对应关系，供后续若要在打包时引入官方字体时使用（社区包或自行注册字体）。
// ignore_for_file: avoid_print
import 'dart:io';

const String scssPath =
    '../wot-ui/src/uni_modules/wot-ui/components/wd-icon/iconfont.scss';
const String outputPath = 'lib/src/icon/iconfont_map.dart';

void main() {
  final scss = File(scssPath).readAsStringSync();
  final entries = <String, int>{};
  final re = RegExp(
    r'\.wd-icon-([\w-]+):before\s*\{\s*content:\s*"\\e([0-9a-fA-F]{3,4})"',
    multiLine: true,
  );

  for (final m in re.allMatches(scss)) {
    final name = m.group(1)!;
    final code = int.parse(m.group(2)!, radix: 16);
    entries[name] = code;
  }

  if (entries.isEmpty) {
    throw StateError('在 $scssPath 中未解析到任何图标映射');
  }

  final buffer = StringBuffer()
    ..writeln('// 由 tool/gen_icon_font.dart 自动生成，请勿手工编辑。')
    ..writeln('// 名称 → Unicode 码点（源自 wot-ui iconfont.scss，共 ${entries.length} 个）。')
    ..writeln('/// wot 官方图标名称到 Unicode 码点的映射表。')
    ..writeln('class WotIconFont {')
    ..writeln('  const WotIconFont._();')
    ..writeln('')
    ..writeln('  /// 名称对应的码点；未命中返回 null。')
    ..writeln('  static int? codePointOf(String name) => _map[name];')
    ..writeln('')
    ..writeln('  static const Map<String, int> _map = <String, int>{');

  final keys = entries.keys.toList()..sort();
  for (final k in keys) {
    buffer.writeln("    '$k': 0x${entries[k]!.toRadixString(16)},");
  }
  buffer.writeln('  };');
  buffer.writeln('}');

  final out = File(outputPath);
  out.writeAsStringSync(buffer.toString());
  print('已生成 ${out.path}（${entries.length} 个图标）');
}