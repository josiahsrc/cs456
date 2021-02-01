import 'dart:ui' as ui;

import 'package:flutter/material.dart';

@immutable
class Thumb {
  const Thumb({
    this.initialValue = 0.0,
    this.onStart,
    this.onEnd,
    this.onChanged,
  })  : assert(initialValue != null),
        super();

  final double initialValue;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final ValueChanged<double> onChanged;
}

@immutable
class ThumbSliderDecoration {
  const ThumbSliderDecoration({
    this.thumbRadius = 25.0,
    this.thumbColorA = Colors.blue,
    this.thumbColorB = Colors.red,
    this.lineThickness = 2,
    this.lineColor = Colors.grey,
  })  : assert(thumbRadius != null),
        assert(thumbColorA != null),
        assert(thumbColorB != null),
        assert(lineThickness != null && lineThickness >= 0),
        assert(lineThickness != null && lineThickness >= 0),
        super();

  final double thumbRadius;
  final Color thumbColorA;
  final Color thumbColorB;
  final double lineThickness;
  final Color lineColor;

  double get thumbDiameter => thumbRadius * 2;
}

@immutable
class _ThumbState {
  const _ThumbState({
    @required this.value,
    @required this.pressed,
    @required this.nrmValue,
  })  : assert(value != null),
        assert(pressed != null),
        assert(nrmValue != null),
        super();

  final double value;
  final bool pressed;
  final double nrmValue;

  _ThumbState copyWith({
    double value,
    bool pressed,
    double nrmValue,
  }) {
    return _ThumbState(
      value: value ?? this.value,
      pressed: pressed ?? this.pressed,
      nrmValue: nrmValue ?? this.nrmValue,
    );
  }
}

class ThumbSlider extends StatefulWidget {
  const ThumbSlider({
    Key key,
    this.valueA = 0.0,
    this.valueB = 1.0,
    this.decoration = const ThumbSliderDecoration(),
    @required this.thumbs,
  })  : assert(valueA != null),
        assert(valueB != null),
        assert(valueA < valueB),
        assert(decoration != null),
        assert(thumbs != null && thumbs.length >= 0),
        super(key: key);

  final double valueA;
  final double valueB;
  final ThumbSliderDecoration decoration;
  final List<Thumb> thumbs;

  @override
  _ThumbSliderState createState() => _ThumbSliderState();
}

class _ThumbSliderState extends State<ThumbSlider> {
  List<_ThumbState> _thumbStates;

  @override
  void initState() {
    _syncThumbStates();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ThumbSlider prev) {
    _syncThumbStates();
    super.didUpdateWidget(prev);
  }

  void _syncThumbStates() {
    _thumbStates = [
      for (final thumb in widget.thumbs)
        _ThumbState(
          value: thumb.initialValue.clamp(widget.valueA, widget.valueA),
          nrmValue: _normalizeValue(thumb.initialValue),
          pressed: false,
        ),
    ];
  }

  void _resolveCollisions() {}

  double _normalizeValue(double value) {
    final min = widget.valueA.abs();

    if (widget.valueA < 0) {
      final max = widget.valueB + min;
      final val = value + min;
      return val / max;
    } else {
      final max = widget.valueB - min;
      final val = value - min;
      return val / max;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final containerWidth = mq.size.width;

    final thumbPositions = [
      for (int i = 0; i < widget.thumbs.length; ++i)
        Offset(
          _thumbStates[i].nrmValue * containerWidth,
          widget.decoration.thumbRadius,
        ),
    ];

    int getThumb(Offset pos) {
      for (int i = 0; i < widget.thumbs.length; ++i) {
        final thumbPos = thumbPositions[i];
        if ((thumbPos - pos).distance < widget.decoration.thumbRadius) {
          return i;
        }
      }

      return null;
    }

    void updatePress(int thumbIndex, Offset pos) {
      final clamped = pos.dx.clamp(0, containerWidth);
      final nrmValue = clamped / containerWidth;
      final value = ui.lerpDouble(widget.valueA, widget.valueB, nrmValue);

      setState(() {
        _thumbStates[thumbIndex] = _thumbStates[thumbIndex].copyWith(
          nrmValue: nrmValue,
          value: value,
        );
      });

      widget.thumbs[thumbIndex].onChanged?.call(value);
    }

    /// Here is where I declare my custom painter. The listener
    /// will wrap this widget. The painter will render a thumb
    /// and a slider based on the input tracked from the listener.
    final painter = CustomPaint(
      painter: _Painter(
        decoration: widget.decoration,
        thumbs: _thumbStates,
      ),
    );

    /// I'm overriding the listener here. The listener will
    /// be responsible for tracking input gestures on this.
    /// If an input gesture starts within the thumb, then the
    /// widget becomes "slidable".
    final listener = Listener(
      // onPointerDown: (event) {
      //   if (isPressValid(event.localPosition)) {
      //     widget.onStart?.call();
      //     updatePress(event.localPosition);
      //     setState(() => _isPressing = true);
      //   }
      // },
      // onPointerMove: (event) {
      //   if (_isPressing) {
      //     updatePress(event.localPosition);
      //   }
      // },
      // onPointerUp: (event) {
      //   if (_isPressing) {
      //     widget.onEnd?.call();
      //     setState(() => _isPressing = false);
      //   }
      // },
      // onPointerCancel: (event) {
      //   if (_isPressing) {
      //     widget.onEnd?.call();
      //     setState(() => _isPressing = false);
      //   }
      // },
      child: painter,
    );

    final content = Container(
      width: double.infinity,
      height: widget.decoration.thumbDiameter,
      child: listener,
    );

    return content;
  }
}

/// Draws the slider.
class _Painter extends CustomPainter {
  const _Painter({
    @required this.thumbs,
    @required this.decoration,
  })  : assert(thumbs != null),
        assert(decoration != null),
        super();

  final List<_ThumbState> thumbs;
  final ThumbSliderDecoration decoration;

  @override
  void paint(Canvas canvas, Size size) {
    final halfExtents = size / 2;

    // Draw line.
    {
      final start = Offset(0, halfExtents.height);
      final end = Offset(size.width, halfExtents.height);
      final paint = Paint()
        ..color = decoration.lineColor
        ..strokeWidth = decoration.lineThickness;

      canvas.drawLine(start, end, paint);
    }

    // Draw circles
    for (final thumb in thumbs) {
      final origin = Offset(
        thumb.nrmValue * size.width,
        halfExtents.height,
      );

      final paint = Paint()
        ..color = Color.lerp(
          decoration.thumbColorA,
          decoration.thumbColorA,
          thumb.nrmValue,
        );

      canvas.drawCircle(
        origin,
        decoration.thumbRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
