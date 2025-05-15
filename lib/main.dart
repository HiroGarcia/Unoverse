import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/data/services/group_provider.dart';
import 'package:unoverse/data/services/group_service.dart';
import 'package:unoverse/data/services/player_provider.dart';
import 'package:unoverse/data/services/user_provider.dart';
import 'package:unoverse/firebase_options.dart';
import 'package:unoverse/presentation/controllers/card_flip_controller.dart';
import 'package:unoverse/presentation/pages/auth/auth_page.dart';
import 'package:unoverse/themes/dark_mode.dart';
import 'package:unoverse/themes/light_mode.dart';

import 'presentation/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => CardFlipController()),
        ChangeNotifierProxyProvider<UserProvider, GroupProvider>(
          create: (_) => GroupProvider(groupService: GroupService()),
          update: (_, userProvider, groupProvider) {
            print("ProxyProvider Update: Método 'update' chamado.");
            final user = userProvider.user;
            print(
              "ProxyProvider Update: userProvider.user é null: ${user == null}",
            );
            final groupIds = user?.groupsId ?? [];
            groupProvider!.updateUserGroupIds(groupIds);
            return groupProvider;
          },
        ),
      ],
      child: UnoverseApp(),
    ),
  );
}

class UnoverseApp extends StatelessWidget {
  const UnoverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unoverse Demo',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: const RoteadorTelas(),
    );
  }
}

class RoteadorTelas extends StatelessWidget {
  const RoteadorTelas({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userProvider = context.watch<UserProvider>();
        final userEntity = userProvider.user;

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final firebaseUser = authSnapshot.data!;

          Provider.of<UserProvider>(
            context,
            listen: false,
          ).listenUser(firebaseUser.uid);

          if (userEntity == null) {
            print(
              "RoteadorTelas: Auth OK, mas UserProvider user is null. Mostrando loading de usuário.",
            );
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            print(
              "RoteadorTelas: Auth OK, UserProvider user carregado. Mostrando HomePage.",
            );

            return HomePage(userAuth: firebaseUser);
          }
        } else {
          print("RoteadorTelas: Usuário não logado. Mostrando AuthPage.");
          return AuthPage(); // Mostra a tela de login/cadastro
        }
      },
    );
  }
}
