import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:project/providers/food_classifier_provider.dart';
import 'package:project/screens/camera_screen.dart';
import 'package:project/screens/result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _cropAndAnalyze(BuildContext context) async {
    final provider = context.read<FoodClassifierProvider>();
    if (provider.selectedImage == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: provider.selectedImage!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: const Color(0xFFE53935),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      provider.setCroppedImage(croppedFile.path);
      if (context.mounted) {
        _analyze(context);
      }
    }
  }

  Future<void> _analyze(BuildContext context) async {
    final provider = context.read<FoodClassifierProvider>();

    await provider.classifyAndFetchAll();

    if (context.mounted && provider.classificationResult != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Recognizer App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<FoodClassifierProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image display area
                _buildImageCard(context, provider),

                const SizedBox(height: 24),

                // Image source buttons
                _buildImageSourceButtons(context, provider),

                const SizedBox(height: 16),

                // Camera feed button
                _buildCameraFeedButton(context),

                const SizedBox(height: 24),

                // Action buttons
                if (provider.selectedImage != null) ...[
                  _buildActionButtons(context, provider),
                ],

                // Error display
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Card(
                      color: Colors.red.shade900.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                // Model loading indicator
                if (!provider.isModelInitialized && provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          'Loading ML Model...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, FoodClassifierProvider provider) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF16213E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: provider.selectedImage != null
          ? Image.file(
              provider.selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select or capture a food image',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSourceButtons(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _GradientButton(
            icon: Icons.photo_library,
            label: 'Gallery',
            onPressed: () => provider.pickImageFromGallery(),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3460), Color(0xFF533483)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GradientButton(
            icon: Icons.camera_alt,
            label: 'Camera',
            onPressed: () => provider.pickImageFromCamera(),
            gradient: const LinearGradient(
              colors: [Color(0xFF533483), Color(0xFFE94560)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraFeedButton(BuildContext context) {
    return _GradientButton(
      icon: Icons.videocam,
      label: 'Camera Feed (Real-time)',
      onPressed: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        if (result != null && context.mounted) {
          context.read<FoodClassifierProvider>().setImage(result);
        }
      },
      gradient: const LinearGradient(
        colors: [Color(0xFF0F3460), Color(0xFF16213E), Color(0xFF533483)],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Analyze button
        ElevatedButton.icon(
          onPressed: provider.isClassifying || !provider.isModelInitialized
              ? null
              : () => _analyze(context),
          icon: provider.isClassifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(
            provider.isClassifying ? 'Analyzing...' : 'Analyze',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3460),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 12),

        // Crop & Analyze button
        ElevatedButton.icon(
          onPressed: provider.isClassifying || !provider.isModelInitialized
              ? null
              : () => _cropAndAnalyze(context),
          icon: const Icon(Icons.crop),
          label: const Text('Crop & Analyze'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF533483),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Gradient gradient;

  const _GradientButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
