import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/episode.dart';
import '../../services/episode_service.dart';

/// Used for BOTH creating a new episode (pass podcastId) and editing an
/// existing one (pass episode).
class EpisodeFormScreen extends StatefulWidget {
  final String podcastId;
  final Episode? episode;
  const EpisodeFormScreen({super.key, required this.podcastId, this.episode});

  @override
  State<EpisodeFormScreen> createState() => _EpisodeFormScreenState();
}

class _EpisodeFormScreenState extends State<EpisodeFormScreen> {
  final _episodeService = EpisodeService();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _numberController;
  late final TextEditingController _durationController;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.episode != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.episode?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.episode?.description ?? '');
    _numberController = TextEditingController(
        text: widget.episode?.episodeNumber.toString() ?? '');
    _durationController = TextEditingController(
        text: widget.episode?.durationMinutes.toString() ?? '');
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (_isEditing) {
        final updated = Episode(
          id: widget.episode!.id,
          podcastId: widget.episode!.podcastId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          episodeNumber: int.tryParse(_numberController.text) ?? 0,
          durationMinutes: int.tryParse(_durationController.text) ?? 0,
          addedBy: widget.episode!.addedBy,
          createdAt: widget.episode!.createdAt,
        );
        await _episodeService.updateEpisode(updated);
      } else {
        final episode = Episode(
          id: '', // Firestore assigns this in addEpisode()
          podcastId: widget.podcastId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          episodeNumber: int.tryParse(_numberController.text) ?? 0,
          durationMinutes: int.tryParse(_durationController.text) ?? 0,
          addedBy: uid,
          createdAt: DateTime.now(),
        );
        await _episodeService.addEpisode(episode);
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
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Episode' : 'Add Episode')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Episode Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
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
                  : Text(_isEditing ? 'Save Changes' : 'Add Episode'),
            ),
          ],
        ),
      ),
    );
  }
}
