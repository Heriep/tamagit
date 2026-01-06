import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AquatanGenerator {
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

  /// Generate deterministic colors from username hash
  static Map<String, Color> generateColorsFromUsername(String username) {
    final hash = sha256.convert(utf8.encode(username)).toString();
    final colors = <String, Color>{};
    
    int hashIndex = 0;
    for (final entry in tmplColors.entries) {
      // Use 2 characters from hash for each RGB component (6 chars total per color)
      // Hash is 64 chars long, wrap around safely
      final rStart = (hashIndex) % 62;
      final gStart = (hashIndex + 2) % 62;
      final bStart = (hashIndex + 4) % 62;
      
      final r = int.parse(hash.substring(rStart, rStart + 2), radix: 16);
      final g = int.parse(hash.substring(gStart, gStart + 2), radix: 16);
      final b = int.parse(hash.substring(bStart, bStart + 2), radix: 16);
      
      colors[entry.key] = Color.fromARGB(255, r, g, b);
      hashIndex = (hashIndex + 6) % 62; // Move to next position, wrap around
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

    final replacementTable = <int, List<int>>{};
    for (final entry in tmplColors.entries) {
      final key = _toHex(entry.value);
      
      if (entry.key == '背景' && transparentBackground) {
        replacementTable[key] = [255, 255, 255, 0];
      } else {
        final color = colorMap[entry.key];
        if (color != null) {
          replacementTable[key] = [color.red, color.green, color.blue, color.alpha];
        }
      }
    }

    for (int i = 0; i < newPixels.length; i += 4) {
      final r = newPixels[i];
      final g = newPixels[i + 1];
      final b = newPixels[i + 2];
      final key = _toHex([r, g, b]);

      if (replacementTable.containsKey(key)) {
        final replacement = replacementTable[key]!;
        newPixels[i] = replacement[0];
        newPixels[i + 1] = replacement[1];
        newPixels[i + 2] = replacement[2];
        newPixels[i + 3] = replacement[3];
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