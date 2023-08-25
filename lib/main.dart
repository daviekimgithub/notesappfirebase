import 'package:flutter/material.dart';
import 'package:notes/views/home-page.dart';
import 'package:notes/views/login-view.dart';
import 'package:notes/views/notes_view.dart';
import 'package:notes/views/register-view.dart';
import 'package:notes/views/verify-email-view.dart';
import 'constants/routes.dart' as routes;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        routes.loginRoutes: (context) => const LoginView(),
        routes.registerRoutes: (context) => const RegisterView(),
        routes.notesRoutes: (context) => const NotesView(),
        routes.verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    );
  }
}
