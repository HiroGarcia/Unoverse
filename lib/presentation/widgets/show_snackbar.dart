import 'package:flutter/material.dart';

showSnackBar({
  required BuildContext context,
  required String mensagem,
  bool isError = true,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(mensagem),
    backgroundColor:
        isError
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.inversePrimary,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
