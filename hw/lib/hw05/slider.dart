import 'package:flutter/material.dart';

@immutable
class CurvedSliderParametricFunc {
  const CurvedSliderParametricFunc() : super();
}

@immutable
class CurvedSliderDecoration {
  const CurvedSliderDecoration({
    this.lineThickness = 2,
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
    this.decoration = const CurvedSliderDecoration(),
  })  : assert(decoration != null),
        super(key: key);

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
    return CustomPaint(
      painter: _Painter(
        decoration: widget.decoration,
      ),
    );
  }
}

/// Draws the slider.
class _Painter extends CustomPainter {
  const _Painter({
    @required this.decoration,
  })  : assert(decoration != null),
        super();

  final CurvedSliderDecoration decoration;

  @override
  void paint(Canvas canvas, Size size) {
    final halfExtents = size / 2;

    // canvas.drawPoints(PointMode., points, paint)
    // final path = Path()..conicTo(x1, y1, x2, y2, w) <--- bezier
    // https://www.google.com/search?q=parametrict+functions&oq=parametrict+functions&aqs=chrome..69i57j0i13l8j0i10i13.4908j1j7&sourceid=chrome&ie=UTF-8
    // https://www.mathopenref.com/coordparamellipse.html
    // TODO:
    // - curved slider first
    // - then sin function

    // Draw line.
    {
      final start = Offset(0, halfExtents.height);
      final end = Offset(size.width, halfExtents.height);
      final paint = Paint()
        ..color = decoration.lineColor
        ..strokeWidth = decoration.lineThickness;

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
