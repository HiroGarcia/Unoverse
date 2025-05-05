import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/modal_controller.dart';

showFormModal({required BuildContext context, required String uid}) {
  TextEditingController nameController = TextEditingController();
  TextEditingController primeiroController = TextEditingController(text: '3');
  TextEditingController segundoController = TextEditingController(text: '2');
  TextEditingController terceiroController = TextEditingController(text: '1');
  ModalController modalController = ModalController();

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
          child: ListView(
            children: [
              Text(
                'Adicionar Group',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(label: Text("Nome do Group")),
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
                        Map<String, String> role = {uid: 'master'};
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
