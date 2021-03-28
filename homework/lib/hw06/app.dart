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
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final video = SliverList(
      delegate: SliverChildListDelegate([
        UnusableVideoPlayer(),
      ]),
    );

    final info = SliverList(
      delegate: SliverChildListDelegate([
        Text(
          'A really useful video player. '
          'Press play to play the vid.',
          style: theme.textTheme.headline5,
        ),
      ]),
    );

    final content = CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
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
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: info,
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
