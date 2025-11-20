import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';
import '../services/content_validation_service.dart';
import '../services/vision_validation_service.dart';

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
  final _storageService = StorageService();
  final _validationService = ContentValidationService();

  File? _newImage;
  bool _isSaving = false;
  bool _isValidating = false;
  bool _isValidatingImage = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _zonaCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio);
    _direccionCtrl = TextEditingController(text: widget.user.direccion);
    _zonaCtrl = TextEditingController(text: widget.user.zona ?? '');
  }

  Future<void> _pickImage() async {
    try {
      final File? pickedFile = await _storageService.pickImage();
      if (pickedFile != null) {
        // ✅ Validar tamaño antes de asignar
        final isValidSize = await _storageService.isValidFileSize(pickedFile);
        if (!isValidSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La imagen es demasiado grande. Máximo 5MB.'),
              ),
            );
          }
          return;
        }

        // 🔹 VALIDAR IMAGEN CON GOOGLE VISION API
        setState(() => _isValidatingImage = true);

        final visionResult =
            await VisionValidationService.validateProfileImage(pickedFile);

        setState(() => _isValidatingImage = false);

        if (!visionResult.isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(visionResult.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        // Mostrar advertencia si es fallback
        if (visionResult.isFallback) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(visionResult.message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }

        setState(() => _newImage = pickedFile);
      }
    } catch (e) {
      setState(() => _isValidatingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isValidating = true);

    try {
      final validationResult = await ContentValidationService.validateProfile(
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      );

      if (!validationResult.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${validationResult.issues.first.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en validación: $e')),
      );
      return;
    } finally {
      setState(() => _isValidating = false);
    }

    setState(() => _isSaving = true);
    try {
      String? photoUrl = widget.user.photoUrl;

      if (_newImage != null) {
        photoUrl = await _storageService.updateProfilePhoto(
          userId: widget.user.userId,
          newImageFile: _newImage!,
          oldPhotoUrl:
              widget.user.photoUrl.isNotEmpty ? widget.user.photoUrl : null,
        );
      }

      await _userService.updateProfile(
        userId: widget.user.userId,
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        photoUrl: photoUrl,
        direccion: _direccionCtrl.text.trim(),
        zona: _zonaCtrl.text.trim(),
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
                                  child: _isValidatingImage
                                      ? const CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.transparent,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 30,
                                                height: 30,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Validando...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 60,
                                          backgroundImage: _newImage != null
                                              ? FileImage(_newImage!)
                                              : (widget.user.photoUrl.isNotEmpty
                                                  ? NetworkImage(
                                                      widget.user.photoUrl)
                                                  : const AssetImage(
                                                          'assets/images/logo.png')
                                                      as ImageProvider),
                                        ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 4,
                                  child: GestureDetector(
                                    onTap:
                                        _isValidatingImage ? null : _pickImage,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: _isValidatingImage
                                            ? Colors.grey
                                            : const Color(0xFF5E5CF9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _isValidatingImage
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
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
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _direccionCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _fieldDecoration('Dirección'),
                          ),
                          if (widget.user.role == 'provider' || widget.user.role == 'both') ...[
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _zonaCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _fieldDecoration('Zona donde trabaja'),
                            ),
                          ],
                          const SizedBox(height: 36),
                          _isValidating
                              ? const Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Validando contenido...',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                )
                              : _isSaving
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
                                          backgroundColor:
                                              const Color(0xFF554CFF),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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