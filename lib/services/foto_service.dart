import 'dart:async';
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
    return _compressForUpload(bytes);
  }

  /// Objetivo WhatsApp OG: imagen < 300 KB (Sprint 4).
  static Future<Uint8List> _compressForUpload(Uint8List bytes) async {
    const maxBytes = 280 * 1024;
    var quality = 82;

    while (quality >= 50) {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (compressed.length <= maxBytes) {
        return Uint8List.fromList(compressed);
      }
      quality -= 8;
    }

    final fallback = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 640,
      minHeight: 640,
      quality: 50,
      format: CompressFormat.jpeg,
    );
    return Uint8List.fromList(fallback);
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
