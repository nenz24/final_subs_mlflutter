import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project/models/classification_result.dart';

class ClassifierService {
  static const int inputSize = 224;
  static const String _modelAsset = 'assets/models/1.tflite';
  static const String _labelsAsset = 'assets/models/labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize the classifier by loading model and labels
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadModel(_modelAsset);
    await _loadLabels();
    _isInitialized = true;
  }

  /// Load model from a file path (used for Firebase ML downloaded models)
  Future<void> initializeFromFile(String modelPath) async {
    _interpreter?.close();
    _interpreter = Interpreter.fromFile(File(modelPath));
    await _loadLabels();
    _isInitialized = true;
  }

  Future<void> _loadModel(String assetPath) async {
    _interpreter = await Interpreter.fromAsset(assetPath);
  }

  Future<void> _loadLabels() async {
    final labelData = await rootBundle.loadString(_labelsAsset);
    _labels = labelData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Classify an image from file path using Isolate for background processing
  Future<ClassificationResult> classifyImageFromPath(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Classifier not initialized');
    }

    final img = await image_lib.decodeImageFile(imagePath);
    if (img == null) {
      throw Exception('Failed to decode image');
    }

    return classifyImage(img);
  }

  /// Classify an image_lib.Image using Isolate
  Future<ClassificationResult> classifyImage(image_lib.Image img) async {
    if (!_isInitialized) {
      throw Exception('Classifier not initialized');
    }

    // Preprocess image
    final input = _preprocessImage(img);

    // Get model path for isolate
    final modelPath = await _getModelFilePath();

    // Run inference in isolate
    final result = await Isolate.run(() {
      return _runInferenceInIsolate(modelPath, input);
    });

    // Find top prediction
    return _getTopResult(result);
  }

  /// Classify camera frame (CameraImage) - synchronous for real-time
  ClassificationResult? classifyCameraFrame(image_lib.Image img) {
    if (!_isInitialized || _interpreter == null) return null;

    final input = _preprocessImage(img);
    final output = List.filled(1 * _getOutputSize(), 0.0).reshape([1, _getOutputSize()]);

    _interpreter!.run(input, output);

    final probabilities = (output[0] as List<double>);
    return _getTopResult(probabilities);
  }

  /// Preprocess image to model input format (224x224 RGB normalized)
  List<List<List<List<double>>>> _preprocessImage(image_lib.Image img) {
    final resized = image_lib.copyResize(img, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }

  int _getOutputSize() {
    return _labels?.length ?? 2024;
  }

  ClassificationResult _getTopResult(List<double> probabilities) {
    double maxScore = -1;
    int maxIndex = 0;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxScore) {
        maxScore = probabilities[i];
        maxIndex = i;
      }
    }

    final label = (_labels != null && maxIndex < _labels!.length)
        ? _labels![maxIndex]
        : 'Unknown';

    return ClassificationResult(
      label: label,
      confidence: maxScore,
    );
  }

  Future<String> _getModelFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/food_model.tflite');

    if (!await modelFile.exists()) {
      final data = await rootBundle.load(_modelAsset);
      await modelFile.writeAsBytes(data.buffer.asUint8List());
    }

    return modelFile.path;
  }

  /// Static method to run inference in an isolate
  static List<double> _runInferenceInIsolate(
    String modelPath,
    List<List<List<List<double>>>> input,
  ) {
    final interpreter = Interpreter.fromFile(File(modelPath));

    final outputShape = interpreter.getOutputTensor(0).shape;
    final outputSize = outputShape.last;

    final output = List.filled(1 * outputSize, 0.0).reshape([1, outputSize]);

    interpreter.run(input, output);
    interpreter.close();

    return List<double>.from(output[0] as List);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
