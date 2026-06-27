import 'package:flutter/material.dart';

import '../theme/centinela_theme.dart';

/// Pin de alerta en el mapa del Home.
class CentinelaMapMarker extends StatelessWidget {
  const CentinelaMapMarker({super.key, this.photoUrl, this.size = 44});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: CentinelaColors.alertCritical.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _PinFallback(size: size),
                  )
                : _PinFallback(size: size),
          ),
        ),
        CustomPaint(
          size: Size(size * 0.35, size * 0.2),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

class _PinFallback extends StatelessWidget {
  const _PinFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CentinelaColors.alertCritical,
      alignment: Alignment.center,
      child: Icon(Icons.person, color: Colors.white, size: size * 0.5),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = CentinelaColors.alertCritical;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Indicador de ubicación del usuario en el mapa.
class CentinelaUserMarker extends StatelessWidget {
  const CentinelaUserMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CentinelaColors.community,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: CentinelaColors.community.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}
