import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 上传文件模型。
class WotUploadFile {
  const WotUploadFile({
    this.name,
    this.url,
    this.path,
    this.type,
    this.size,
    this.bytes,
  });
  final String? name;
  final String? url;
  final String? path;
  final String? type;
  final int? size;

  /// 选文件得到的字节内容（web 端 path 常为 null）。
  final Uint8List? bytes;

  /// 可用于缩略图地址。
  String get thumbUrl => url ?? path ?? '';
}

/// 文件上传组件，对应 wot `wd-upload`。
///
/// 内部使用 `file_picker` 选择本地文件。文件列表默认由组件自维护；
/// 若传入非空 [files]（受控模式），则重绘使用外部列表。
class WotUpload extends StatefulWidget {
  const WotUpload({
    super.key,
    this.files = const [],
    this.onAdd,
    this.onRemove,
    this.onClick,
    this.onChange,
    this.maxCount,
    this.multiple = true,
    this.accept,
    this.disabled = false,
    this.size = 80,
    this.gutter = 10,
    this.addText = '添加',
    this.name,
  });

  /// 外部受控文件列表（传入非空即受控），否则组件自维护。
  final List<WotUploadFile> files;

  /// 自定义选文件（若提供则替代内置 file_picker 逻辑，参数为当前文件列表）。
  final ValueChanged<List<WotUploadFile>>? onAdd;

  /// 移除文件（受控模式下由外部刷新列表）。
  final ValueChanged<int>? onRemove;

  final ValueChanged<WotUploadFile>? onClick;

  /// 文件列表变化回调（受控模式）。
  final ValueChanged<List<WotUploadFile>>? onChange;

  final int? maxCount;
  final bool multiple;
  final String? accept;
  final bool disabled;
  final double size;
  final double gutter;
  final String addText;
  final String? name;

  @override
  State<WotUpload> createState() => _WotUploadState();
}

class _WotUploadState extends State<WotUpload> {
  late List<WotUploadFile> _files;

  bool get _controlled => widget.files.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _files = _controlled ? [...widget.files] : [];
  }

  @override
  void didUpdateWidget(WotUpload old) {
    super.didUpdateWidget(old);
    if (_controlled && old.files != widget.files) _files = [...widget.files];
  }

  bool get _canAdd => widget.maxCount == null || _files.length < widget.maxCount!;

  Future<void> _pick() async {
    if (widget.disabled || !_canAdd) return;

    // 提供自定义 onAdd 时交给宿主。
    if (widget.onAdd != null) {
      widget.onAdd!(_files);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.multiple,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = <WotUploadFile>[
      for (final pf in result.files)
        WotUploadFile(
          name: pf.name,
          size: pf.size,
          path: pf.path,
          bytes: pf.bytes,
          type: pf.extension,
        ),
    ];
    setState(() {
      _files.addAll(picked);
    });
    widget.onChange?.call(_files);
  }

  void _remove(int index) {
    if (index < 0 || index >= _files.length) return;
    if (widget.onRemove != null) {
      widget.onRemove!(index);
      return;
    }
    setState(() => _files.removeAt(index));
    widget.onChange?.call(_files);
  }

  List<WotUploadFile> get _display => _controlled ? _files : _files;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final files = _display;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: widget.gutter,
          runSpacing: widget.gutter,
          children: [
            for (final f in files)
              _item(context, f),
            if (_canAdd && !widget.disabled)
              _addButton(context),
          ],
        ),
        if (widget.maxCount != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${files.length}/${widget.maxCount}',
                style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
          ),
      ],
    );
  }

  Widget _item(BuildContext context, WotUploadFile f) {
    final scheme = context.wotScheme;
    return Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.filledStrong,
        borderRadius: BorderRadius.circular(6),
      ),
      child: GestureDetector(
        onTap: () => widget.onClick?.call(f),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (f.bytes != null)
              Image.memory(f.bytes!, fit: BoxFit.cover)
            else if (f.thumbUrl.isNotEmpty)
              Image.network(f.thumbUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _filePlaceholder(context, f))
            else
              _filePlaceholder(context, f),
            if (!widget.disabled)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => _remove(_display.indexOf(f)),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filePlaceholder(BuildContext context, WotUploadFile f) {
    final scheme = context.wotScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WotIcon(name: 'file', size: 20),
            const SizedBox(height: 4),
            Text(
              f.name?.isNotEmpty == true ? f.name! : f.size != null ? fmtBytes(f.size!) : '文件',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: scheme.textAuxiliary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    final scheme = context.wotScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pick,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          border: Border.all(color: scheme.borderMain),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WotIcon(name: 'add', size: 22),
            const SizedBox(height: 4),
            Text(widget.addText,
                style: TextStyle(fontSize: 12, color: scheme.textAuxiliary)),
          ],
        ),
      ),
    );
  }
}

/// 字节数格式化。
String fmtBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}