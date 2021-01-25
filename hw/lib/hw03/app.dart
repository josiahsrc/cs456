import 'package:flutter/material.dart';

import 'slider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textbox = Text(
      'Hello',
      textAlign: TextAlign.center,
    );

    final slider = ThumbSlider(
      onStart: () {
        print('Started slider');
      },
      onEnd: () {
        print('Ended slider');
      },
      onChanged: (value) {
        print('Changed slider: $value');
      },
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
