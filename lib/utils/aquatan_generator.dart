import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AquatanGenerator {
  // Exact colors from the original JavaScript aquagen.js
  static const Map<String, List<int>> tmplColors = {
    '背景': [190, 179, 145],
    '帽子1': [6, 72, 39],
    '帽子2': [19, 84, 49],
    '帽子3': [24, 97, 61],
    '帽子4': [0, 126, 64],
    '帽子5': [18, 177, 108],
    '目1': [30, 142, 247],
    '目2': [94, 206, 247],
    '頬口手1': [247, 86, 30],
    '頬口手2': [255, 134, 78],
    '腹1': [231, 70, 14],
    '腹2': [247, 86, 30],
    '腹3': [255, 118, 62],
    '腹4': [255, 134, 78],
    '足1': [110, 78, 46],
    '足2': [142, 110, 78],
    '胴体1': [39, 42, 45],
    '胴体2': [55, 58, 61],
    '胴体3': [71, 74, 77],
    '胴体4': [87, 90, 93],
    '胴体5': [89, 98, 100],
    '胴体6': [103, 106, 109],
  };

  /// Generate default color map (keeps original colors)
  static Map<String, Color> generateColorsFromUsername(String username) {
    // Return original colors without any modification
    final colors = <String, Color>{};
    
    for (final entry in tmplColors.entries) {
      colors[entry.key] = Color.fromARGB(
        255,
        entry.value[0],
        entry.value[1],
        entry.value[2],
      );
    }
    
    return colors;
  }

  static int _toHex(List<int> rgb) {
    return (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
  }

  static Future<ui.Image> recolorAquatan(
    ui.Image baseImage,
    Map<String, Color> colorMap, {
    bool transparentBackground = true,
  }) async {
    final ByteData? byteData = await baseImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception('Failed to get image data');

    final Uint8List pixels = byteData.buffer.asUint8List();
    final Uint8List newPixels = Uint8List.fromList(pixels);

    // Only make background transparent if requested
    if (transparentBackground) {
      final bgKey = _toHex(tmplColors['背景']!);
      
      for (int i = 0; i < newPixels.length; i += 4) {
        final r = newPixels[i];
        final g = newPixels[i + 1];
        final b = newPixels[i + 2];
        final key = _toHex([r, g, b]);

        // Make background transparent
        if (key == bgKey) {
          newPixels[i + 3] = 0; // Set alpha to 0
        }
      }
    }

    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(newPixels);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: baseImage.width,
      height: baseImage.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}