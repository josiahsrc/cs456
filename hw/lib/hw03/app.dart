import 'package:flutter/material.dart';

import 'slider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(42.0),
            child: ThumbSlider(),
          ),
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
