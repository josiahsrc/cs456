import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Simple App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Page(),
    );
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CS456 Simple App'),
      ),
      body: Center(
        child: SizedBox.fromSize(
          size: Size.square(MediaQuery.of(context).size.width - 128),
          child: Image.network(
            'https://www.benjerry.co.nz/files/live/sites/systemsite/files/flavors/wmiab/wmiab-cccd-spoon-hero.png',
          ),
        ),
      ),
    );
  }
}
