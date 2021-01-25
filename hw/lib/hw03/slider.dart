import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef void DoubleConsumer(double value);

class ThumbSlider extends StatefulWidget {
  const ThumbSlider({
    Key key,
    this.onChanged,
    this.onStart,
    this.onEnd,
    this.initialValue = 0,
    this.thumbRadius = 16,
    this.thumbColorA = Colors.blue,
    this.thumbColorB = Colors.red,
    this.lineThickness = 2,
    this.lineColorA = Colors.blue,
    this.lineColorB = Colors.red,
  })  : assert(initialValue != null),
        assert(initialValue >= 0 && initialValue <= 1),
        assert(thumbRadius != null),
        assert(thumbColorA != null),
        assert(thumbColorB != null),
        assert(lineThickness != null),
        super(key: key);

  final DoubleConsumer onChanged;

  final VoidCallback onStart;

  final VoidCallback onEnd;

  final double initialValue;

  final double thumbRadius;

  final Color thumbColorA;

  final Color thumbColorB;

  final double lineThickness;

  final Color lineColorA;

  final Color lineColorB;

  double get diameter => thumbRadius * 2;

  @override
  _ThumbSliderState createState() => _ThumbSliderState();
}

class _ThumbSliderState extends State<ThumbSlider> {
  double _value;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = math.max(widget.lineThickness, widget.diameter);

    // An interpolated line color based on the value.
    final lineColor = Color.lerp(
      widget.lineColorA,
      widget.lineColorB,
      _value,
    );

    // An interpolated thumb color based on the value.
    final thumbColor = Color.lerp(
      widget.thumbColorA,
      widget.thumbColorB,
      _value,
    );

    // The bounds of the slider. Expand to fit the parent's
    // width, but clamp the height to match this widget.
    final drawer = SizedBox(
      height: height,
      child: CustomPaint(
        painter: _Painter(
          value: _value,
          lineColor: lineColor,
          lineThickness: widget.lineThickness,
          thumbColor: thumbColor,
          thumbRadius: widget.thumbRadius,
        ),
      ),
    );

    // A gesture arena for tracking pointer positions.
    final gestures = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        double getValue(double xpos) {
          final clamped = xpos.clamp(0, width);
          return clamped / width;
        }

        return GestureDetector(
          onPanDown: (details) {
            final v = getValue(details.localPosition.dx);
            setState(() => _value = v);
            widget.onStart?.call();
            widget.onChanged?.call(v);
          },
          onPanCancel: () {
            widget.onEnd?.call();
          },
          onPanEnd: (details) {
            widget.onEnd?.call();
          },
          onPanUpdate: (details) {
            final v = getValue(details.localPosition.dx);
            setState(() => _value = v);
            widget.onChanged?.call(v);
          },
          child: drawer,
        );
      },
    );

    return gestures;
  }
}

class _Painter extends CustomPainter {
  const _Painter({
    @required this.value,
    @required this.lineColor,
    @required this.lineThickness,
    @required this.thumbColor,
    @required this.thumbRadius,
  })  : assert(value != null),
        assert(lineColor != null),
        assert(lineThickness != null),
        assert(thumbColor != null),
        assert(thumbRadius != null),
        super();

  final double value;
  final Color lineColor;
  final double lineThickness;
  final Color thumbColor;
  final double thumbRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final halfExtents = size / 2;

    // Draw line.
    {
      final start = Offset(0, halfExtents.height);
      final end = Offset(size.width, halfExtents.height);
      final paint = Paint()
        ..color = lineColor
        ..strokeWidth = lineThickness;

      canvas.drawLine(start, end, paint);
    }

    // Draw thumb.
    {
      final origin = Offset(value * size.width, halfExtents.height);
      final paint = Paint()..color = thumbColor;

      canvas.drawCircle(origin, thumbRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) {
    return old.value != this.value &&
        old.lineColor != this.lineColor &&
        old.lineThickness != this.lineThickness &&
        old.thumbColor != this.thumbColor &&
        old.thumbRadius != this.thumbRadius;
  }
}
