import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/features/scan/widgets/camera_overlay_painter.dart';

void main() {
  group('CameraOverlayPainter', () {
    test('repaints only when properties change', () {
      const painter1 = CameraOverlayPainter(
        borderColor: Colors.white,
        borderWidth: 3.0,
      );
      const painter2 = CameraOverlayPainter(
        borderColor: Colors.white,
        borderWidth: 3.0,
      );
      const painter3 = CameraOverlayPainter(
        borderColor: Colors.amber,
        borderWidth: 4.0,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
    });

    testWidgets('paints viewfinder and accent corners without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: Size(400, 800),
              painter: CameraOverlayPainter(),
            ),
          ),
        ),
      );

      expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is CameraOverlayPainter), findsOneWidget);
    });
  });
}
