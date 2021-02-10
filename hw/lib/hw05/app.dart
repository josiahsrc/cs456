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
    final valueA = 10.0;
    final valueB = 110.0;
    final thumbs = <CurvedSliderThumb>[
      CurvedSliderThumb(initialValue: 10),
      CurvedSliderThumb(initialValue: 50),
      CurvedSliderThumb(initialValue: 80),
    ];

    final slider = CurvedSlider.elipse(
      valueA: valueA,
      valueB: valueB,
      fill: .25,
      offset: .75,
      thumbs: thumbs,
    );

    // final slider = CurvedSlider.waves(
    //   frequency: 1,
    //   valueA: valueA,
    //   valueB: valueB,
    //   thumbs: thumbs,
    // );

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: slider,
        ),
      ),
    );
  }
}
