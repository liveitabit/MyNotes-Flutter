import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // const _HomePage({Key? key}) : super(key: key);

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
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(hintText: 'Email'),
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  final userCredentials = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  devtools.log('userCredentials: $userCredentials');
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    showErrorDialog(
                      context,
                      'Please give a strong password.',
                    );
                  } else if (e.code == 'email-already-in-use') {
                    showErrorDialog(
                      context,
                      'Email is already registered.',
                    );
                  } else if (e.code == 'invalid-email') {
                    showErrorDialog(
                      context,
                      'Entered email is not valid. Please enter a valid email',
                    );
                  } else {
                    showErrorDialog(
                      context,
                      'something else went wrong: ${e.code}',
                    );
                  }
                } catch (e) {
                  showErrorDialog(context, e.runtimeType.toString());
                }
              },
              child: const Text('Register Now'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already Registered? Login Here!'),
          ),
        ],
      ),
    );
  }
}
