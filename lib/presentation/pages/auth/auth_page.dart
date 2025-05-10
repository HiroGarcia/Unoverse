import 'package:flutter/material.dart';
import 'package:unoverse/presentation/pages/auth/login_page.dart';
import 'package:unoverse/presentation/pages/auth/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // initially, show login page
  bool showLoginPage = true;

  // toggle between pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(togglePages: togglePages);
    } else {
      return RegisterPage(togglePages: togglePages);
    }
  }
}
