import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../theme/wot_state.dart';
import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';
// 内置上传走 dart:io（native）；web 平台降级为占位实现，需用 uploadMethod。
import 'wot_upload_unsupported.dart'
    if (dart.library.io) 'wot_upload_native.dart';

/// 上传文件状态。
enum WotUploadStatus {
  /// 待上传（手动上传模式）。
  pending,

  /// 上传中（加载动画）。
  loading,

  /// 上传成功。
  success,

  /// 上传失败。
  fail,
}

/// 上传文件模型。
class WotUploadFile {
  const WotUploadFile({
    this.name,
    this.url,
    this.path,
    this.type,
    this.size,
    this.bytes,
    this.status = WotUploadStatus.success,
    this.percent,
    this.uid,
  });
  final String? name;
  final String? url;
  final String? path;
  final String? type;
  final int? size;

  /// 选文件得到的字节内容（web 端 path 常为 null）。
  final Uint8List? bytes;

  /// 当前上传状态，默认 success（已有文件视为成功）。
  final WotUploadStatus status;

  /// 上传进度（0-100），可选。
  final double? percent;

  /// 文件唯一标识（可选）。
  final int? uid;

  /// 可用于缩略图地址。
  String get thumbUrl => url ?? path ?? '';

  /// 复制并替换上传状态/进度/地址。
  WotUploadFile copyWith({
    WotUploadStatus? status,
    double? percent,
    String? url,
  }) {
    return WotUploadFile(
      name: name,
      url: url ?? this.url,
      path: path,
      type: type,
      size: size,
      bytes: bytes,
      status: status ?? this.status,
      percent: percent ?? this.percent,
      uid: uid,
    );
  }
}

/// 上传结果。
class WotUploadResponse {
  const WotUploadResponse({
    this.statusCode = 200,
    this.body,
    this.url,
    this.error,
  });

  /// HTTP 状态码；0 表示请求未发出（URL 非法、平台不支持等）。
  final int statusCode;

  /// 响应体原文，便于调用方自行解析。
  final String? body;

  /// 上传成功后的文件地址；为空时保留原文件的 [WotUploadFile.url]。
  final String? url;

  /// 错误信息；非空即视为失败。
  final String? error;

  bool get isSuccess => error == null && statusCode >= 200 && statusCode < 300;
}

