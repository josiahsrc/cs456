import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'slider.dart';

enum DemoType {
  elipse,
  wave,
  spiral,
}

class Demo extends StatefulWidget {
  final String title;
  final DemoType type;

  const Demo({
    Key key,
    @required this.title,
    @required this.type,
  }) : super(key: key);

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  static final int _minThumbs = 1;
  static final int _maxThumbs = 10;

  double _nThumbs01;
  double _valueA;
  double _valueB;
  List<double> _thumbValues;
  int _activeThumbIdx;
  bool _mirror;
  double _elipseFill = .25;
  double _elipseOffset = 0;
  double _spiralFreq = 1;
  double _spiralOffset = 0;
  double _waveFreq = 1;
  double _waveOffset = 0;
  double _thumbSize = 15;
  double _lineSize = 6;
  double _aspect = 1;

  int get _thumbCount =>
      math.max(ui.lerpDouble(_minThumbs, _maxThumbs, _nThumbs01).round(), 1);

  @override
  void initState() {
    _nThumbs01 = 0;
    _valueA = -10;
    _valueB = 10;
    _thumbValues = [_valueA];
    _activeThumbIdx = null;
    _mirror = false;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Demo oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Widget labeled(String label, Widget child) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Spacer(),
          child,
        ],
      );
    }

    final configChildren = <Widget>[];

    final thumbs = [
      for (int i = 0; i < _thumbCount; ++i)
        CurvedSliderThumb(
          initialValue: _thumbValues[i],
          onStart: () => setState(() => _activeThumbIdx = i),
          onEnd: () => setState(() => _activeThumbIdx = null),
          onChanged: (value) => setState(() => _thumbValues[i] = value),
        ),
    ];

    configChildren.add(labeled(
      'Min/Max Values',
      RangeSlider(
        min: -40,
        max: 40,
        values: RangeValues(_valueA, _valueB),
        onChanged: (value) => setState(() {
          _valueA = value.start;
          _valueB = value.end;
        }),
      ),
    ));

    configChildren.add(labeled(
      'Mirror',
      Switch(
        value: _mirror,
        onChanged: (value) => setState(() => _mirror = value),
      ),
    ));

    configChildren.add(labeled(
      'Aspect Ratio',
      Slider(
        min: 1,
        max: 2.25,
        value: _aspect,
        onChanged: (value) => setState(() => _aspect = value),
      ),
    ));

    configChildren.add(labeled(
      'Thumb Size',
      Slider(
        min: 10.0,
        max: 50.0,
        value: _thumbSize,
        onChanged: (value) => setState(() => _thumbSize = value),
      ),
    ));

    configChildren.add(labeled(
      'Line Size',
      Slider(
        min: 1.0,
        max: 20.0,
        value: _lineSize,
        onChanged: (value) => setState(() => _lineSize = value),
      ),
    ));

    configChildren.add(labeled(
      'Thumb count',
      Slider(
        min: 0.0,
        max: 1.0,
        value: _nThumbs01,
        onChanged: (value) => setState(() {
          final prev = _thumbCount;
          _nThumbs01 = value;
          if (prev != _thumbCount) {
            _thumbValues.clear();
            for (int i = 0; i < _thumbCount; ++i) {
              final t = i.toDouble() / math.max(_thumbCount - 1, 1);
              _thumbValues.add(ui.lerpDouble(_valueA, _valueB, t));
            }
          }
        }),
      ),
    ));

    final decor = CurvedSliderDecoration(
      thumbRadius: _thumbSize,
      lineThickness: _lineSize,
    );

    Widget slider;
    switch (widget.type) {
      case DemoType.elipse:
        configChildren.add(labeled(
          'Elipse Fill',
          Slider(
            min: 0.0,
            max: 1.0,
            value: _elipseFill,
            onChanged: (value) => setState(() => _elipseFill = value),
          ),
        ));

        configChildren.add(labeled(
          'Elipse Offset',
          Slider(
            min: 0.0,
            max: 1.0,
            value: _elipseOffset,
            onChanged: (value) => setState(() => _elipseOffset = value),
          ),
        ));

        slider = CurvedSlider.elipse(
          valueA: _valueA,
          valueB: _valueB,
          thumbs: thumbs,
          mirror: _mirror,
          fill: _elipseFill,
          offset: _elipseOffset,
          decoration: decor,
        );
        break;
      case DemoType.wave:
        configChildren.add(labeled(
          'Wave Frequency',
          Slider(
            min: 0.1,
            max: 5.0,
            value: _waveFreq,
            onChanged: (value) => setState(() => _waveFreq = value),
          ),
        ));

        configChildren.add(labeled(
          'Wave Offset',
          Slider(
            min: 0.0,
            max: 1.0,
            value: _waveOffset,
            onChanged: (value) => setState(() => _waveOffset = value),
          ),
        ));

        slider = CurvedSlider.waves(
          valueA: _valueA,
          valueB: _valueB,
          thumbs: thumbs,
          mirror: _mirror,
          offset: _waveOffset,
          frequency: _waveFreq,
          decoration: decor,
        );
        break;
      case DemoType.spiral:
        configChildren.add(labeled(
          'Spiral Frequency',
          Slider(
            min: 0.1,
            max: 3.0,
            value: _spiralFreq,
            onChanged: (value) => setState(() => _spiralFreq = value),
          ),
        ));

        configChildren.add(labeled(
          'Siral Offset',
          Slider(
            min: 0.0,
            max: 1.0,
            value: _spiralOffset,
            onChanged: (value) => setState(() => _spiralOffset = value),
          ),
        ));

        slider = CurvedSlider.spiral(
          valueA: _valueA,
          valueB: _valueB,
          thumbs: thumbs,
          mirror: _mirror,
          offset: _spiralOffset,
          frequency: _spiralFreq,
          decoration: decor,
        );
        break;
      default:
        throw UnimplementedError();
    }

    configChildren.add(labeled(
      'Vals',
      SizedBox(
        width: 250,
        child: Wrap(
          children: [
            for (int i = 0; i < _thumbValues.length; ++i)
              Text(
                _thumbValues[i].toStringAsFixed(1),
                style: TextStyle(
                  color: _activeThumbIdx == i ? Colors.green : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    ));

    final config = SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          children: configChildren,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        config,
        Divider(),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: AspectRatio(
              aspectRatio: _aspect,
              child: slider,
            ),
          ),
        ),
      ]),
    );
  }
}
