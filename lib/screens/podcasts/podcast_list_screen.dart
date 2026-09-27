import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/podcast.dart';
import '../../services/podcast_service.dart';
import '../../services/auth_service.dart';
import 'podcast_form_screen.dart';
import 'podcast_detail_screen.dart';

/// Real-time feed of all podcasts (FR: "real-time display").
/// This is your new HomeScreen — wire it in from AuthGate.
class PodcastListScreen extends StatelessWidget {
  const PodcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final podcastService = PodcastService();
    final authService = AuthService();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcasts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Podcast>>(
        stream: podcastService.streamPodcasts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final podcasts = snapshot.data ?? [];
          if (podcasts.isEmpty) {
            return const Center(
              child: Text('No podcasts yet. Tap + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              final podcast = podcasts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: podcast.coverImageUrl.isNotEmpty
                      ? NetworkImage(podcast.coverImageUrl)
                      : null,
                  child: podcast.coverImageUrl.isEmpty
                      ? const Icon(Icons.podcasts)
                      : null,
                ),
                title: Text(podcast.title),
                subtitle: Text('${podcast.host} · ${podcast.category}'),
                trailing: podcast.addedBy == currentUid
                    ? const Icon(Icons.edit, size: 18)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PodcastDetailScreen(podcast: podcast),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PodcastFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
