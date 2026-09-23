import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/wot_state.dart';
import '../../locale/wot_messages.dart';
import '../../theme/wot_theme.dart';

/// 导出图片类型，对应 wot `wd-signature` 的 `file-type`。
enum WotSignatureFileType {
  /// PNG（无损，默认）。
  png,

  /// JPG（有损）。需引擎支持 `ImageByteFormat.jpeg`（Flutter ≥ 3.22）；
  /// 当前引擎不支持时自动回退为 PNG，[WotSignature.quality] 随之失效。
  jpg,
}

/// 签名确认结果，对应 wot `SignatureResult`。
///
/// - [success] 为 true 时 [bytes] 为导出图片的二进制（PNG/JPG 按 [WotSignature.fileType]）。
/// - 画板为空（没有任何笔画）时 [success] 为 false、[bytes] 为 null。
class WotSignatureResult {
  const WotSignatureResult({required this.success, this.bytes});

  final bool success;
  final Uint8List? bytes;
}

/// 手写签名板，对应 wot `wd-signature`。用 [CustomPainter] 自绘笔画，
/// 支持导出图片（[confirm] / [WotSignature.onConfirm]）与历史撤销恢复（[enableHistory]）。
class WotSignature extends StatefulWidget {
  const WotSignature({
    super.key,
    this.onUpdate,
    this.onClear,
    this.onConfirm,
    this.penColor,
    this.lineWidth = 3,
    this.bgColor,
    this.height = 200,
    this.disabled = false,
    this.readonly = false,
    this.error = false,
    this.fileType = WotSignatureFileType.png,
    this.quality = 1,
    this.exportScale = 1,
    this.enableHistory = false,
    this.step = 1,
  });

  /// 书写状态变化回调，参数表示是否有内容（每次落笔结束 / 撤销 / 恢复 / 清空后触发）。
  final ValueChanged<bool>? onUpdate;

  /// 清空回调（点击清空按钮时触发）。
  final VoidCallback? onClear;

  /// 确认导出回调，参数为 [WotSignatureResult]（点击「确认」或调用 [confirm] 时触发）。
  final ValueChanged<WotSignatureResult>? onConfirm;

  /// 画笔颜色，默认使用主题主文本色。
  final Color? penColor;

  /// 笔画粗细，默认 3。
  final double lineWidth;

  /// 背景颜色，默认使用主题填充色。导出图片时也作为画布底色。
  final Color? bgColor;

  /// 画板高度，默认 200。
  final double height;

  /// 是否禁用书写，默认 false。禁用时整体淡化且不可交互。
  final bool disabled;

  /// 是否只读：不可书写 / 清空 / 撤销（保持正常配色），默认 false。
  final bool readonly;

  /// 是否处于校验失败态（error 态）。命中时画板描红边。
  final bool error;

  /// 导出图片类型，默认 [WotSignatureFileType.png]。
  final WotSignatureFileType fileType;

  /// 导出图片质量（仅 JPG 生效，0~1），默认 1。
  final double quality;

  /// 导出图片缩放比例（提高清晰度用，如 2 表示 2 倍像素），默认 1。
  final double exportScale;

  /// 是否开启历史记录（撤销 / 恢复），默认 false。
  final bool enableHistory;

  /// 撤销 / 恢复的步长（一次操作的笔画数），默认 1。
  final int step;

  @override
  State<WotSignature> createState() => _WotSignatureState();
}

class _WotSignatureState extends State<WotSignature> {
  final List<List<Offset>> _strokes = [];
  List<Offset>? _current;
  final List<List<Offset>> _redoStack = [];
  bool _hasInk = false;

  final GlobalKey _boundaryKey = GlobalKey();

  void _notifyUpdate() => widget.onUpdate?.call(_strokes.isNotEmpty);

  void _start(DragStartDetails d) {
    if (widget.disabled) return;
    setState(() {
      _current = [d.localPosition];
      _strokes.add(_current!);
      _hasInk = true;
    });
  }

  void _update(DragUpdateDetails d) {
    if (widget.disabled || _current == null) return;
    setState(() => _current!.add(d.localPosition));
  }

  void _end(DragEndDetails d) {
    if (_current == null) return;
    setState(() => _current = null);
    // 新笔画提交后，重做历史失效。
    if (widget.enableHistory) _redoStack.clear();
    _notifyUpdate();
  }

  /// 清空画板（同时清空重做历史）。
  void clear() {
    setState(() {
      _strokes.clear();
      _current = null;
      _redoStack.clear();
      _hasInk = false;
    });
    widget.onClear?.call();
    _notifyUpdate();
  }

  /// 撤销最近 [widget.step] 笔（仅 [enableHistory] 生效）。
  void revoke() {
    if (!widget.enableHistory || _strokes.isEmpty) return;
    setState(() {
      final n = widget.step.clamp(1, _strokes.length);
      for (var i = 0; i < n; i++) {
        _redoStack.add(_strokes.removeLast());
      }
      _hasInk = _strokes.isNotEmpty;
    });
    _notifyUpdate();
  }

