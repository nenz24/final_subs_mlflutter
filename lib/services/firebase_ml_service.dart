import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:project/services/classifier_service.dart';

class FirebaseMLService {
  static const String _modelName = 'food-classifier';

  Future<String?> downloadAndInitialize(ClassifierService classifierService) async {
    try {
      final model = await FirebaseModelDownloader.instance.getModel(
        _modelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );

      final modelFile = model.file;
      if (modelFile.existsSync()) {
        await classifierService.initializeFromFile(modelFile.path);
        return modelFile.path;
      }

      return null;
    } catch (e) {
      // Fallback to local model if Firebase ML fails
      return null;
    }
  }
}
