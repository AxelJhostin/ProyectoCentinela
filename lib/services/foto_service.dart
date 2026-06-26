import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Selección, compresión y subida de fotos a Supabase Storage.
class FotoService {
  FotoService._();

  static final _picker = ImagePicker();

  static Future<Uint8List?> pickAndCompress({ImageSource? source}) async {
    final chosen = source ?? await _chooseSource();
    if (chosen == null) return null;

    final file = await _picker.pickImage(
      source: chosen,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 800,
      minHeight: 800,
      quality: 82,
      format: CompressFormat.jpeg,
    );
    return Uint8List.fromList(compressed);
  }

  static Future<ImageSource?> _chooseSource() async {
    // Por defecto galería; cámara se elige desde UI con parámetro.
    return ImageSource.gallery;
  }

  static Future<Uint8List?> pickFromCamera() =>
      pickAndCompress(source: ImageSource.camera);

  static Future<Uint8List?> pickFromGallery() =>
      pickAndCompress(source: ImageSource.gallery);

  static Future<String> uploadAlertaFoto(Uint8List bytes) async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sesión no iniciada');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$fileName';

    await SupabaseService.client.storage.from('centinela-fotos').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    return SupabaseService.client.storage
        .from('centinela-fotos')
        .getPublicUrl(path);
  }
}
