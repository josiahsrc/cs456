import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef CurvedSliderParametricCallback = double Function(double t);

const _segments = 300;

@immutable
class CurvedSliderDecoration {
  const CurvedSliderDecoration({
    this.lineThickness = 6,
    this.lineColor = Colors.grey,
    this.thumbRadius = 16,
    this.thumbColor = Colors.red,
  })  : assert(lineThickness != null && lineThickness >= 0),
        assert(lineColor != null),
        assert(thumbRadius != null && thumbRadius >= 0),
        assert(thumbColor != null),
        super();

  final double lineThickness;
  final Color lineColor;
  final double thumbRadius;
  final Color thumbColor;
}

@immutable
class CurvedSliderThumb {
  const CurvedSliderThumb() : super();
}

class CurvedSlider extends StatefulWidget {
  const CurvedSlider({
    Key key,
    this.decoration = const CurvedSliderDecoration(),
    @required this.computeX,
    @required this.computeY,
    @required this.join,
  })  : assert(decoration != null),
        assert(computeX != null),
        assert(computeY != null),
        assert(join != null),
        super(key: key);

  factory CurvedSlider.elipse({
    double fill = 1,
    double offset = 0,
  }) {
    assert(fill != null && fill >= 0 && fill <= 1);
    assert(offset != null && offset >= 0 && offset <= 1);

    double getEffectiveT(double t) {
      final rOffset = 2 * math.pi * offset;
      return t * fill + rOffset;
    }

    return CurvedSlider(
      computeX: (t) => math.cos(getEffectiveT(t)),
      computeY: (t) => math.sin(getEffectiveT(t)),
      join: fill == 1.0,
    );
  }

  final CurvedSliderDecoration decoration;
  final CurvedSliderParametricCallback computeX;
  final CurvedSliderParametricCallback computeY;
  final bool join;

  @override
  _CurvedSliderState createState() => _CurvedSliderState();
}

class _CurvedSliderState extends State<CurvedSlider> {
  final List<Offset> nrmLinePoints = [];
  final List<Offset> nrmThumbPoints = [];

  @override
  void initState() {
    _sync();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CurvedSlider oldWidget) {
    _sync();
    super.didUpdateWidget(oldWidget);
  }

  void _sync() {
    double getX(double t) {
      return widget.computeX.call(t);
    }

    double getY(double t) {
      return widget.computeY.call(t);
    }

    double getT(int i) {
      return ((i).toDouble() / _segments) * 2 * math.pi;
    }

    double getNrm(double val, double min, double max) {
      final absmin = min.abs();
      if (min > 0) {
        return (val - absmin) / (max - absmin);
      } else {
        return (val + absmin) / (max + absmin);
      }
    }

    // Get parametric bounds.
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (int i = 0; i < _segments; ++i) {
      final t = getT(i);
      final x = getX(t);
      final y = getY(t);

      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    // Cache normalized points.
    nrmLinePoints.clear();
    for (int i = 0; i < _segments; ++i) {
      final t = getT(i);
      nrmLinePoints.add(Offset(
        getNrm(getX(t), minX, maxX),
        getNrm(getY(t), minY, maxY),
      ));
    }
  }

  Offset _closestOnLine(Offset nrmPoint) {
    Offset closestNrm;
    var closestDist = double.infinity;

    for (final offset in nrmLinePoints) {
      var dist = (nrmPoint - offset).distanceSquared;
      if (dist < closestDist) {
        closestDist = dist;
        closestNrm = offset;
      }
    }

    return closestNrm;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _layout);
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);

    Offset getNrm(Offset loc) {
      return Offset(
        loc.dx / size.width,
        loc.dy / size.height,
      );
    }

    final painter = CustomPaint(
      painter: _Painter(
        nrmLinePoints: nrmLinePoints,
        nrmThumbPoints: nrmThumbPoints,
        join: widget.join,
        decoration: widget.decoration,
      ),
    );

    final gestures = Listener(
      onPointerDown: (event) {
        // final nrm = getNrm(event.localPosition);
      },
      onPointerMove: (event) {},
      onPointerUp: (event) {},
      onPointerCancel: (event) {},
      child: painter,
    );

    return gestures;
  }
}

/// Draws the slider.
class _Painter extends CustomPainter {
  const _Painter({
    @required this.nrmLinePoints,
    @required this.nrmThumbPoints,
    @required this.join,
    @required this.decoration,
  })  : assert(nrmLinePoints != null),
        assert(nrmThumbPoints != null),
        assert(join != null),
        assert(decoration != null),
        super();

  final List<Offset> nrmLinePoints;
  final List<Offset> nrmThumbPoints;
  final bool join;
  final CurvedSliderDecoration decoration;

  @override
  void paint(Canvas canvas, Size size) {
    assert(nrmLinePoints.length > 0);

    double getCanvasX(double nrmX) {
      return nrmX * size.width;
    }

    double getCanvasY(double nrmY) {
      return nrmY * size.height;
    }

    // Draw line.
    {
      final path = Path()..moveTo(
        getCanvasX(nrmLinePoints.first.dx),
        getCanvasY(nrmLinePoints.first.dy),
      );

      for (final nrmPoint in nrmLinePoints) {
        final x = getCanvasX(nrmPoint.dx);
        final y = getCanvasY(nrmPoint.dy);
        path.lineTo(x, y);
      }

      final paint = Paint()
        ..color = decoration.lineColor
        ..strokeWidth = decoration.lineThickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (join) path.close();
      canvas.drawPath(path, paint);
    }

    // Draw thumbs.
    {
      for (final nrmPoint in nrmThumbPoints) {
        final x = getCanvasX(nrmPoint.dx);
        final y = getCanvasY(nrmPoint.dy);

        final paint = Paint()..color = decoration.thumbColor;

        canvas.drawCircle(
          Offset(x, y),
          decoration.thumbRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
