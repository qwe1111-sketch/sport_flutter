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
  final List<File> _selectedFiles = [];

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

  Future<void> _pickMedia() async {
    if (_selectedFiles.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能选择6个文件')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultipleMedia(limit: 6 - _selectedFiles.length);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(pickedFiles.map((file) => File(file.path)));
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
                                  mediaFiles: _selectedFiles,
                                ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
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
              _buildMediaGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedFiles.length + (_selectedFiles.length < 6 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _selectedFiles.length && _selectedFiles.length < 6) {
          return GestureDetector(
            onTap: _pickMedia,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.black54),
            ),
          );
        }

        final file = _selectedFiles[index];
        final isImage = ['.jpg', '.jpeg', '.png', '.gif'].any((ext) => file.path.toLowerCase().endsWith(ext));

        return Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover)
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
              onPressed: () {
                setState(() {
                  _selectedFiles.removeAt(index);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
