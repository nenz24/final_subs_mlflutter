import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;

class ImageUtils {
  /// Convert CameraImage (YUV420/BGRA) to image_lib.Image
  static image_lib.Image convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(cameraImage);
    }
    throw Exception('Unsupported image format: ${cameraImage.format.group}');
  }

  static image_lib.Image _convertYUV420(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final img = image_lib.Image(width: width, height: height);

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = yPlane.bytes[yIndex];
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        // YUV to RGB conversion
        int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
        int g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
            .round()
            .clamp(0, 255);
        int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

        img.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return img;
  }

  static image_lib.Image _convertBGRA8888(CameraImage image) {
    final plane = image.planes[0];
    final width = image.width;
    final height = image.height;
    final img = image_lib.Image(width: width, height: height);

    final bytes = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * bytesPerRow + x * 4;
        final b = bytes[index];
        final g = bytes[index + 1];
        final r = bytes[index + 2];
        final a = bytes[index + 3];

        img.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return img;
  }

  /// Preprocess image for model input (resize to 224x224)
  static image_lib.Image preprocessForModel(
    image_lib.Image img, {
    int inputSize = 224,
  }) {
    return image_lib.copyResize(
      img,
      width: inputSize,
      height: inputSize,
      interpolation: image_lib.Interpolation.linear,
    );
  }
}
