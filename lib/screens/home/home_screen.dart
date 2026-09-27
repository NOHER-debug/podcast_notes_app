import 'package:flutter/material.dart';
import '../podcasts/podcast_list_screen.dart';

/// AuthGate routes here once signed in. This simply hands off to the
/// Podcast feed, which is the real home screen (Day 11).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PodcastListScreen();
  }
}
