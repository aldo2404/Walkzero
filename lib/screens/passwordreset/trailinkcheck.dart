import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Uri resetPasswordUrl = Uri(
  scheme: 'https',
  host: 'thinq24.walkzer.com',
  //path: 'set-password',
  //fragment: 'numbers',
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Reset Password',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              launchUrl(resetPasswordUrl);
            },
            child: const Text('Reset Password'),
          ),
        ),
      ),
    );
  }
}
