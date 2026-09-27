import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/podcast.dart';
import '../../services/podcast_service.dart';
import '../../services/storage_service.dart';

/// Used for BOTH creating a new podcast and editing an existing one.
/// Pass an existing [podcast] to edit; leave it null to create.
class PodcastFormScreen extends StatefulWidget {
  final Podcast? podcast;
  const PodcastFormScreen({super.key, this.podcast});

  @override
  State<PodcastFormScreen> createState() => _PodcastFormScreenState();
}

class _PodcastFormScreenState extends State<PodcastFormScreen> {
  final _podcastService = PodcastService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _hostController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;

  File? _pickedImage;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.podcast != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.podcast?.title ?? '');
    _hostController = TextEditingController(text: widget.podcast?.host ?? '');
    _descriptionController =
        TextEditingController(text: widget.podcast?.description ?? '');
    _categoryController =
        TextEditingController(text: widget.podcast?.category ?? '');
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (_isEditing) {
        String coverUrl = widget.podcast!.coverImageUrl;
        if (_pickedImage != null) {
          coverUrl = await _storageService.uploadPodcastCover(
              _pickedImage!, widget.podcast!.id);
        }
        final updated = widget.podcast!.copyWith(
          title: _titleController.text.trim(),
          host: _hostController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          coverImageUrl: coverUrl,
        );
        await _podcastService.updatePodcast(updated);
      } else {
        // Create the Firestore doc first to get an ID, then upload the
        // image using that ID, then update the doc with the image URL.
        final docRef = FirebaseFirestore.instance.collection('podcasts').doc();
        String coverUrl = '';
        if (_pickedImage != null) {
          coverUrl =
              await _storageService.uploadPodcastCover(_pickedImage!, docRef.id);
        }
        final podcast = Podcast(
          id: docRef.id,
          title: _titleController.text.trim(),
          host: _hostController.text.trim(),
          description: _descriptionController.text.trim(),
          coverImageUrl: coverUrl,
          category: _categoryController.text.trim(),
          addedBy: uid,
          createdAt: DateTime.now(),
        );
        await docRef.set(podcast.toFirestore());
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
    _hostController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Podcast' : 'Add Podcast')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                    : (widget.podcast?.coverImageUrl.isNotEmpty ?? false)
                        ? Image.network(widget.podcast!.coverImageUrl,
                            fit: BoxFit.cover)
                        : const Center(
                            child: Icon(Icons.add_a_photo, size: 40)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                  labelText: 'Host', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                  labelText: 'Category', border: OutlineInputBorder()),
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
                  : Text(_isEditing ? 'Save Changes' : 'Add Podcast'),
            ),
          ],
        ),
      ),
    );
  }
}
