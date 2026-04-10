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
          toolbarColor: const Color(0xFF0D9373),
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
      body: Consumer<FoodClassifierProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // Custom App Bar with glassmorphism
              _buildSliverAppBar(provider),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Image preview card
                      _buildImagePreview(context, provider),

                      const SizedBox(height: 24),

                      // Source selection chips
                      _buildSourceChips(context, provider),

                      const SizedBox(height: 20),

                      // Action buttons
                      if (provider.selectedImage != null)
                        _buildActionSection(context, provider),

                      // Error display
                      if (provider.error != null)
                        _buildErrorCard(provider.error!),

                      // Model loading
                      if (!provider.isModelInitialized && provider.isLoading)
                        _buildModelLoading(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(FoodClassifierProvider provider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF0F1923).withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9373), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'FoodLens',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            // Model status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.isModelInitialized
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B),
                boxShadow: [
                  BoxShadow(
                    color: provider.isModelInitialized
                        ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF0D9373).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9373).withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: provider.selectedImage != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  provider.selectedImage!,
                  fit: BoxFit.cover,
                ),
                // Bottom gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF22C55E),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Image ready for analysis',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              decoration: BoxDecoration(
                color: const Color(0xFF162231),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0D9373).withValues(alpha: 0.2),
                            const Color(0xFF06B6D4).withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: 48,
                        color: const Color(0xFF0D9373).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Take or select a food photo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use the options below to get started',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSourceChips(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SourceChip(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            color: const Color(0xFF0D9373),
            onTap: () => provider.pickImageFromGallery(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SourceChip(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            color: const Color(0xFF0891B2),
            onTap: () => provider.pickImageFromCamera(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SourceChip(
            icon: Icons.videocam_rounded,
            label: 'Live Feed',
            color: const Color(0xFF7C3AED),
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
              if (result != null && context.mounted) {
                context.read<FoodClassifierProvider>().setImage(result);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return Column(
      children: [
        // Analyze button — full width, primary
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isClassifying || !provider.isModelInitialized
                ? null
                : () => _analyze(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9373),
              disabledBackgroundColor:
                  const Color(0xFF0D9373).withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: provider.isClassifying
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Analyzing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Analyze Food',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Crop & Analyze — outlined
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: provider.isClassifying || !provider.isModelInitialized
                ? null
                : () => _cropAndAnalyze(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF06B6D4),
              side: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.crop_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Crop & Analyze',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style:
                    const TextStyle(color: Color(0xFFF87171), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelLoading() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                const Color(0xFF0D9373).withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading ML Model...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Source Chip Widget ───────────────────────────────────────────────────────

class _SourceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
