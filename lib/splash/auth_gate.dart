import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:ai_tour/login/loginPage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LanguageSelectionScreen();
        }

        return const UserMainPage();
      },
    );
  }
}