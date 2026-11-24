import 'package:flutter/material.dart';

/// Custom painter for camera viewfinder overlay.
///
/// Draws a semi-transparent dark vignette over the camera preview
/// with a clear, high-contrast rectangular viewfinder in the center
/// sized for standard medicine blister strips.
class CameraOverlayPainter extends CustomPainter {
  const CameraOverlayPainter({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.scrimColor = const Color(0x8A000000),
  });

  final Color borderColor;
  final double borderWidth;
  final Color scrimColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Blister strip target rectangle (centered, 80% width, ~40% height)
    final width = size.width * 0.84;
    final height = size.height * 0.40;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2 - 30; // slightly above center
    final rect = Rect.fromLTWH(left, top, width, height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Scrim overlay with punched-out viewfinder
    final scrimPaint = Paint()
      ..color = scrimColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(rrect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, scrimPaint);

    // Viewfinder border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, borderPaint);

    // Corner accent brackets for elderly clarity
    final cornerPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = borderWidth + 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLength = 28.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(left + width - cornerLength, top), Offset(left + width, top), cornerPaint);
    canvas.drawLine(Offset(left + width, top), Offset(left + width, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + height - cornerLength), Offset(left, top + height), cornerPaint);
    canvas.drawLine(Offset(left, top + height), Offset(left + cornerLength, top + height), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(left + width - cornerLength, top + height), Offset(left + width, top + height), cornerPaint);
    canvas.drawLine(Offset(left + width, top + height), Offset(left + width, top + height - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.scrimColor != scrimColor;
  }
}
