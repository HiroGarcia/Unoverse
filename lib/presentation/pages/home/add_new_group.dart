import 'package:flutter/material.dart';

import '../../../controllers/invite_controller.dart';

import '../../widgets/my_textfield.dart';

Future<void> addNewGroup({
  required BuildContext context,
}) async {
  String? inviteValidator(String? value) {
    if (value == null || value.length < 8) {
      return "Convite Inválido";
    }
    return null;
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final TextEditingController conviteIdController = TextEditingController();

      bool isCreated = false;
      String successText = 'Adicionar';
      bool inviteValid = true;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Adicionar Grupo'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextfield(
                    controller: conviteIdController,
                    labelText: "ID do Convite",
                    obscureText: false,
                    maxLength: 8,
                    validator: (value) {
                      return inviteValidator(value);
                    },
                  ),
                  if (!inviteValid) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Convite inválido ou já utilizado",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (isCreated) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Grupo adicionado com sucesso",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            actions:
                isCreated
                    ? [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Concluido!",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                    : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed:
                            (isCreated)
                                ? null
                                : () async {
                                  final inviteId = conviteIdController.text;
                                  final validChars = RegExp(r'^[a-zA-Z0-9]+$');
                                  if (inviteId.length != 8 || !validChars.hasMatch(inviteId)) {
                                    setState(() {
                                      inviteValid = false;
                                    });
                                    return;
                                  }
                                  try {
                                    final result = await InviteController().readInvite(inviteId: inviteId);
                                    if (result == true) {
                                      setState(() {
                                        isCreated = true;
                                        successText = 'Adicionado com sucesso!';
                                        inviteValid = true;
                                      });
                                    } else {
                                      setState(() {
                                        inviteValid = false;
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      inviteValid = false;
                                    });
                                  }
                                },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) => isCreated ? Colors.green : Colors.white,
                          ),
                        ),
                        child: Text(
                          successText,
                          style: TextStyle(
                            color: isCreated ? Colors.green : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
          );
        },
      );
    },
  );
}
