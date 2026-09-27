import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/podcast.dart';

class PodcastService {
  final CollectionReference _podcasts =
      FirebaseFirestore.instance.collection('podcasts');

  /// Real-time feed of all podcasts, newest first.
  Stream<List<Podcast>> streamPodcasts() {
    return _podcasts.orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => Podcast.fromFirestore(d)).toList());
  }

  Future<void> addPodcast(Podcast podcast) async {
    try {
      await _podcasts.add(podcast.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  Future<void> updatePodcast(Podcast podcast) async {
    try {
      await _podcasts.doc(podcast.id).update(podcast.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  Future<void> deletePodcast(String podcastId) async {
    try {
      await _podcasts.doc(podcastId).delete();
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  String _translate(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to do this.';
      case 'unavailable':
        return 'You appear to be offline. Please check your connection.';
      case 'not-found':
        return 'That podcast no longer exists.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
