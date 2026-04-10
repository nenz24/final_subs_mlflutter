import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/food_classifier_provider.dart';
import 'package:project/utils/image_utils.dart';
import 'package:project/models/classification_result.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isProcessingStream = false;
  ClassificationResult? _liveResult;
  int _frameSkipCount = 0;

  // Pulsing animation for capture button
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      // Start image stream for real-time classification
      _startImageStream();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _startImageStream() {
    final provider = context.read<FoodClassifierProvider>();
    if (!provider.isModelInitialized) return;

    _controller?.startImageStream((CameraImage image) {
      _frameSkipCount++;
      // Process every 30th frame to avoid overloading
      if (_frameSkipCount % 30 != 0) return;
      if (_isProcessingStream) return;

      _isProcessingStream = true;
      _processCameraFrame(image, provider);
    });
  }

  Future<void> _processCameraFrame(
    CameraImage cameraImage,
    FoodClassifierProvider provider,
  ) async {
    try {
      final img = ImageUtils.convertCameraImage(cameraImage);
      final result = provider.classifierService.classifyCameraFrame(img);

      if (result != null && mounted) {
        setState(() {
          _liveResult = result;
        });
      }
    } catch (e) {
      // Silently handle frame processing errors
    } finally {
      _isProcessingStream = false;
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Stop image stream before capturing
      await _controller!.stopImageStream();

      final file = await _controller!.takePicture();

      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview — full screen
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),

                // Top bar with back button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFEF4444),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Live classification result overlay
                if (_liveResult != null)
                  Positioned(
                    bottom: 140,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1923).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0D9373).withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9373)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF0D9373),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _liveResult!.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Live Detection',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(
                                _liveResult!.confidence,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getConfidenceColor(
                                  _liveResult!.confidence,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              _liveResult!.confidencePercentage,
                              style: TextStyle(
                                color: _getConfidenceColor(
                                  _liveResult!.confidence,
                                ),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Capture button with pulse animation
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isCapturing ? 1.0 : _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0D9373),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9373)
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing
                                  ? Colors.grey.shade700
                                  : const Color(0xFF0D9373)
                                      .withValues(alpha: 0.4),
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: const Color(0xFF0D9373).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return const Color(0xFF22C55E);
    if (confidence >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
