import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

typedef CurvedSliderParametricCallback = double Function(double t);

const _segments = 600;

double _normalize(double val, double min, double max) {
  final absmin = min.abs();

  double res;
  if (min > 0) {
    res = (val - absmin) / (max - absmin);
  } else {
    res = (val + absmin) / (max + absmin);
  }

  return res.clamp(0.0, 1.0);
}

double _denormalize(double nrm, double min, double max) {
  return ui.lerpDouble(nrm, min, max).clamp(min, max);
}

@immutable
class CurvedSliderDecoration {
  const CurvedSliderDecoration({
    this.lineThickness = 6,
    this.lineColor = Colors.grey,
    this.thumbRadius = 16,
    this.thumbColorA = Colors.blue,
    this.thumbColorB = Colors.red,
  })  : assert(lineThickness != null && lineThickness >= 0),
        assert(lineColor != null),
        assert(thumbRadius != null && thumbRadius >= 0),
        assert(thumbColorA != null),
        assert(thumbColorB != null),
        super();

  final double lineThickness;
  final Color lineColor;
  final double thumbRadius;
  final Color thumbColorA;
  final Color thumbColorB;
}

@immutable
class CurvedSliderThumb {
  const CurvedSliderThumb({
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

class CurvedSlider extends StatefulWidget {
  const CurvedSlider({
    Key key,
    this.decoration = const CurvedSliderDecoration(),
    @required this.computeX,
    @required this.computeY,
    @required this.join,
    this.valueA = 0.0,
    this.valueB = 1.0,
    @required this.thumbs,
    this.mirror = false,
  })  : assert(decoration != null),
        assert(computeX != null),
        assert(computeY != null),
        assert(join != null),
        assert(valueA != null),
        assert(valueB != null),
        assert(valueA < valueB),
        assert(thumbs != null),
        assert(mirror != null),
        super(key: key);

  factory CurvedSlider.elipse({
    double fill = 1,
    double offset = 0,
    double valueA = 0.0,
    double valueB = 1.0,
    @required List<CurvedSliderThumb> thumbs,
    CurvedSliderDecoration decoration = const CurvedSliderDecoration(),
    bool mirror = false,
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
      valueA: valueA,
      valueB: valueB,
      thumbs: thumbs,
      decoration: decoration,
      mirror: mirror,
    );
  }

  factory CurvedSlider.waves({
    double valueA = 0.0,
    double valueB = 1.0,
    double offset = 0.0,
    double frequency = 1.0,
    @required List<CurvedSliderThumb> thumbs,
    CurvedSliderDecoration decoration = const CurvedSliderDecoration(),
    bool mirror = false,
  }) {
    assert(offset != null);
    assert(frequency != null);

    return CurvedSlider(
      computeX: (t) => t,
      computeY: (t) => math.sin(t * frequency + offset),
      join: false,
      valueA: valueA,
      valueB: valueB,
      thumbs: thumbs,
      decoration: decoration,
      mirror: mirror,
    );
  }

  final CurvedSliderDecoration decoration;
  final CurvedSliderParametricCallback computeX;
  final CurvedSliderParametricCallback computeY;
  final bool join;
  final double valueA;
  final double valueB;
  final bool mirror;
  final List<CurvedSliderThumb> thumbs;

  @override
  _CurvedSliderState createState() => _CurvedSliderState();
}

class _CurvedSliderState extends State<CurvedSlider> {
  final List<Offset> lineNrmPoints = [];
  final List<Offset> thumbNrmPoints = [];
  final List<double> thumbNrmValues = [];
  int selectedThumbIdx;

  bool get isThumbSelected => selectedThumbIdx != null;

  @override
  void initState() {
    syncNrmLinePoints();
    syncNrmThumbPoints();
    resolveCollisions();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CurvedSlider oldWidget) {
    syncNrmLinePoints();
    syncNrmThumbPoints();
    resolveCollisions();
    super.didUpdateWidget(oldWidget);
  }

  void syncNrmLinePoints() {
    double getX(double t) {
      return widget.computeX.call(t);
    }

    double getY(double t) {
      return widget.computeY.call(t);
    }

    double getT(int i) {
      return ((i).toDouble() / _segments) * 2 * math.pi;
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

    // Cache normalized line points.
    lineNrmPoints.clear();
    for (int i = 0; i < _segments; ++i) {
      final t = getT(i);
      lineNrmPoints.add(Offset(
        _normalize(getX(t), minX, maxX),
        _normalize(getY(t), minY, maxY),
      ));
    }
  }

  void syncNrmThumbPoints() {
    final nthumbs = widget.thumbs.length;
    final npoints = lineNrmPoints.length;

    // Cache normalized thumb points.
    thumbNrmValues.clear();
    thumbNrmPoints.clear();
    for (int i = 0; i < nthumbs; ++i) {
      final thumb = widget.thumbs[i];

      final nrm = rangeToNrm(thumb.initialValue);
      final idx = (nrm * (npoints - 1)).round();
      thumbNrmPoints.add(lineNrmPoints[idx]);
      thumbNrmValues.add(nrm);
    }
  }

  double rangeToNrm(double range) {
    return _normalize(range, widget.valueA, widget.valueB);
  }

  double nrmToRange(double nrm) {
    return _denormalize(nrm, widget.valueA, widget.valueB);
  }

  int closestNrmLinePoint(Offset nrmPoint) {
    int closestNrm;
    var closestDist = double.infinity;

    for (int i = 0; i < lineNrmPoints.length; ++i) {
      final offset = lineNrmPoints[i];
      final dist = (nrmPoint - offset).distanceSquared;

      if (dist < closestDist) {
        closestDist = dist;
        closestNrm = i;
      }
    }

    return closestNrm;
  }

  int closestNrmThumbPoint(Offset nrmPoint) {
    int closestNrm;
    var closestDist = double.infinity;

    for (int i = 0; i < thumbNrmPoints.length; ++i) {
      final offset = thumbNrmPoints[i];
      final dist = (nrmPoint - offset).distanceSquared;

      if (dist < closestDist) {
        closestDist = dist;
        closestNrm = i;
      }
    }

    return closestNrm;
  }

  void resolveCollisions([bool forward = true]) {
    assert(forward != null);

    final nthumbs = widget.thumbs.length;
    if (nthumbs == 0) {
      return;
    }

    double prevVal;
    Offset prevPos;
    if (forward) {
      prevVal = thumbNrmValues[0];
      prevPos = thumbNrmPoints[0];
      for (int i = 1; i < nthumbs; ++i) {
        if (thumbNrmValues[i] < prevVal) {
          thumbNrmValues[i] = prevVal;
          thumbNrmPoints[i] = prevPos;
          widget.thumbs[i].onChanged?.call(nrmToRange(prevVal));
        }

        prevVal = thumbNrmValues[i];
        prevPos = thumbNrmPoints[i];
      }
    } else {
      prevVal = thumbNrmValues[nthumbs - 1];
      prevPos = thumbNrmPoints[nthumbs - 1];
      for (int i = nthumbs - 2; i >= 0; --i) {
        if (thumbNrmValues[i] > prevVal) {
          thumbNrmValues[i] = prevVal;
          thumbNrmPoints[i] = prevPos;
          widget.thumbs[i].onChanged?.call(nrmToRange(prevVal));
        }

        prevVal = thumbNrmValues[i];
        prevPos = thumbNrmPoints[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: layout);
  }

  Widget layout(BuildContext context, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);

    Offset normalizePoint(Offset loc) {
      return Offset(
        loc.dx / size.width,
        loc.dy / size.height,
      );
    }

    Offset denormalizePoint(Offset loc) {
      return Offset(
        loc.dx * size.width,
        loc.dy * size.height,
      );
    }

    void updatePress(int thumbIdx, Offset localPos) {
      setState(() {
        final nrmPoint = normalizePoint(localPos);
        final lineIdx = closestNrmLinePoint(nrmPoint);
        final lineNrm = lineNrmPoints[lineIdx];

        final prevNrm = thumbNrmValues[thumbIdx];
        final currNrm = lineIdx.toDouble() / (lineNrmPoints.length - 1);

        thumbNrmPoints[thumbIdx] = lineNrm;
        thumbNrmValues[thumbIdx] = currNrm;

        resolveCollisions(currNrm > prevNrm);
      });

      final value = nrmToRange(thumbNrmValues[thumbIdx]);
      widget.thumbs[thumbIdx].onChanged?.call(value);
    }

    final painter = CustomPaint(
      painter: _Painter(
        lineNrmPoints: lineNrmPoints,
        thumbNrmPoints: thumbNrmPoints,
        thumbNrmValues: thumbNrmValues,
        join: widget.join,
        decoration: widget.decoration,
      ),
    );

    final gestures = Listener(
      onPointerDown: (event) {
        final nrm = normalizePoint(event.localPosition);
        final idx = closestNrmThumbPoint(nrm);

        if (idx == null) {
          return;
        }

        if (isThumbSelected) {
          return;
        }

        final pos = denormalizePoint(thumbNrmPoints[idx]);
        if ((pos - event.localPosition).distance >
            widget.decoration.thumbRadius) {
          return;
        }

        widget.thumbs[idx].onStart?.call();
        updatePress(idx, event.localPosition);
        setState(() => selectedThumbIdx = idx);
      },
      onPointerMove: (event) {
        if (isThumbSelected) {
          updatePress(selectedThumbIdx, event.localPosition);
        }
      },
      onPointerUp: (event) {
        if (isThumbSelected) {
          widget.thumbs[selectedThumbIdx].onEnd?.call();
          setState(() => selectedThumbIdx = null);
        }
      },
      onPointerCancel: (event) {
        if (isThumbSelected) {
          widget.thumbs[selectedThumbIdx].onEnd?.call();
          setState(() => selectedThumbIdx = null);
        }
      },
      child: painter,
    );

    if (widget.mirror) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: gestures,
      );
    }

    return gestures;
  }
}

/// Draws the slider.
class _Painter extends CustomPainter {
  const _Painter({
    @required this.lineNrmPoints,
    @required this.thumbNrmPoints,
    @required this.thumbNrmValues,
    @required this.join,
    @required this.decoration,
  })  : assert(lineNrmPoints != null),
        assert(thumbNrmPoints != null),
        assert(thumbNrmValues != null),
        assert(join != null),
        assert(decoration != null),
        super();

  final List<Offset> lineNrmPoints;
  final List<Offset> thumbNrmPoints;
  final List<double> thumbNrmValues;
  final bool join;
  final CurvedSliderDecoration decoration;

  @override
  void paint(Canvas canvas, Size size) {
    assert(lineNrmPoints.length > 0);

    double getCanvasX(double nrmX) {
      return nrmX * size.width;
    }

    double getCanvasY(double nrmY) {
      return nrmY * size.height;
    }

    // Draw line.
    {
      final path = Path()
        ..moveTo(
          getCanvasX(lineNrmPoints.first.dx),
          getCanvasY(lineNrmPoints.first.dy),
        );

      for (final nrmPoint in lineNrmPoints) {
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
      final nthumbs = thumbNrmPoints.length;
      for (int i = 0; i < nthumbs; ++i) {
        final point = thumbNrmPoints[i];
        final value = thumbNrmValues[i];

        final x = getCanvasX(point.dx);
        final y = getCanvasY(point.dy);

        final paint = Paint()
          ..color = Color.lerp(
            decoration.thumbColorA,
            decoration.thumbColorB,
            value,
          );

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
