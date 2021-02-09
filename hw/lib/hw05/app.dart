import 'package:flutter/material.dart';

import 'slider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final slider = CurvedSlider();

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1 / 1.2,
          child: slider,
        ),
      ),
    );
  }
}
