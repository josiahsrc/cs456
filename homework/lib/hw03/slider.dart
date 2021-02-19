import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ThumbSlider extends StatefulWidget {
  /// Here is my constructor definition for my slider. This
  /// allows the caller to configure the widget.
  ///
  /// Callbacks:
  /// - onStart, invoked when the thumb becomes active.
  /// - onChange, invoked when the thumb changes location.
  /// - onEnd, invoked when the thumb becomes inactive.
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
    this.thumbRadius = 25,
    this.lineThickness = 2,
  })  : assert(valueA != null),
        assert(valueB != null),
        assert(valueA < valueB),
        assert(initialValue != null),
        assert(colorA != null),
        assert(colorB != null),
        assert(thumbRadius != null && thumbRadius >= 0),
        assert(lineThickness != null && lineThickness >= 0),
        super(key: key);

  final VoidCallback onStart;
  final VoidCallback onEnd;
  final ValueChanged<double> onChanged;
  final double valueA;
  final double valueB;
  final double initialValue;
  final Color colorA;
  final Color colorB;
  final double thumbRadius;
  final double lineThickness;

  double get thumbDiameter => thumbRadius * 2;

  @override
  _ThumbSliderState createState() => _ThumbSliderState();
}

class _ThumbSliderState extends State<ThumbSlider> {
  double _normalizedValue;
  bool _isPressing = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final containerWidth = mq.size.width;

    if (_normalizedValue == null) {
      final clamped = widget.initialValue.clamp(
        widget.valueA,
        widget.valueB,
      );

      _normalizedValue = clamped / containerWidth;
    }

    final thumbPos = Offset(
      _normalizedValue * containerWidth,
      widget.thumbRadius,
    );

    bool isPressValid(Offset pos) {
      return (thumbPos - pos).distance < widget.thumbRadius;
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

    /// Here is where I declare my custom painter. The listener
    /// will wrap this widget. The painter will render a thumb
    /// and a slider based on the input tracked from the listener.
    final painter = CustomPaint(
      /// This is where I'm creating my painter.
      painter: _Painter(
        color: Color.lerp(
          widget.colorA,
          widget.colorB,
          _normalizedValue,
        ),
        value: _normalizedValue,
        thumbRadius: widget.thumbRadius,
        lineThickness: widget.lineThickness,
      ),
    );

    /// I'm overriding the listener here. The listener will
    /// be responsible for tracking input gestures on this.
    /// If an input gesture starts within the thumb, then the
    /// widget becomes "slidable".
    final listener = Listener(
      onPointerDown: (event) {
        if (isPressValid(event.localPosition)) {
          widget.onStart?.call();
          updatePress(event.localPosition);
          setState(() => _isPressing = true);
        }
      },
      onPointerMove: (event) {
        if (_isPressing) {
          updatePress(event.localPosition);
        }
      },
      onPointerUp: (event) {
        if (_isPressing) {
          widget.onEnd?.call();
          setState(() => _isPressing = false);
        }
      },
      onPointerCancel: (event) {
        if (_isPressing) {
          widget.onEnd?.call();
          setState(() => _isPressing = false);
        }
      },
      child: painter,
    );

    final content = Container(
      width: double.infinity,
      height: widget.thumbDiameter,
      color: Colors.grey,
      child: listener,
    );

    return content;
  }
}

/// Draws the slider.
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
