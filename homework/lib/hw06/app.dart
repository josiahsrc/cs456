import 'package:flutter/material.dart';

import 'unusable_widget.dart';

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

    final video = SliverList(
      delegate: SliverChildListDelegate([
        UnusableVideoPlayer(),
      ]),
    );

    final content = CustomScrollView(
      physics: NeverScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: video,
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Unusable Widget Demo'),
      ),
      body: content,
    );
  }
}
