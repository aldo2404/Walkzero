import 'package:flutter/material.dart';

class MyOrientationPage extends StatefulWidget {
  const MyOrientationPage({super.key});

  @override
  MyOrientationPageState createState() => MyOrientationPageState();
}

class MyOrientationPageState extends State<MyOrientationPage> {
  bool isPortrait = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orientation Example'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          isPortrait = orientation == Orientation.portrait;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Orientation: ${isPortrait ? "Portrait" : "Landscape"}',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MyOrientationPage()));
}
