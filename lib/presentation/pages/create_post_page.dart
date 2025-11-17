import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_flutter/presentation/bloc/community_bloc.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPost = _titleController.text.isNotEmpty && _contentController.text.isNotEmpty;

    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CommunityPostSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('发表新帖'),
          actions: [
            BlocBuilder<CommunityBloc, CommunityState>(
              builder: (context, state) {
                final isSubmitting = state is CommunityLoading;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: canPost && !isSubmitting 
                        ? () {
                            context.read<CommunityBloc>().add(AddPost(
                                  title: _titleController.text,
                                  content: _contentController.text,
                                  mediaFile: _selectedFile,
                                ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Colors.grey.shade700,
                    ),
                    child: isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('发表'),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: const InputDecoration.collapsed(
                  hintText: '标题',
                ),
              ),
              const Divider(height: 32),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration.collapsed(
                  hintText: '内容...',
                ),
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              _buildMediaPreview(),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.photo_library_outlined, size: 28), onPressed: () => _pickMedia(ImageSource.gallery)),
                  const SizedBox(width: 16),
                  IconButton(icon: const Icon(Icons.videocam_outlined, size: 28), onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    final isImage = ['.jpg', '.jpeg', '.png', '.gif'].any((ext) => _selectedFile!.path.toLowerCase().endsWith(ext));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 100,
                height: 100,
                child: isImage
                    ? Image.file(_selectedFile!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Icon(Icons.movie_creation_outlined, color: Colors.white, size: 48),
                      ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 16)),
              onPressed: () => setState(() => _selectedFile = null),
            ),
          ],
        ),
      ),
    );
  }
}
