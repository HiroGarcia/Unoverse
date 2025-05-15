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
        ChangeNotifierProvider<GroupProvider>(
          create: (context) {
            // Use listen: false para não criar dependência de reconstrução aqui
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            return GroupProvider(
              groupService: GroupService(),
              userProvider: userProvider,
            );
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
    // 1. Observa o estado de autenticação do Firebase Auth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Nomeei o snapshot para clareza

        if (authSnapshot.connectionState == ConnectionState.waiting) {
          // Mostra um indicador inicial enquanto o Firebase verifica o estado de autenticação pela primeira vez
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Observa o estado do UserProvider (para saber se os dados do usuário Entity foram carregados)
        // Use 'watch' para que RoteadorTelas reconstrua quando o UserProvider chamar notifyListeners()
        final userProvider = context.watch<UserProvider>();
        final userEntity =
            userProvider
                .user; // Pega o objeto UserEntity carregado pelo Provider

        if (authSnapshot.hasData && authSnapshot.data != null) {
          // --- Usuário está AUTENTICADO pelo Firebase Auth (Passo 1 OK) ---
          final firebaseUser = authSnapshot.data!; // O User do Firebase Auth

          if (userEntity == null) {
            // --- Usuário AUTENTICADO, mas dados do UserProvider AINDA NÃO CARREGADOS (ou não encontrados) ---
            // Mostra um indicador específico enquanto espera os dados do usuário Entity.
            print(
              "RoteadorTelas: Auth OK, mas UserProvider user is null. Mostrando loading de dados do usuário.",
            );
            return const Scaffold(
              // Use Scaffold para um fundo consistente
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // --- Usuário AUTENTICADO E dados do UserProvider CARREGADOS (Passo 2 OK) ---
            // O ProxyProvider já deve ter sido acionado pelo notifyListeners() do UserProvider
            // quando userEntity foi setado. Agora é seguro mostrar a HomePage.
            print(
              "RoteadorTelas: Auth OK, UserProvider user carregado. Mostrando HomePage.",
            );
            // Passe o Firebase User se a HomePage precisar dele (ela usará o UserProvider para o Entity)
            return HomePage(userAuth: firebaseUser);
          }
        } else {
          // --- Usuário NÃO está AUTENTICADO pelo Firebase Auth ---
          // O UserProvider já deve ter setado _user para null e chamado notifyListeners().
          print("RoteadorTelas: Usuário não logado. Mostrando AuthPage.");
          return AuthPage(); // Mostra a tela de login/cadastro
        }
      },
    );
  }
}
