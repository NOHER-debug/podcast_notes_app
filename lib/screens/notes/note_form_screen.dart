import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/note.dart';
import '../../services/note_service.dart';

/// Used for BOTH creating a new note (pass episodeId) and editing an
/// existing one (pass note).
class NoteFormScreen extends StatefulWidget {
  final String episodeId;
  final Note? note;
  const NoteFormScreen({super.key, required this.episodeId, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _noteService = NoteService();
  late final TextEditingController _contentController;
  late final TextEditingController _timestampController;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _timestampController =
        TextEditingController(text: widget.note?.timestampInEpisode ?? '');
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (_isEditing) {
        final updated = Note(
          id: widget.note!.id,
          userId: widget.note!.userId,
          episodeId: widget.note!.episodeId,
          content: _contentController.text.trim(),
          timestampInEpisode: _timestampController.text.trim(),
          createdAt: widget.note!.createdAt,
        );
        await _noteService.updateNote(updated);
      } else {
        final note = Note(
          id: '',
          userId: uid,
          episodeId: widget.episodeId,
          content: _contentController.text.trim(),
          timestampInEpisode: _timestampController.text.trim(),
          createdAt: DateTime.now(),
        );
        await _noteService.addNote(note);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _timestampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Note' : 'Add Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _timestampController,
              decoration: const InputDecoration(
                labelText: 'Timestamp in episode (e.g. 12:45)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your note',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? 'Save Changes' : 'Add Note'),
            ),
          ],
        ),
      ),
    );
  }
}
