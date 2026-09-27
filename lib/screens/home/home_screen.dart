import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/// Placeholder for now — in the next step we'll turn this into the
/// Podcast feed (Cloud Firestore + Cloud Storage layer).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Signed in as ${authService.currentUser?.email ?? ''}\n\n'
          'Podcast feed goes here next.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
