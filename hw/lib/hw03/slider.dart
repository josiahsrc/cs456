import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

typedef void DoubleConsumer(double value);

class ThumbSlider extends StatefulWidget {
  const ThumbSlider({
    Key key,
    this.onStart,
    this.onEnd,
    this.onChanged,
    this.valueA = 0.0,
    this.valueB = 1.0,
    this.initialValue = 0.0,
    this.colorA = Colors.blue,
    this.colorB = Colors.red,
  })  : assert(valueA != null),
        assert(valueB != null),
        assert(valueA < valueB),
        assert(initialValue != null),
        assert(colorA != null),
        assert(colorB != null),
        super(key: key);

  final VoidCallback onStart;
  final VoidCallback onEnd;
  final DoubleConsumer onChanged;
  final double valueA;
  final double valueB;
  final double initialValue;
  final Color colorA;
  final Color colorB;

  @override
  _ThumbSliderState createState() => _ThumbSliderState();
}

class _ThumbSliderState extends State<ThumbSlider> {
  double _normalizedValue;
  bool _isPressing = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final thumbRadius = 25.0;
    final thumbDiameter = thumbRadius * 2;
    final lineThickness = 2.0;
    final containerWidth = mq.size.width;

    if (_normalizedValue == null) {
      final clamped = widget.initialValue.clamp(widget.valueA, widget.valueB);
      _normalizedValue = clamped / containerWidth;
    }

    final thumbPos = Offset(
      _normalizedValue * containerWidth,
      thumbRadius,
    );

    bool isPressValid(Offset pos) {
      return (thumbPos - pos).distance < thumbRadius;
    }

    void updatePress(Offset pos) {
      final clamped = pos.dx.clamp(0, containerWidth);
      setState(() => _normalizedValue = clamped / containerWidth);

      final value = ui.lerpDouble(
        widget.valueA,
        widget.valueB,
        _normalizedValue,
      );

      widget.onChanged?.call(value);
    }

    final painter = CustomPaint(
      painter: _Painter(
        color: Color.lerp(widget.colorA, widget.colorB, _normalizedValue),
        value: _normalizedValue,
        thumbRadius: thumbRadius,
        lineThickness: lineThickness,
      ),
    );

    final listener = Listener(
      onPointerDown: (event) {
        if (isPressValid(event.localPosition)) {
          widget.onStart?.call();
          updatePress(event.localPosition);
          _isPressing = true;
        }
      },
      onPointerMove: (event) {
        if (_isPressing) {
          updatePress(event.localPosition);
        }
      },
      onPointerCancel: (event) {
        if (_isPressing) {
          widget.onEnd?.call();
        }
        _isPressing = false;
      },
      onPointerUp: (event) {
        if (_isPressing) {
          widget.onEnd?.call();
        }
        _isPressing = false;
      },
      child: painter,
    );

    final content = Container(
      width: double.infinity,
      height: thumbDiameter,
      color: Colors.grey,
      child: listener,
    );

    return content;
  }
}

class _Painter extends CustomPainter {
  const _Painter({
    @required this.value,
    @required this.color,
    @required this.thumbRadius,
    @required this.lineThickness,
  })  : assert(value != null),
        assert(color != null),
        assert(thumbRadius != null),
        assert(lineThickness != null),
        super();

  final double value;
  final Color color;
  final double thumbRadius;
  final double lineThickness;

  @override
  void paint(Canvas canvas, Size size) {
    final halfExtents = size / 2;

    // Draw line.
    {
      final start = Offset(0, halfExtents.height);
      final end = Offset(size.width, halfExtents.height);
      final paint = Paint()
        ..color = color
        ..strokeWidth = lineThickness;

      canvas.drawLine(start, end, paint);
    }

    // Draw circle.
    {
      final origin = Offset(value * size.width, halfExtents.height);
      final paint = Paint()..color = color;

      canvas.drawCircle(origin, thumbRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) {
    return old.value != this.value ||
        old.color != this.color ||
        old.lineThickness != this.lineThickness ||
        old.thumbRadius != this.thumbRadius;
  }
}
