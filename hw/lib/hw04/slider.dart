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
    @required this.nrmValue,
  })  : assert(value != null),
        assert(nrmValue != null),
        super();

  final double value;
  final double nrmValue;

  _ThumbState copyWith({
    double value,
    double nrmValue,
  }) {
    return _ThumbState(
      value: value ?? this.value,
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
  int _selectedThumb;

  bool get _isThumbSelected => _selectedThumb != null;

  @override
  void initState() {
    _syncThumbStates();
    _resolveCollisions();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ThumbSlider prev) {
    _syncThumbStates();
    _resolveCollisions();
    super.didUpdateWidget(prev);
  }

  void _syncThumbStates() {
    _selectedThumb = null;
    _thumbStates = [
      for (final thumb in widget.thumbs)
        _ThumbState(
          value: thumb.initialValue.clamp(widget.valueA, widget.valueA),
          nrmValue: _normalizeValue(thumb.initialValue),
        ),
    ];
  }

  /// Do a forward or backward pass to resolve thumb collisions.
  void _resolveCollisions([bool forward = true]) {
    assert(forward != null);
    assert(_thumbStates.length == widget.thumbs.length);

    if (_thumbStates.length == 0) {
      return;
    }

    _ThumbState prev;
    if (forward) {
      prev = _thumbStates[0];
      for (int i = 1; i < _thumbStates.length; ++i) {
        if (_thumbStates[i].nrmValue < prev.nrmValue) {
          _thumbStates[i] = _thumbStates[i].copyWith(
            nrmValue: prev.nrmValue,
            value: prev.value,
          );
        }

        prev = _thumbStates[i];
      }
    } else {
      prev = _thumbStates[_thumbStates.length - 1];
      for (int i = _thumbStates.length - 2; i >= 0; --i) {
        if (_thumbStates[i].nrmValue > prev.nrmValue) {
          _thumbStates[i] = _thumbStates[i].copyWith(
            nrmValue: prev.nrmValue,
            value: prev.value,
          );
        }

        prev = _thumbStates[i];
      }
    }
  }

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

    int getOverlappingThumb(Offset pos) {
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
        final prevNrmValue = _thumbStates[thumbIndex].nrmValue;
        _thumbStates[thumbIndex] = _thumbStates[thumbIndex].copyWith(
          nrmValue: nrmValue,
          value: value,
        );

        _resolveCollisions(nrmValue > prevNrmValue);
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
      onPointerDown: (event) {
        int idx = getOverlappingThumb(event.localPosition);
        if (idx != null) {
          widget.thumbs[idx].onStart?.call();
          updatePress(idx, event.localPosition);
          setState(() => _selectedThumb = idx);
        }
      },
      onPointerMove: (event) {
        if (_isThumbSelected) {
          updatePress(_selectedThumb, event.localPosition);
        }
      },
      onPointerUp: (event) {
        if (_isThumbSelected) {
          widget.thumbs[_selectedThumb].onEnd?.call();
          setState(() => _selectedThumb = null);
        }
      },
      onPointerCancel: (event) {
        if (_isThumbSelected) {
          widget.thumbs[_selectedThumb].onEnd?.call();
          setState(() => _selectedThumb = null);
        }
      },
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
