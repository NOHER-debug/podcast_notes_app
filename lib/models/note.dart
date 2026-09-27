import 'package:cloud_firestore/cloud_firestore.dart';

/// "Note" — the OWNER entity (belongs to the authenticated user) and also
/// the JOIN entity, linking User (userId) and Episode (episodeId).
class Note {
  final String id;
  final String userId;
  final String episodeId;
  final String content;
  final String timestampInEpisode; // e.g. "12:45"
  final DateTime createdAt;

  Note({
    required this.id,
    required this.userId,
    required this.episodeId,
    required this.content,
    required this.timestampInEpisode,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'episodeId': episodeId,
      'content': content,
      'timestampInEpisode': timestampInEpisode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      userId: data['userId'] ?? '',
      episodeId: data['episodeId'] ?? '',
      content: data['content'] ?? '',
      timestampInEpisode: data['timestampInEpisode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
