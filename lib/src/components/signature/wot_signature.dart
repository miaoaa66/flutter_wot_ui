import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';

/// 手写签名板，对应 wot `wd-signature`。用 [CustomPainter] 自绘笔画。
class WotSignature extends StatefulWidget {
  const WotSignature({
    super.key,
    this.onUpdate,
    this.onClear,
    this.penColor,
    this.lineWidth = 3,
    this.bgColor,
    this.height = 200,
    this.disabled = false,
  });

  final ValueChanged<bool>? onUpdate;
  final VoidCallback? onClear;
  final Color? penColor;
  final double lineWidth;
  final Color? bgColor;
  final double height;
  final bool disabled;

  @override
  State<WotSignature> createState() => _WotSignatureState();
}

class _WotSignatureState extends State<WotSignature> {
  final List<List<Offset>> _strokes = [];
  List<Offset>? _current;
  bool _hasInk = false;

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
    setState(() {
      _current = null;
    });
    widget.onUpdate?.call(true);
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _current = null;
      _hasInk = false;
    });
    widget.onClear?.call();
  }

  bool get hasInk => _hasInk;

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final bg = widget.bgColor ?? scheme.filledStrong;
    final pen = widget.penColor ?? scheme.textMain;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onPanStart: _start,
        onPanUpdate: _update,
        onPanEnd: _end,
        child: CustomPaint(
          size: Size.infinite,
          painter: _SignaturePainter(
            strokes: _strokes,
            penColor: pen,
            lineWidth: widget.lineWidth,
          ),
          child: Align(
            alignment: const Alignment(1, 1),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: clear,
                child: Icon(Icons.delete_outline,
                    size: 18, color: scheme.iconAuxiliary),
              ),
            ),
          ),
        ),
      ),
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