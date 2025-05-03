import 'package:flutter/material.dart';

showSnackBar({
  required BuildContext context,
  required String mensagem,
  bool isError = true,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(mensagem),
    backgroundColor: isError ? Colors.red : Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
