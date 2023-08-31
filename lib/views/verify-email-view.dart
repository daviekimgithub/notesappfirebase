import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import '../constants/routes.dart' as routes;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text(
              "We have already send vefication email. Please open to verify your account"),
          const Text("If you haven't received the email yet click resend"),
          TextButton(
              onPressed: () async {
                AuthService.firebase().currentUser;
                await AuthService.firebase().sendEmailVerification();
              },
              child: const Text(
                'Resend Verification email',
              )),
          TextButton(
              onPressed: () {
                AuthService.firebase().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    routes.loginRoutes, (route) => false);
              },
              child: const Text('Back to Login'))
        ],
      ),
    );
  }
}
