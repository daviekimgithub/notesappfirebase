import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/views/nested_views/show_error_dialog.dart';
import '../constants/routes.dart' as routes;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: Text('Register'),
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
                final response = await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  routes.verifyEmailRoute,
                  (route) => false,
                );
              } on WeakPasswordException {
                await showErrorDialog(
                  context,
                  "Weak Password",
                );
              } on EmailAlreadyInUseException {
                await showErrorDialog(
                  context,
                  "Email Already In Use",
                );
              } on InvalidEmailException {
                await showErrorDialog(
                  context,
                  "Invalid Email",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  "Failed to Register",
                );
              }
            },
            child: const Text("register"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  routes.verifyEmailRoute,
                );
              },
              child: Text('Already registered, Login here'))
        ],
      ),
    );
  }
}
