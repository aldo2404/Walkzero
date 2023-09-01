import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:walkzero/constwidget/thememode.dart';
//import 'package:walkzero/screens/loginflow/loginpage.dart';
import 'package:walkzero/screens/passwordreset/resetpassword.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        builder: (context, snapshot) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MaterialApp(
            themeMode: themeProvider.themeMode,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme,
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            home: const NativeSplashscreen(),
          );
        });
  }
}

class NativeSplashscreen extends StatefulWidget {
  const NativeSplashscreen({
    super.key,
  });

  @override
  State<NativeSplashscreen> createState() => _NativeSplashscreenState();
}

class _NativeSplashscreenState extends State<NativeSplashscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        FlutterNativeSplash.remove();
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const PasswordResetPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
