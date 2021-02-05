import 'package:flutter/material.dart';

import 'slider.dart' as slider;

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  static const int thumbCount = 1;
  
  List<bool> _slidersActive;
  List<double> _sliderValues;

  @override
  void initState() {
    _slidersActive = [for (int i = 0; i < thumbCount; ++i) false];
    _sliderValues = [for (int i = 0; i < thumbCount; ++i) 0.0];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void activateThumb(int index) {
      setState(() => _slidersActive[index] = true);
    }

    void deactivateThumb(int index) {
      setState(() => _slidersActive[index] = false);
    }

    void updateThumb(int index, double value) {
      setState(() => _sliderValues[index] = value);
    }

    final thumbs = [
      for (int i = 0; i < thumbCount; ++i)
        slider.Thumb(
          initialValue: 0,
          onStart: () => activateThumb(i),
          onEnd: () => deactivateThumb(i),
          onChanged: (value) => updateThumb(i, value),
        ),
    ];

    final textBoxes = [
      for (int i = 0; i < thumbCount; ++i)
        Text(
          'Slider Value = ${_sliderValues[i].toStringAsFixed(4)}',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: _slidersActive[i] ? Colors.green : Colors.black,
          ),
        )
    ];

    final thumbSlider = slider.ThumbSlider(
      valueA: 0,
      valueB: 20,
      thumbs: thumbs,
    );

    final page = Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          thumbSlider,
          ...textBoxes,
        ],
      ),
    );

    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: page,
    );
  }
}
