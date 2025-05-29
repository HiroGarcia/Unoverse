import 'package:flutter/material.dart';
import 'package:unoverse/domain/enums/enum_role.dart';
import 'package:uuid/uuid.dart';

import '../../../controllers/invite_controller.dart';
import '../../../domain/entity/group_entity.dart';

Future<void> addNewInvite({
  required BuildContext context,
  required Group group,
  required String userUid,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool isAdminSelected = false;
      bool isUserSelected = false;
      bool isCreated = false;
      String successText = 'Criar';

      final String? currentRole = group.role[userUid];
      final bool isMaster = currentRole == 'master';
      final bool isAdmin = currentRole == 'admin';
      final String inviteId = Uuid().v4().substring(0, 8);

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Criar convite'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Convite ID: $inviteId",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (isCreated) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Convite criado com sucesso, salve o código antes de sair dessa tela e compartilhe com o novo membro",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    if (isMaster) ...[
                      CheckboxListTile(
                        title: const Text('Admin'),
                        value: isAdminSelected,
                        selected: isUserSelected,
                        onChanged: (value) {
                          setState(() {
                            isAdminSelected = true;
                            isUserSelected = false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('User'),
                        value: isUserSelected,
                        selected: isAdminSelected,
                        onChanged: (value) {
                          setState(() {
                            isUserSelected = true;
                            isAdminSelected = false;
                          });
                        },
                      ),
                    ] else if (isAdmin) ...[
                      CheckboxListTile(
                        title: const Text('User'),
                        value: true,
                        onChanged: null,
                      ),
                    ],
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
                          "já salvei, sair",
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
                      ElevatedButton(
                        onPressed:
                            (isCreated || (isMaster && (!isAdminSelected && !isUserSelected)))
                                ? null
                                : () async {
                                  // Determina o papel do convite
                                  Role roleToSend;
                                  if (isMaster) {
                                    roleToSend = isAdminSelected ? Role.admin : Role.user;
                                  } else {
                                    roleToSend = Role.user;
                                  }

                                  try {
                                    InviteController().createdInvite(
                                      groupId: group.groupId,
                                      role: roleToSend,
                                      inviteId: inviteId,
                                    );
                                    setState(() {
                                      isCreated = true;
                                      successText = 'Criado com sucesso';
                                    });
                                  } catch (e) {
                                    // Trate o erro se necessário
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
