import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Handles the image-upload workflow: pick (done in UI) -> upload here ->
/// caller saves the returned URL into the Firestore document.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a podcast cover image and returns its public download URL.
  Future<String> uploadPodcastCover(File imageFile, String podcastId) async {
    try {
      final ref = _storage.ref().child('podcast_covers/$podcastId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Image upload failed: ${e.message}');
    }
  }
}
