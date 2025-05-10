import 'package:flutter/material.dart';
import 'package:unoverse/presentation/widgets/my_button.dart';
import 'package:unoverse/presentation/widgets/my_textfield.dart';

import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authController = AuthController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'U N O V E R S E',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'L E T \'S   G O   P L A Y I N G',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: MyTextfield(
                    controller: emailController,
                    labelText: 'Email',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value == "") {
                        return "Email invalid";
                      }
                      if (!value.contains("@") ||
                          !value.contains(".") ||
                          value.length < 4) {
                        return "Email invalid";
                      }
                      return null;
                    },
                  ),
                ),
                MyTextfield(
                  controller: passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must have at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: MyButton(
                    text: 'Login',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        authController.loginUser(
                          email: emailController.text,
                          password: passwordController.text,
                          context: context,
                        );
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an acoount? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
