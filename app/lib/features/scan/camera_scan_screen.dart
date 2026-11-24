import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../widgets/big_button.dart';
import '../find_medicine/find_medicine_screen.dart';
import 'widgets/camera_overlay_painter.dart';

/// Screen 2 — Live Camera Scan Screen (Phase 4B).
///
/// Features:
/// - Real-time camera preview using the official `camera` plugin.
/// - High-contrast viewfinder overlay specifically designed for medicine strips.
/// - Flash/torch toggle with explicit accessibility tooltip and state icon.
/// - Single-action capture button (large touch target >= 64dp).
/// - Fallback option: "Type the name instead" (never locks the user out).
/// - Handles camera initialization, permission denial, and lifecycle transitions.
class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key, this.cameraDescription});

  final CameraDescription? cameraDescription;

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTorchOn = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      CameraDescription? targetCamera = widget.cameraDescription;
      if (targetCamera == null) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          if (mounted) {
            setState(() {
              _errorMessage = Strings.scanNoCamera;
            });
          }
          return;
        }
        // Prefer back camera for scanning physical objects
        targetCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      final controller = CameraController(
        targetCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _controller = controller;

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _errorMessage = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'CameraAccessDenied' ||
            e.code == 'CameraAccessDeniedWithoutPrompt' ||
            e.code == 'CameraAccessRestricted') {
          _errorMessage = Strings.scanPermissionDenied;
        } else {
          _errorMessage = 'Camera error: ${e.description ?? e.code}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = Strings.scanNoCamera;
      });
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final nextMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(nextMode);
      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (_) {
      // Some devices or emulators do not support flash
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final xFile = await controller.takePicture();
      if (!mounted) return;

      // In Phase 4B, verify capture success.
      // Phase 4C / 4E will forward xFile to OcrService and CandidateMatcher.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo captured: ${xFile.name} (${(await xFile.length()) ~/ 1024} KB)',
            style: const TextStyle(fontSize: 16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: AppTheme.redBorder,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _navigateToFindMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FindMedicineScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(Strings.scanTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          tooltip: Strings.back,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isInitialized)
            IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                size: 28,
                color: _isTorchOn ? Colors.amber : Colors.white,
              ),
              tooltip: _isTorchOn ? Strings.scanTorchOff : Strings.scanTorchOn,
              onPressed: _toggleTorch,
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        Center(
          child: CameraPreview(_controller!),
        ),

        // Viewfinder and scrim overlay
        const Positioned.fill(
          child: CustomPaint(
            painter: CameraOverlayPainter(),
          ),
        ),

        // Controls and instructions overlay
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top instruction banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                Strings.scanInstruction,
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // Bottom control buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary Capture Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isCapturing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.camera_alt, size: 28),
                    label: Text(
                      Strings.scanCaptureButton,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _isCapturing ? null : _capturePhoto,
                  ),
                  const SizedBox(height: 12),

                  // Fallback: Type instead button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70, width: 2),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_outlined, size: 24),
                    label: Text(
                      Strings.scanTypeInstead,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _navigateToFindMedicine,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(
            Icons.no_photography_outlined,
            size: 80,
            color: Colors.white70,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTheme.bodyStyle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          BigButton(
            label: Strings.scanTypeInstead,
            icon: Icons.keyboard_outlined,
            onPressed: _navigateToFindMedicine,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
