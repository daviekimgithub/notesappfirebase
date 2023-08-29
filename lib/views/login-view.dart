import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;
import '../constants/routes.dart' as routes;
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter Your Email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Enter your Password",
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredentials = await AuthService.firebase().login(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                if (user != null) {
                  if (user.isEmailVerified) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      routes.notesRoutes,
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      routes.verifyEmailRoute,
                      (route) => false,
                    );
                  }
                }
              } on UserNotFoundException {
                await showErrorDialog(
                  context,
                  "User Not Found",
                );
              } on WrongPasswordException {
                await showErrorDialog(
                  context,
                  "Wrong Password",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  "Authentication Error",
                );
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    routes.registerRoutes, (route) => false);
              },
              child: const Text('Not yet registered, Register here'))
        ],
      ),
    );
  }
}
