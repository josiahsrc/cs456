import 'dart:ui';

import 'package:flutter/material.dart';

import 'demo.dart';
import 'slider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.home,
      routes: Routes.define(),
    );
  }
}

class Routes {
  const Routes._();

  static final home = '/';
  static final example = '/example';
  static final elipse = '/elipse';
  static final wave = '/wave';
  static final spiral = '/spiral';

  static Map<String, WidgetBuilder> define() => {
        home: (c) => HomePage(),
        example: (c) => ExamplePage(),
        elipse: (c) => Demo(
              title: 'Elipse Demo',
              type: DemoType.elipse,
            ),
        wave: (c) => Demo(
              title: 'Wave Demo',
              type: DemoType.wave,
            ),
        spiral: (c) => Demo(
              title: 'Spiral Demo',
              type: DemoType.spiral,
            ),
      };
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);

    final routes = {
      Routes.example: 'Example',
      Routes.elipse: 'Elipse Widget (Fancy)',
      Routes.wave: 'Wave Widget (Fancy)',
      Routes.spiral: 'Spiral Widget (Fancy)',
    };

    final tiles = SliverList(
      delegate: SliverChildListDelegate([
        for (final entry in routes.entries)
          ListTile(
            title: Text(entry.value),
            onTap: () => nav.pushNamed(entry.key),
            trailing: Icon(Icons.arrow_right),
          ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Curved Slider Demo'),
      ),
      body: CustomScrollView(
        slivers: [tiles],
      ),
    );
  }
}

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final thumbCount = 10;
    final valueA = 0.0;
    final valueB = 1.0;
    final mirror = false;
    final fill = .5;
    final offset = 0.6;
    final height = 400.0;

    final slider = CurvedSlider.elipse(
      valueA: valueA,
      valueB: valueB,
      mirror: mirror,
      fill: fill,
      offset: offset,
      thumbs: [
        for (int i = 0; i < thumbCount; ++i)
          CurvedSliderThumb(
            initialValue: lerpDouble(
              valueA,
              valueB,
              i.toDouble() / thumbCount,
            ),
            onStart: () => print('START'),
            onEnd: () => print('END'),
            onChanged: (value) => print(
              'Value changed: ${value.toStringAsFixed(2)}',
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox.fromSize(
          size: Size.fromHeight(height),
          child: slider,
        ),
      ),
    );
  }
}
