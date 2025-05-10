import 'package:flutter/material.dart';
import 'package:unoverse/presentation/widgets/show_snackbar.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
                  'Let\'s create an account for you',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 10),
                  child: MyTextfield(
                    controller: nameController,
                    labelText: 'Name',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return "Name must have at least 3 characters.";
                      }
                      return null;
                    },
                  ),
                ),
                MyTextfield(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: MyTextfield(
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
                ),

                MyTextfield(
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Passwords must be the same";
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 26, bottom: 16.0),
                  child: MyButton(
                    text: 'SIGN UP',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        authController.registerUser(
                          email: emailController.text,
                          password: passwordController.text,
                          name: nameController.text,
                          context: context,
                        );
                      } else {
                        showSnackBar(
                          context: context,
                          isError: true,
                          mensagem: 'Complete the fields correctly',
                        );
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        'Login now',
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
