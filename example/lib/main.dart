import 'package:flutter/material.dart';
import 'package:linear_gauge/linear_gauge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Linear gauge Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LinearGuagePage(),
    );
  }
}

class LinearGuagePage extends StatefulWidget {
  @override
  _LinearGuagePageState createState() => _LinearGuagePageState();
}

class _LinearGuagePageState extends State<LinearGuagePage> {
  bool isRunning = true;
  var value = 324.0;
  var endValue = 735.0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: LinearGauge(
          barRadius: Radius.circular(10),
          width: MediaQuery.of(context).size.width - 50,
          animation: isRunning,
          gaugeHeight: 20.0,
          animationDuration: 1500,
          max: endValue,
          fraction: value,
          gaugeStatus: Text("$value"),
          widgetIndicator: Icon(Icons.arrow_drop_down, size: 40),
        ),
      ),
    );
  }
}
