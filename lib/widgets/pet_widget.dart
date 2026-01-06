import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../providers/pet_provider.dart';
import '../utils/aquatan_generator.dart';
import '../models/aquatan.dart';
import '../services/aquatan_manager.dart';

class PetWidget extends StatefulWidget {
  const PetWidget({Key? key}) : super(key: key);

  @override
  State<PetWidget> createState() => _PetWidgetState();
}

class _PetWidgetState extends State<PetWidget> with SingleTickerProviderStateMixin {
  ui.Image? _customAquatan;
  int _currentFrame = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _currentFrame = (_currentFrame + 1) % 4;
        });
      });
    
    _generateCustomPet();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateCustomPet() async {
    final petProvider = context.read<PetProvider>();
    final state = petProvider.state;
    
    if (state == null) return;

    final ByteData data = await rootBundle.load('assets/images/aquatan_base.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image baseImage = frameInfo.image;

    final customImage = await AquatanGenerator.recolorAquatan(
      baseImage,
      state.colors,
      transparentBackground: true,
    );

    if (mounted) {
      setState(() {
        _customAquatan = customImage;
      });
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final manager = petProvider.aquatanManager;
        
        if (manager == null || _customAquatan == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final state = manager.state;
        final size = manager.displaySize * 64; // Base size 64

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(manager.moodIcon, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      manager.statusMessage,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Aquatan sprite
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: AquatanPainter(
                  image: _customAquatan!,
                  frame: _currentFrame,
                  pose: state.currentPose,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stats bars
            _buildStatsBar(context, manager),

            const SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(petProvider),
          ],
        );
      },
    );
  }

  Widget _buildStatsBar(BuildContext context, AquatanManager manager) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow('Health', manager.state.health, manager.healthColor),
          const SizedBox(height: 8),
          _buildStatRow('Energy', manager.state.energy, manager.energyColor),
          const SizedBox(height: 8),
          _buildStatRow('Happiness', manager.state.happiness, manager.happinessColor),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PetProvider petProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => petProvider.feed(),
          icon: const Icon(Icons.restaurant),
          label: const Text('Feed'),
        ),
        ElevatedButton.icon(
          onPressed: () => petProvider.play(),
          icon: const Icon(Icons.sports_esports),
          label: const Text('Play'),
        ),
        ElevatedButton.icon(
          onPressed: () => petProvider.rest(),
          icon: const Icon(Icons.bed),
          label: const Text('Rest'),
        ),
      ],
    );
  }
}

class AquatanPainter extends CustomPainter {
  final ui.Image image;
  final int frame;
  final AquatanPose pose;

  AquatanPainter({
    required this.image,
    required this.frame,
    required this.pose,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const spriteSize = 32.0;
    final srcRect = Rect.fromLTWH(
      frame * spriteSize,
      pose.row * spriteSize,
      spriteSize,
      spriteSize,
    );

    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final paint = Paint()
      ..filterQuality = FilterQuality.none;

    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(AquatanPainter oldDelegate) {
    return frame != oldDelegate.frame || pose != oldDelegate.pose;
  }
}