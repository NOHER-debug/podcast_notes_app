import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final CollectionReference _notes =
      FirebaseFirestore.instance.collection('notes');

  /// Real-time list of the CURRENT user's notes for one episode.
  /// (Security rules also enforce this ownership server-side.)
  Stream<List<Note>> streamNotesForEpisode(String episodeId, String userId) {
    return _notes
        .where('episodeId', isEqualTo: episodeId)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Note.fromFirestore(d)).toList());
  }

  Future<void> addNote(Note note) async {
    try {
      await _notes.add(note.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notes.doc(note.id).update(note.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notes.doc(noteId).delete();
    } on FirebaseException catch (e) {
      throw Exception(_translate(e.code));
    }
  }

  String _translate(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You can only manage your own notes.';
      case 'unavailable':
        return 'You appear to be offline. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
