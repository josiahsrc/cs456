import 'package:flutter/material.dart';

import 'slider.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _sliderActive = false;
  int _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    final textbox = Text(
      'Slider Value = $_sliderValue',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _sliderActive ? Colors.green : Colors.black,
      ),
    );

    final slider = ThumbSlider(
      onStart: () {
        setState(() => _sliderActive = true);
      },
      onEnd: () {
        setState(() => _sliderActive = false);
      },
      onChanged: (value) {
        setState(() => _sliderValue = value.toInt());
      },
      initialValue: _sliderValue.toDouble(),
      valueA: 0,
      valueB: 100,
    );

    final page = Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          textbox,
          slider,
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