  /// 恢复最近 [widget.step] 笔（仅 [enableHistory] 生效）。
  void restore() {
    if (!widget.enableHistory || _redoStack.isEmpty) return;
    setState(() {
      final n = widget.step.clamp(1, _redoStack.length);
      for (var i = 0; i < n; i++) {
        _strokes.add(_redoStack.removeLast());
      }
      _hasInk = true;
    });
    _notifyUpdate();
  }

  /// 解析导出格式：JPG 仅在引擎支持 `ImageByteFormat.jpeg` 时可用，否则回退 PNG。
  ImageByteFormat _exportFormat() {
    if (widget.fileType == WotSignatureFileType.png) return ImageByteFormat.png;
    for (final e in ImageByteFormat.values) {
      if (e.name == 'jpeg') return e;
    }
    return ImageByteFormat.png;
  }

  /// 导出签名图片：截取画板为 [Uint8List]（类型 / 缩放见对应参数），
  /// 并触发 [WotSignature.onConfirm]。画板为空时返回 [WotSignatureResult.success]=false。
  ///
  /// 也可在外部通过 [GlobalKey] 持有本组件调用 `confirm()`，例如弹窗 `afterEnter` 后导出。
  Future<WotSignatureResult> confirm() async {
    const empty = WotSignatureResult(success: false, bytes: null);
    if (_strokes.isEmpty) {
      widget.onConfirm?.call(empty);
      return empty;
    }
    final ctx = _boundaryKey.currentContext;
    final boundary = ctx?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      widget.onConfirm?.call(empty);
      return empty;
    }
    final image = await boundary.toImage(pixelRatio: widget.exportScale);
    final data = await image.toByteData(format: _exportFormat());
    final bytes = data?.buffer.asUint8List();
    final result = WotSignatureResult(success: bytes != null, bytes: bytes);
    widget.onConfirm?.call(result);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final fieldScope = WotFieldScope.of(context);
    final disabled = widget.disabled || (fieldScope?.state == WotFieldState.disabled);
    final readonly = widget.readonly || (fieldScope?.state == WotFieldState.readonly);
    final hasError = widget.error || (fieldScope?.error ?? false);
    // 锁定书写 / 清空 / 撤销 / 恢复（只读与禁用都锁，区别在是否淡化）。
    final locked = disabled || readonly;

    final bg = widget.bgColor ?? scheme.filledStrong;
    final pen = widget.penColor ?? scheme.textMain;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            // 仅在 error（且未禁用）时描红边，其余态保持原有的无边框圆角观感。
            border: hasError && !disabled
                ? Border.all(color: scheme.dangerMain)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 仅绘制区进入截图边界（清空 / 底部按钮不入库）。
              RepaintBoundary(
                key: _boundaryKey,
                child: GestureDetector(
                  onPanStart: locked ? null : _start,
                  onPanUpdate: locked ? null : _update,
                  onPanEnd: locked ? null : _end,
                  // 无障碍：画板区对读屏说明用途（手写签名区域）。
                  child: Semantics(
                    label: tr(context, 'wot.signature.area'),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _SignaturePainter(
                        strokes: _strokes,
                        penColor: pen,
                        lineWidth: widget.lineWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                // 无障碍：清空是图标按钮，补 button 角色 + 文案（图标本身对读屏不可读）。
                child: Semantics(
                  button: true,
                  label: tr(context, 'wot.common.clear'),
                  onTap: locked ? null : clear,
                  child: GestureDetector(
                    onTap: locked ? null : clear,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.delete_outline,
                          size: 18,
                          color: disabled ? scheme.iconDisabled : scheme.iconAuxiliary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildFooter(locked: locked, disabled: disabled),
      ],
    );
    return disabled ? Opacity(opacity: 0.5, child: content) : content;
  }

  Widget _buildFooter({required bool locked, required bool disabled}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(
          onPressed: locked ? null : clear,
          child: Text(tr(context, 'wot.common.clear')),
        ),
        if (widget.enableHistory) ...[
          TextButton(
            onPressed: (locked || _strokes.isEmpty) ? null : revoke,
            child: Text(tr(context, 'wot.common.revoke')),
          ),
          TextButton(
            onPressed: (locked || _redoStack.isEmpty) ? null : restore,
            child: Text(tr(context, 'wot.common.restore')),
          ),
        ],
        FilledButton(
          // 只读仍允许「确认」导出当前签名；禁用则整体不可用。
          onPressed: (!disabled && _hasInk) ? () => confirm() : null,
          child: Text(tr(context, 'wot.common.confirm')),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.penColor,
    required this.lineWidth,
  });

  final List<List<Offset>> strokes;
  final Color penColor;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = penColor;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(stroke.first, lineWidth / 2, paint);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
