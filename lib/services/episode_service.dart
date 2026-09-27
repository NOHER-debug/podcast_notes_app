import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/episode.dart';

class EpisodeService {
  final CollectionReference _episodes =
      FirebaseFirestore.instance.collection('episodes');

  /// Real-time list of episodes belonging to one podcast, ordered by
  /// episode number.
  Stream<List<Episode>> streamEpisodesForPodcast(String podcastId) {
    return _episodes
        .where('podcastId', isEqualTo: podcastId)
        .orderBy('episodeNumber')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Episode.fromFirestore(d)).toList());
  }

  Future<void> addEpisode(Episode episode) async {
    try {
      await _episodes.add(episode.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  Future<void> updateEpisode(Episode episode) async {
    try {
      await _episodes.doc(episode.id).update(episode.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  Future<void> deleteEpisode(String episodeId) async {
    try {
      await _episodes.doc(episodeId).delete();
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  String _translate(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Only the podcast owner can manage its episodes.';
      case 'unavailable':
        return 'You appear to be offline. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
