import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/services/oss_upload_service.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  File? _newAvatarFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户名不能为空')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // This will be the RELATIVE path if a new avatar is chosen.
    String? finalAvatarPath = widget.user.avatarUrl;

    if (_newAvatarFile != null) {
      final ossService = context.read<OssUploadService>();
      try {
        // Upload the file and get the new object key (relative path).
        finalAvatarPath = await ossService.uploadFile(_newAvatarFile!, uploadPath: 'videos/avatars');
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('头像上传失败: $e')),
          );
        }
        return;
      }
    }

    // Dispatch the RELATIVE path to the BLoC.
    if (mounted) {
      context.read<AuthBloc>().add(
            UpdateProfileEvent(
              username: _usernameController.text,
              bio: _bioController.text,
              avatarUrl: finalAvatarPath,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            setState(() {
              _isUploading = false;
            });
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('个人资料已更新')),
              );
              Navigator.of(context).pop();
            }
          } else if (state is AuthError) {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('更新失败: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading || _isUploading;
          
          ImageProvider? backgroundImage;
          if (_newAvatarFile != null) {
            backgroundImage = FileImage(_newAvatarFile!); // Local preview is fine.
          } else if (widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty) {
            // Always use avatarUrl directly, as it's a full URL from the backend.
            backgroundImage = NetworkImage(widget.user.avatarUrl!);
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: backgroundImage,
                        child: backgroundImage == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: '个人简介',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}
