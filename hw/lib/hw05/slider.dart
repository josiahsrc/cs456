import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef CurvedSliderParametricCallback = double Function(double t);

@immutable
class CurvedSliderCalculator {
  const CurvedSliderCalculator({
    @required CurvedSliderParametricCallback computeX,
    @required CurvedSliderParametricCallback computeY,
    this.join = true,
  })  : assert(computeX != null),
        assert(computeY != null),
        assert(join != null),
        _computeX = computeX,
        _computeY = computeY,
        super();

  factory CurvedSliderCalculator.elipse({
    double fill = 1,
    double offset = 0,
  }) {
    assert(fill != null && fill >= 0 && fill <= 1);
    assert(offset != null && offset >= 0 && offset <= 1);

    double getEffectiveT(double t) {
      final rOffset = 2 * math.pi * offset;
      return t * fill + rOffset;
    }

    return CurvedSliderCalculator(
      computeX: (t) => math.cos(getEffectiveT(t)),
      computeY: (t) => math.sin(getEffectiveT(t)),
      join: fill == 1,
    );
  }

  final CurvedSliderParametricCallback _computeX;
  final CurvedSliderParametricCallback _computeY;
  final bool join;

  double computeX(double t) {
    return _computeX.call(t);
  }

  double computeY(double t) {
    return _computeY.call(t);
  }
}

@immutable
class CurvedSliderDecoration {
  const CurvedSliderDecoration({
    this.lineThickness = 6,
    this.lineColor = Colors.grey,
  })  : assert(lineThickness != null && lineThickness >= 0),
        assert(lineColor != null),
        super();

  final double lineThickness;
  final Color lineColor;
}

class CurvedSlider extends StatefulWidget {
  const CurvedSlider({
    Key key,
    @required this.calculator,
    this.decoration = const CurvedSliderDecoration(),
  })  : assert(calculator != null),
        assert(decoration != null),
        super(key: key);

  final CurvedSliderCalculator calculator;
  final CurvedSliderDecoration decoration;

  @override
  _CurvedSliderState createState() => _CurvedSliderState();
}

class _CurvedSliderState extends State<CurvedSlider> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _layout);
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final painter = CustomPaint(
      painter: _Painter(
        calculator: widget.calculator,
        decoration: widget.decoration,
      ),
    );

    final gestures = Listener(
      onPointerDown: (event) {},
      onPointerMove: (event) {},
      onPointerUp: (event) {},
      onPointerCancel: (event) {},
      child: painter,
    );

    return gestures;
  }
}

@immutable
class _Thumb {
  const _Thumb({
    @required this.normal,
  })  : assert(normal != null && normal >= 0 && normal <= 1),
        super();

  final double normal;

  _Thumb copyWith({
    double normal,
  }) {
    return _Thumb(
      normal: normal ?? this.normal,
    );
  }
}

/// Draws the slider.
class _Painter extends CustomPainter {
  const _Painter({
    @required this.calculator,
    @required this.decoration,
  })  : assert(calculator != null),
        assert(decoration != null),
        super();

  final CurvedSliderCalculator calculator;
  final CurvedSliderDecoration decoration;

  @override
  void paint(Canvas canvas, Size size) {
    final segments = 100;

    double getX(double t) {
      return calculator.computeX(t);
    }

    double getY(double t) {
      return calculator.computeY(t);
    }

    double getT(int i) {
      return ((i).toDouble() / segments) * 2 * math.pi;
    }

    double getNormal(double val, double min, double max) {
      final absmin = min.abs();
      if (min > 0) {
        return (val - absmin) / (max - absmin);
      } else {
        return (val + absmin) / (max + absmin);
      }
    }

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (int i = 0; i < segments; ++i) {
      final t = getT(i);
      final x = getX(t);
      final y = getY(t);

      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    double getCanvasX(double t) {
      return getNormal(getX(t), minX, maxX) * size.width;
    }

    double getCanvasY(double t) {
      return getNormal(getY(t), minY, maxY) * size.height;
    }

    // Draw curved slider line.
    {
      final path = Path()..moveTo(getCanvasX(0), getCanvasY(0));
      for (int i = 0; i < segments; ++i) {
        final t = getT(i);
        final x = getCanvasX(t);
        final y = getCanvasY(t);

        path.lineTo(x, y);
      }

      final paint = Paint()
        ..color = decoration.lineColor
        ..strokeWidth = decoration.lineThickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (calculator.join) path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
