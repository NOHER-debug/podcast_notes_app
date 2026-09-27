import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the "User" entity — a Firestore document keyed by the
/// Firebase Auth UID, holding the user's profile info.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String bio;
  final String photoUrl;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
