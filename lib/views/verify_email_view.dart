import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/services/auth/auth_service.dart';

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
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text(
            "We've sent you an email for account verification. Please open it to verify your account.",
          ),
          const Text(
              "If you haven't received the mail, click below to resend confirmation mail."),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
              // await FirebaseAuth.instance.signOut();
            },
            child: const Text('Resent Verify Email'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register/',
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
