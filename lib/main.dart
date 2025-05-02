import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unoverse/firebase_options.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(),
    );
  }
}
