import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/classification_result.dart';
import 'package:project/models/meal.dart';
import 'package:project/models/nutrition.dart';
import 'package:project/services/classifier_service.dart';
import 'package:project/services/meal_api_service.dart';
import 'package:project/services/gemini_service.dart';
import 'package:project/services/firebase_ml_service.dart';

class FoodClassifierProvider extends ChangeNotifier {
  final ClassifierService _classifierService = ClassifierService();
  final MealApiService _mealApiService = MealApiService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseMLService _firebaseMLService = FirebaseMLService();
  final ImagePicker _imagePicker = ImagePicker();

  // State
  File? _selectedImage;
  ClassificationResult? _classificationResult;
  List<Meal> _meals = [];
  Nutrition? _nutrition;
  bool _isLoading = false;
  bool _isClassifying = false;
  bool _isFetchingMeals = false;
  bool _isFetchingNutrition = false;
  String? _error;
  bool _isModelInitialized = false;
  bool _isFirebaseModel = false;

  // Getters
  File? get selectedImage => _selectedImage;
  ClassificationResult? get classificationResult => _classificationResult;
  List<Meal> get meals => _meals;
  Nutrition? get nutrition => _nutrition;
  bool get isLoading => _isLoading;
  bool get isClassifying => _isClassifying;
  bool get isFetchingMeals => _isFetchingMeals;
  bool get isFetchingNutrition => _isFetchingNutrition;
  String? get error => _error;
  bool get isModelInitialized => _isModelInitialized;
  bool get isFirebaseModel => _isFirebaseModel;
  ClassifierService get classifierService => _classifierService;

  /// Initialize the ML model
  Future<void> initializeModel() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Try Firebase ML first
      try {
        final path = await _firebaseMLService.downloadAndInitialize(_classifierService);
        if (path != null) {
          _isFirebaseModel = true;
          _isModelInitialized = true;
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        // Firebase ML failed, fallback to local
      }

      // Fallback to local model
      await _classifierService.initialize();
      _isModelInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Model init error: $e');
      _error = 'Gagal memuat model AI. Pastikan koneksi internet stabil dan coba restart aplikasi.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _classificationResult = null;
        _meals = [];
        _nutrition = null;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
      _error = 'Gagal memilih gambar. Pastikan izin akses galeri sudah diberikan.';
      notifyListeners();
    }
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _classificationResult = null;
        _meals = [];
        _nutrition = null;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
      _error = 'Gagal mengambil foto. Pastikan izin akses kamera sudah diberikan.';
      notifyListeners();
    }
  }

  /// Set image from custom camera or cropper
  void setImage(String path) {
    _selectedImage = File(path);
    _classificationResult = null;
    _meals = [];
    _nutrition = null;
    _error = null;
    notifyListeners();
  }

  /// Set cropped image
  void setCroppedImage(String path) {
    _selectedImage = File(path);
    notifyListeners();
  }

  /// Classify the selected image
  Future<void> classifyImage() async {
    if (_selectedImage == null) {
      _error = 'Belum ada gambar yang dipilih. Silakan ambil atau pilih gambar terlebih dahulu.';
      notifyListeners();
      return;
    }

    if (!_isModelInitialized) {
      _error = 'Model AI belum siap. Tunggu beberapa saat atau restart aplikasi.';
      notifyListeners();
      return;
    }

    try {
      _isClassifying = true;
      _error = null;
      notifyListeners();

      _classificationResult = await _classifierService.classifyImageFromPath(
        _selectedImage!.path,
      );

      _isClassifying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Classification error: $e');
      _error = 'Gagal menganalisis gambar. Coba gunakan gambar makanan yang lebih jelas.';
      _isClassifying = false;
      notifyListeners();
    }
  }

  /// Fetch meal info from MealDB API
  Future<void> fetchMealInfo() async {
    if (_classificationResult == null) return;

    try {
      _isFetchingMeals = true;
      notifyListeners();

      _meals = await _mealApiService.searchMealByName(
        _classificationResult!.label,
      );

      _isFetchingMeals = false;
      notifyListeners();
    } catch (e) {
      debugPrint('MealDB fetch error: $e');
      _isFetchingMeals = false;
      notifyListeners();
    }
  }

  /// Fetch nutrition info from Gemini API
  Future<void> fetchNutritionInfo() async {
    if (_classificationResult == null) return;

    try {
      _isFetchingNutrition = true;
      notifyListeners();

      _nutrition = await _geminiService.getNutritionInfo(
        _classificationResult!.label,
      );

      _isFetchingNutrition = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Gemini nutrition error: $e');
      _isFetchingNutrition = false;
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('quota') || errorMsg.contains('rate')) {
        _error = 'Kuota API nutrisi habis. Coba lagi nanti atau gunakan API key baru.';
      } else if (errorMsg.contains('network') || errorMsg.contains('socket') || errorMsg.contains('connection')) {
        _error = 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';
      } else {
        _error = 'Gagal memuat informasi nutrisi. Coba lagi nanti.';
      }
      notifyListeners();
    }
  }

  /// Classify image and fetch all related info
  Future<void> classifyAndFetchAll() async {
    await classifyImage();

    if (_classificationResult != null) {
      // Run API calls in parallel
      await Future.wait([
        fetchMealInfo(),
        fetchNutritionInfo(),
      ]);
    }
  }

  /// Reset all state
  void reset() {
    _selectedImage = null;
    _classificationResult = null;
    _meals = [];
    _nutrition = null;
    _isLoading = false;
    _isClassifying = false;
    _isFetchingMeals = false;
    _isFetchingNutrition = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _classifierService.dispose();
    super.dispose();
  }
}
