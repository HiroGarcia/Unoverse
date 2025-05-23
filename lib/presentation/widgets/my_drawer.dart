import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth user = FirebaseAuth.instance;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: null,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
              ),
            ),
            accountName: Text(
              user.currentUser!.displayName.toString(),
              style: TextStyle(color: Colors.white),
            ),
            accountEmail: Text(
              user.currentUser!.email.toString(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Mudar foto de perfil"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Deletar Conta"),
            onTap: () {
              // showSenhaConfirmacaoDialog(context: context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sair"),
            onTap: () async {
              try {
                print("Iniciando processo de logout.");
                await user.signOut();
                print("FirebaseAuth signOut() concluído.");
              } catch (e) {
                print("Erro durante o processo de logout: $e");
              }
            },
          ),
        ],
      ),
    );
  }
}
