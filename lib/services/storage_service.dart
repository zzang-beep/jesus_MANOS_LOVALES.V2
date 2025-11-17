import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ============== SELECCIONAR IMAGEN ==============
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw 'Error al seleccionar imagen: $e';
    }
  }

  // ============== SUBIR FOTO DE PERFIL ==============
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // 1. Crear referencia en Storage
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('users/$userId/$fileName');

      // 2. Metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // 3. Subir archivo
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // 4. Esperar y obtener URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Error de Firebase Storage: ${e.message}';
    } catch (e) {
      throw 'Error al subir imagen: $e';
    }
  }

  // ============== ELIMINAR FOTO DE PERFIL ==============
  Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) return;

      // Obtener referencia desde URL
      final Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      // Si el archivo no existe, no hacer nada
      if (e.code == 'object-not-found') return;
      throw 'Error al eliminar imagen: ${e.message}';
    } catch (e) {
      throw 'Error al eliminar imagen: $e';
    }
  }

  // ============== ACTUALIZAR FOTO DE PERFIL ==============
  Future<String> updateProfilePhoto({
    required String userId,
    required File newImageFile,
    String? oldPhotoUrl,
  }) async {
    try {
      // 1. Eliminar foto anterior si existe
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        await deleteProfilePhoto(oldPhotoUrl);
      }

      // 2. Subir nueva foto
      final String newUrl = await uploadProfilePhoto(
        userId: userId,
        imageFile: newImageFile,
      );

      return newUrl;
    } catch (e) {
      throw 'Error al actualizar foto: $e';
    }
  }

  // ============== OBTENER TAMAÑO DE ARCHIVO ==============
  Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  // ============== VALIDAR TAMAÑO (MAX 5MB) ==============
  Future<bool> isValidFileSize(File file, {int maxSizeMB = 5}) async {
    final size = await getFileSize(file);
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return size <= maxSizeBytes;
  }
}
