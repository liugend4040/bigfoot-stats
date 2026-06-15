import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUid;

  void _handleLoggedUser(BuildContext context, User user) {
    if (_lastUid == user.uid) return;

    _lastUid = user.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppData>().startFirebaseListeners();
    });
  }

  void _handleLoggedOut(BuildContext context) {
    if (_lastUid == null) return;

    _lastUid = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppData>().stopFirebaseListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          _handleLoggedUser(context, user);
          return const HomeScreen();
        }

        _handleLoggedOut(context);
        return const LoginScreen();
      },
    );
  }
}