import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(hintText: 'Email'),
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(hintText: 'Password'),
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
                          print('userCredentials: $userCredentials');
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('Please give a strong password.');
                          } else if (e.code == 'email-already-in-use') {
                            print('Email is already registered.');
                          } else if (e.code == 'invalid-email') {
                            print(
                                'Entered email is not valid. Please enter a valid email');
                          } else {
                            print('something else went wrong: ${e.code}');
                          }
                        } catch (e) {
                          print(e.runtimeType);
                        }
                      },
                      child: const Text('Register Now'),
                    ),
                  ),
                ],
              );
            default:
              return const Text('Loading....');
          }
        },
      ),
    );
  }
}