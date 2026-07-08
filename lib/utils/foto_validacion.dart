/// Validación de fotos antes de compresión/subida (Sprint 8).
abstract final class FotoValidacion {
  static const maxBytesPreCompresion = 10 * 1024 * 1024;
  static const minAncho = 200;
  static const minAlto = 200;

  static String? validarTamanoBytes(int bytes) {
    if (bytes <= 0) return 'La imagen está vacía.';
    if (bytes > maxBytesPreCompresion) {
      return 'La imagen es muy grande (máx. 10 MB). Elige otra foto.';
    }
    return null;
  }

  static String? validarDimensiones({required int ancho, required int alto}) {
    if (ancho < minAncho || alto < minAlto) {
      return 'La foto debe medir al menos ${minAncho}x$minAlto píxeles.';
    }
    return null;
  }
}
