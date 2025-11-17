import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ServiceStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ============== SELECCIONAR IMAGEN ==============
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw 'Error al seleccionar imagen: $e';
    }
  }

  // ============== SUBIR FOTO DE SERVICIO ==============
  Future<String> uploadServicePhoto({
    required String serviceId,
    required File imageFile,
  }) async {
    try {
      // 1. Crear referencia en Storage
      final String fileName =
          'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(
        'services/$serviceId/$fileName',
      );

      // 2. Metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'serviceId': serviceId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // 3. Subir archivo
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // 4. Mostrar progreso (opcional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // 5. Esperar y obtener URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Error de Firebase Storage: ${e.message}';
    } catch (e) {
      throw 'Error al subir imagen: $e';
    }
  }

  // ============== ELIMINAR FOTO DE SERVICIO ==============
  Future<void> deleteServicePhoto(String photoUrl) async {
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

  // ============== ACTUALIZAR FOTO DE SERVICIO ==============
  Future<String> updateServicePhoto({
    required String serviceId,
    required File newImageFile,
    String? oldPhotoUrl,
  }) async {
    try {
      // 1. Eliminar foto anterior si existe
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        await deleteServicePhoto(oldPhotoUrl);
      }

      // 2. Subir nueva foto
      final String newUrl = await uploadServicePhoto(
        serviceId: serviceId,
        imageFile: newImageFile,
      );

      return newUrl;
    } catch (e) {
      throw 'Error al actualizar foto: $e';
    }
  }

  // ============== SUBIR MÚLTIPLES FOTOS (Para v2) ==============
  Future<List<String>> uploadMultiplePhotos({
    required String serviceId,
    required List<File> imageFiles,
  }) async {
    try {
      final List<String> urls = [];

      for (var i = 0; i < imageFiles.length; i++) {
        final url = await uploadServicePhoto(
          serviceId: '$serviceId-photo$i',
          imageFile: imageFiles[i],
        );
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw 'Error al subir múltiples fotos: $e';
    }
  }

  // ============== VALIDAR TAMAÑO (MAX 5MB) ==============
  Future<bool> isValidFileSize(File file, {int maxSizeMB = 5}) async {
    try {
      final size = await file.length();
      final maxSizeBytes = maxSizeMB * 1024 * 1024;
      return size <= maxSizeBytes;
    } catch (e) {
      return false;
    }
  }

  // ============== OBTENER TAMAÑO DE ARCHIVO ==============
  Future<String> getFileSizeString(File file) async {
    try {
      final bytes = await file.length();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }
}
