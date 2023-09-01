import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String resetPasswordUrl =
    'https://your-app-domain.com/reset-password?code=YOUR_CODE';

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
              launch(resetPasswordUrl);
            },
            child: const Text('Reset Password'),
          ),
        ),
      ),
    );
  }
}