/// 自定义上传实现：接收文件与进度回调（0-100），返回 [WotUploadResponse]。
typedef WotUploadMethod = Future<WotUploadResponse> Function(
  WotUploadFile file,
  void Function(double percent) onProgress,
);

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
    this.onUpload,
    this.onOverSize,
    this.onBeforeUpload,
    this.maxCount,
    this.maxSize,
    this.autoUpload = true,
    this.preview = true,
    this.multiple = true,
    this.accept,
    this.disabled = false,
    this.readonly = false,
    this.size = 80,
    this.gutter = 10,
    this.addText,
    this.name,
    this.action,
    this.header,
    this.formData,
    this.fileFieldName = 'file',
    this.uploadMethod,
    this.onFail,
  });

  /// 外部受控文件列表（传入非空即受控），否则组件自维护。
  final List<WotUploadFile> files;

  /// 自定义选文件（若提供则替代内置 file_picker 逻辑，参数为当前文件列表）。
  final ValueChanged<List<WotUploadFile>>? onAdd;

  /// 移除文件（受控模式下由外部刷新列表）。
  final ValueChanged<int>? onRemove;

  /// 点击预览文件时回调。
  final ValueChanged<WotUploadFile>? onClick;

  /// 文件列表变化回调（受控模式）。
  final ValueChanged<List<WotUploadFile>>? onChange;

  /// 单文件上传成功（模拟完成）后回调。
  final ValueChanged<WotUploadFile>? onUpload;

  /// 文件大小超过 [maxSize] 限制时回调。
  final ValueChanged<WotUploadFile>? onOverSize;

  /// 选文件后 / 上传前的拦截钩子；返回 false 则跳过该文件。
  final bool Function(WotUploadFile)? onBeforeUpload;

  /// 最大允许的文件数量；达到后不再显示添加按钮。
  final int? maxCount;

  /// 单文件大小上限（字节）；超过的文件不会加入列表，并触发 [onOverSize]。
  final int? maxSize;

  /// 是否选中文件后自动上传（模拟）；为 false 时以 pending 状态加入，需外部触发。
  final bool autoUpload;

  /// 是否允许点击文件预览大图；默认 true。
  final bool preview;

  final bool multiple;
  final String? accept;
  final bool disabled;

  /// 是否只读：不可添加 / 删除文件（预览仍可用），保持正常配色。
  final bool readonly;
  final double size;
  final double gutter;
  final String? addText;
  final String? name;

  /// 上传地址（wot `action` 语义）。设置后使用内置 multipart 上传。
  ///
  /// **web 平台不支持**：无 `dart:io`，请改用 [uploadMethod] 自行实现
  ///（如 `package:http` 的 `BrowserClient` 或 `dart:html` 的 `HttpRequest`）。
  final String? action;

  /// 上传请求头（wot `header` 语义）。
  final Map<String, String>? header;

  /// 随文件一并提交的额外表单字段。
  final Map<String, String>? formData;

  /// multipart 中文件字段名，默认 `file`。
  ///
  /// 注意：wot 的 `name` 在此组件中已被「表单字段名」占用，故另取此名。
  final String fileFieldName;

  /// 自定义上传实现；提供后**优先于** [action]，且全平台可用。
  final WotUploadMethod? uploadMethod;

  /// 单个文件上传失败时回调。
  final ValueChanged<WotUploadFile>? onFail;

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

  /// 是否禁用（显式或父级 WotFieldScope 下发）。
  bool get _isDisabled =>
      widget.disabled || WotFieldScope.read(context)?.state == WotFieldState.disabled;

  /// 是否锁定编辑（禁用或只读）——锁添加 / 删除，但允许预览。
  bool get _locked {
    if (_isDisabled || widget.readonly) return true;
    return WotFieldScope.read(context)?.state == WotFieldState.readonly;
  }

  Future<void> _pick() async {
    if (_locked || !_canAdd) return;

    // 提供自定义 onAdd 时交给宿主。
    if (widget.onAdd != null) {
      widget.onAdd!(_files);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget.multiple,
      type: _fileType,
      allowedExtensions: _allowedExtensions,
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
          status: widget.autoUpload ? WotUploadStatus.loading : WotUploadStatus.pending,
        ),
    ];

    // 大小校验：超过 maxSize 的文件不加入列表，并触发 onOverSize。
    if (widget.maxSize != null) {
      picked.removeWhere((f) {
        if (f.size != null && f.size! > widget.maxSize!) {
          widget.onOverSize?.call(f);
          return true;
        }
        return false;
      });
    }

    for (var i = 0; i < picked.length; i++) {
      // 上传前拦截：返回 false 跳过该文件。
      if (widget.onBeforeUpload?.call(picked[i]) == false) {
        picked.removeAt(i);
        i--;
      }
    }
    if (picked.isEmpty) return;

    setState(() {
      _files.addAll(picked);
    });
    widget.onChange?.call(_files);

    // 自动上传：走真实上传（uploadMethod 优先，其次 action）。
    if (widget.autoUpload) {
      for (final f in picked) {
        _startUpload(f);
      }
    }
  }

  /// 把 [WotUpload.accept] 解析为 `file_picker` 的 [FileType]。
  FileType get _fileType {
    final a = widget.accept?.trim().toLowerCase();
    if (a == null || a.isEmpty) return FileType.any;
    if (a.startsWith('image')) return FileType.image;
    if (a.startsWith('video')) return FileType.video;
    if (a.startsWith('audio')) return FileType.audio;
    if (a.startsWith('media')) return FileType.media;
    return FileType.custom;
  }

  /// [WotUpload.accept] 解析出的扩展名列表；仅 [FileType.custom] 时需要。
  List<String>? get _allowedExtensions {
    if (_fileType != FileType.custom) return null;
    final exts = widget.accept!
        .toLowerCase()
        .split(',')
        .map((e) => e.trim())
        .map((e) => e.startsWith('*.') ? e.substring(2) : e)
        .map((e) => e.startsWith('.') ? e.substring(1) : e)
        .where((e) => e.isNotEmpty && !e.contains('*'))
        .toList();
    return exts.isEmpty ? null : exts;
  }

  /// 真实上传：[WotUpload.uploadMethod] 优先，其次 [WotUpload.action] 内置实现。
  Future<void> _startUpload(WotUploadFile f) async {
    if (_files.indexWhere((e) => identical(e, f)) < 0) return;

    // copyWith 会换掉对象，因此用 current 跟踪列表里最新的那一份。
    var current = f;
    void setFile(WotUploadFile next) {
      if (!mounted) return;
      final i = _files.indexWhere((e) => identical(e, current));
      if (i < 0) return;
      _files[i] = next;
      current = next;
      setState(() {});
    }

    setFile(f.copyWith(status: WotUploadStatus.loading, percent: 0));

    WotUploadResponse res;
    try {
      final custom = widget.uploadMethod;
      if (custom != null) {
        res = await custom(f, (p) {
          setFile(current.copyWith(status: WotUploadStatus.loading, percent: p));
        });
      } else {
        final action = widget.action;
        if (action == null || action.isEmpty) {
          res = const WotUploadResponse(
            statusCode: 0,
            error: '未配置 action 或 uploadMethod，无法上传',
          );
        } else {
          final uri = Uri.tryParse(action);
          if (uri == null) {
            res = const WotUploadResponse(statusCode: 0, error: 'action 不是合法 URL');
          } else {
            res = await wotUploadViaHttp(
              uri: uri,
              header: widget.header,
              formData: widget.formData,
              fieldName: widget.fileFieldName,
              fileName: f.name ?? 'file',
              bytes: f.bytes ?? Uint8List(0),
              contentType: f.type,
              onProgress: (p) {
                setFile(current.copyWith(
                    status: WotUploadStatus.loading, percent: p));
              },
            );
          }
        }
      }
    } catch (e) {
      res = WotUploadResponse(statusCode: 0, error: '$e');
    }

    final done = res.isSuccess
        ? current.copyWith(
            status: WotUploadStatus.success,
            percent: 100,
            url: res.url ?? current.url,
          )
        : current.copyWith(status: WotUploadStatus.fail, percent: 0);
    setFile(done);

    if (res.isSuccess) {
      widget.onUpload?.call(done);
    } else {
      widget.onFail?.call(done);
    }
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

  /// 点击文件：可预览大图并回调 [onClick]。
  void _preview(BuildContext context, WotUploadFile f) {
    widget.onClick?.call(f);
    if (!widget.preview) return;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 480),
            child: f.bytes != null
                ? Image.memory(f.bytes!, fit: BoxFit.contain)
                : (f.thumbUrl.isNotEmpty
                    ? Image.network(
                        f.thumbUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48),
                      )
                    : const Icon(Icons.insert_drive_file, size: 48)),
          ),
        ),
      ),
    );
  }

  List<WotUploadFile> get _display => _controlled ? _files : _files;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final files = _display;
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: widget.gutter,
          runSpacing: widget.gutter,
          children: [
            for (final f in files)
              _item(context, f),
            if (_canAdd && !_locked)
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
    // disabled 额外整体淡化；readonly 仅锁添加 / 删除，配色不变。
    return _isDisabled ? Opacity(opacity: 0.5, child: panel) : panel;
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
        onTap: () => _preview(context, f),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (f.bytes != null)
              Image.memory(f.bytes!, fit: BoxFit.cover)
            else if (f.thumbUrl.isNotEmpty)
              Image.network(f.thumbUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _filePlaceholder(context, f))
            else
              _filePlaceholder(context, f),
            // 上传中：加载动画 + 真实进度百分比。
            if (f.status == WotUploadStatus.loading)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      if (f.percent != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${f.percent!.round()}%',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // 上传失败：点击重试。
            if (f.status == WotUploadStatus.fail)
              GestureDetector(
                onTap: () => _startUpload(f),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: const Center(
                    child: Icon(Icons.refresh, size: 22, color: Colors.white),
                  ),
                ),
              ),
            if (!_locked)
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
            Text(widget.addText ?? tr(context, 'wot.common.add'),
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