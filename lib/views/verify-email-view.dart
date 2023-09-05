import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/bloc/auth_events.dart';
import '../services/auth/bloc/auth_bloc.dart';

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
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
              },
              child: const Text(
                'Resend Verification email',
              )),
          TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      AuthEventLogout(),
                    );
              },
              child: const Text('Back to Login'))
        ],
      ),
    );
  }
}
