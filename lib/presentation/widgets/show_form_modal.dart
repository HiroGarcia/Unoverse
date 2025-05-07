import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entity/enum_type.dart';
import '../controllers/modal_controller.dart';

showFormModal({
  required BuildContext context,
  String? uid,
  String? groupId,
  required EnumType type,
}) {
  TextEditingController nameController = TextEditingController();

  TextEditingController primeiroController = TextEditingController(text: '3');
  TextEditingController segundoController = TextEditingController(text: '2');
  TextEditingController terceiroController = TextEditingController(text: '1');

  TextEditingController emailController = TextEditingController();
  TextEditingController initialScoreController = TextEditingController(
    text: '0',
  );

  ModalController modalController = ModalController();
  String titleType = '';

  if (type == EnumType.group) {
    titleType = 'Grupo';
  } else if (type == EnumType.player) {
    titleType = 'Jogador';
  } else if (type == EnumType.member) {
    titleType = 'Membro';
  }

  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar $titleType',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(label: Text("Nome do $titleType")),
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
              const SizedBox(height: 16),
              if (type == EnumType.group) ...[
                Text('Score'),
                TextFormField(
                  controller: primeiroController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Pontuação 1º lugar'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pontuação é obrigatória';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: segundoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Pontuação 2º lugar'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pontuação é obrigatória';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: terceiroController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Pontuação 3º lugar'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pontuação é obrigatória';
                    }
                    return null;
                  },
                ),
              ] else if (type == EnumType.player) ...[
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email do Jogador (Opcional)',
                  ),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: initialScoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Pontuação Inicial'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pontuação inicial é obrigatória';
                    }
                    // Check if it's a valid integer
                    if (int.tryParse(value) == null) {
                      return 'Entre com um número válido';
                    }
                    return null;
                  },
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
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
                          );
                          Navigator.pop(context);
                        } else if (type == EnumType.player) {
                          modalController.addPlayer(
                            name: nameController.text,
                            userEmail: emailController.text,
                            scoreInitial: int.parse(
                              initialScoreController.text,
                            ),
                            groupId: groupId!,
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
