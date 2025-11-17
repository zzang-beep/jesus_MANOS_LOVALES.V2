import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _userService = UserService();

  File? _newImage;
  bool _isSaving = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  Future<String> _uploadProfileImage(String userId, File imageFile) async {
    final ref = FirebaseStorage.instance.ref('user_photos/$userId.jpg');
    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSaving = true);
    try {
      String? photoUrl = widget.user.photoUrl;
      if (_newImage != null) {
        photoUrl = await _uploadProfileImage(widget.user.userId, _newImage!);
      }

      await _userService.updateProfile(
        userId: widget.user.userId,
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        photoUrl: photoUrl,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cambios: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondodeapp.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Editar perfil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Actualiza tu información para que los vecinos te conozcan mejor',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: const Color(0xFF6B7CFF),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _newImage != null
                                        ? FileImage(_newImage!)
                                        : (widget.user.photoUrl.isNotEmpty
                                            ? NetworkImage(widget.user.photoUrl)
                                            : const AssetImage(
                                                    'assets/images/logo.png')
                                                as ImageProvider),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 4,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5E5CF9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _fieldDecoration('Nombre completo'),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Campo requerido'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _bioCtrl,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 4,
                            decoration: _fieldDecoration('Sobre mí'),
                          ),
                          const SizedBox(height: 36),
                          _isSaving
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF554CFF),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Guardar cambios',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
