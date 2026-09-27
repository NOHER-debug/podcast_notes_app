import 'package:cloud_firestore/cloud_firestore.dart';

/// "Podcast" — the entity users reference/browse but don't individually
/// own. Carries the cover image uploaded to Cloud Storage.
class Podcast {
  final String id;
  final String title;
  final String host;
  final String description;
  final String coverImageUrl;
  final String category;
  final String addedBy; // uid of the user who added this podcast
  final DateTime createdAt;

  Podcast({
    required this.id,
    required this.title,
    required this.host,
    required this.description,
    required this.coverImageUrl,
    required this.category,
    required this.addedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'host': host,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'category': category,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Podcast.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Podcast(
      id: doc.id,
      title: data['title'] ?? '',
      host: data['host'] ?? '',
      description: data['description'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      category: data['category'] ?? '',
      addedBy: data['addedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Podcast copyWith({
    String? title,
    String? host,
    String? description,
    String? coverImageUrl,
    String? category,
  }) {
    return Podcast(
      id: id,
      title: title ?? this.title,
      host: host ?? this.host,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      category: category ?? this.category,
      addedBy: addedBy,
      createdAt: createdAt,
    );
  }
}
