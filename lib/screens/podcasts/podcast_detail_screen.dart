import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/podcast.dart';
import '../../models/episode.dart';
import '../../services/podcast_service.dart';
import '../../services/episode_service.dart';
import 'podcast_form_screen.dart';
import '../episodes/episode_form_screen.dart';
import '../episodes/episode_detail_screen.dart';

class PodcastDetailScreen extends StatelessWidget {
  final Podcast podcast;
  const PodcastDetailScreen({super.key, required this.podcast});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Podcast?'),
        content: Text(
            'This will permanently delete "${podcast.title}". This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PodcastService().deletePodcast(podcast.id);
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        podcast.addedBy == FirebaseAuth.instance.currentUser?.uid;
    final episodeService = EpisodeService();

    return Scaffold(
      appBar: AppBar(
        title: Text(podcast.title),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PodcastFormScreen(podcast: podcast),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (podcast.coverImageUrl.isNotEmpty)
            Image.network(podcast.coverImageUrl,
                height: 180, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Host: ${podcast.host}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(podcast.category,
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text(podcast.description),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Episodes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Episode>>(
              stream: episodeService.streamEpisodesForPodcast(podcast.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final episodes = snapshot.data ?? [];
                if (episodes.isEmpty) {
                  return const Center(child: Text('No episodes yet.'));
                }
                return ListView.builder(
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final ep = episodes[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${ep.episodeNumber}')),
                      title: Text(ep.title),
                      subtitle: Text('${ep.durationMinutes} min'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EpisodeDetailScreen(episode: ep),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Episode'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EpisodeFormScreen(podcastId: podcast.id),
          ),
        ),
      ),
    );
  }
}
