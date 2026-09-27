import 'package:cloud_firestore/cloud_firestore.dart';

/// "Episode" — belongs to a Podcast (many-to-one via podcastId).
class Episode {
  final String id;
  final String podcastId;
  final String title;
  final String description;
  final int episodeNumber;
  final int durationMinutes;
  final String addedBy;
  final DateTime createdAt;

  Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.description,
    required this.episodeNumber,
    required this.durationMinutes,
    required this.addedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'podcastId': podcastId,
      'title': title,
      'description': description,
      'episodeNumber': episodeNumber,
      'durationMinutes': durationMinutes,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Episode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Episode(
      id: doc.id,
      podcastId: data['podcastId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      episodeNumber: data['episodeNumber'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
      addedBy: data['addedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
