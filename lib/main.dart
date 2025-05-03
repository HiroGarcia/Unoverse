import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unoverse/firebase_options.dart';

import 'presentation/pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const UnoverseApp());
}

class UnoverseApp extends StatelessWidget {
  const UnoverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unoverse Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: 'loginScreen',
      routes: {'loginScreen': (context) => LoginPage()},
    );
  }
}
