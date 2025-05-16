import 'package:flutter/material.dart';

import '../../domain/entity/enum_type.dart';
import '../../domain/entity/group_entity.dart';
import '../../domain/entity/player_entity.dart';
import '../controllers/modal_controller.dart';
import 'my_textfield.dart';

Future<void> showFormDialog({
  required BuildContext context,
  String? uid,
  String? groupId,
  Group? group,
  Player? player,
  required EnumType type,
}) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController primeiroController = TextEditingController(text: '3');
  TextEditingController segundoController = TextEditingController(text: '2');
  TextEditingController terceiroController = TextEditingController(text: '1');
  TextEditingController emailController = TextEditingController();
  TextEditingController initialScoreController = TextEditingController(
    text: '0',
  );

  ModalController modalController = ModalController();
  String title = '';
  String nameType = '';
  if (type == EnumType.group) {
    nameType = 'Grupo';
    if (group == null) {
      title = 'Adicionar Grupo';
    } else {
      title = 'Editar Grupo';
      nameController.text = group.name;
      primeiroController.text = group.config['primeiro'].toString();
      segundoController.text = group.config['segundo'].toString();
      terceiroController.text = group.config['terceiro'].toString();
    }
  } else if (type == EnumType.player) {
    nameType = 'Jogador';
    if (player == null) {
      title = 'Adicionar Jogador';
    } else {
      title = 'Editar Jogador';
      nameController.text = player.name;
    }
  } else if (type == EnumType.member) {
    nameType = 'Membro';
    if (group == null) {
      title = 'Adicionar Membro';
    } else {
      title = 'Editar Membro';
    }
  }

  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: 'Fechar',
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: type == EnumType.group ? 300 : 200,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextfield(
                    controller: nameController,
                    labelText: 'Nome do $nameType',
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      if (value.length < 3) {
                        return 'Nome deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  if (type == EnumType.group) ...[
                    Text('Score'),
                    const SizedBox(height: 16),
                    MyTextfield(
                      controller: primeiroController,
                      labelText: 'Pontuação 1º lugar',
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pontuação é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: segundoController,
                      labelText: 'Pontuação 2º lugar',
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pontuação é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: terceiroController,
                      labelText: 'Pontuação 3º lugar',
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pontuação é obrigatória';
                        }
                        return null;
                      },
                    ),
                  ] else if (type == EnumType.player) ...[
                    MyTextfield(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email do Jogador (Opcional)',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Entre com um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: initialScoreController,
                      keyboardType: TextInputType.number,
                      labelText: 'Pontuação Inicial',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pontuação inicial é obrigatória';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Entre com um número válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (type == EnumType.group) {
                  Map<String, String> role = {uid!: 'master'};
                  Map<String, int> config = {
                    'primeiro': int.parse(primeiroController.text),
                    'segundo': int.parse(segundoController.text),
                    'terceiro': int.parse(terceiroController.text),
                  };
                  List<String> membersList = [uid];
                  modalController.addGroup(
                    name: nameController.text,
                    uid: uid,
                    members: membersList,
                    role: role,
                    config: config,
                    groupUid: (group != null) ? group.groupId : null,
                    createIn: (group != null) ? group.createIn : null,
                  );
                  Navigator.pop(context);
                } else if (type == EnumType.player) {
                  modalController.addPlayer(
                    name: nameController.text,
                    userEmail: emailController.text,
                    scoreInitial: int.parse(initialScoreController.text),
                    groupId: groupId!,
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Salvar'),
          ),
        ],
      );
    },
  );
}
