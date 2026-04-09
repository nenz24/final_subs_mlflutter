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

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isProcessingStream = false;
  ClassificationResult? _liveResult;
  int _frameSkipCount = 0;

  @override
  void initState() {
    super.initState();
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Camera Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),

                // Live classification result overlay
                if (_liveResult != null)
                  Positioned(
                    bottom: 120,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _liveResult!.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _liveResult!.confidencePercentage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Capture button
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          color: _isCapturing
                              ? Colors.grey
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                        child: _isCapturing
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 40,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green.shade700;
    if (confidence >= 0.4) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}
