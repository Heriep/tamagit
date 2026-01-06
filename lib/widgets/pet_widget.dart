import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../providers/pet_provider.dart';
import '../utils/aquatan_generator.dart';
import '../models/aquatan.dart';
import '../utils/game_constants.dart';

class PetWidget extends StatefulWidget {
  const PetWidget({Key? key}) : super(key: key);

  @override
  State<PetWidget> createState() => _PetWidgetState();
}

class _PetWidgetState extends State<PetWidget> with SingleTickerProviderStateMixin {
  ui.Image? _customAquatan;
  int _currentFrame = 0;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _generateCustomPet();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: GameConstants.baseAnimationInterval),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _currentFrame = (_currentFrame + 1) % 4; // 4 frames per animation
          });
        }
      });
    
    _animationController.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimationSpeed();
  }

  void _updateAnimationSpeed() {
    final petProvider = context.watch<PetProvider>();
    final state = petProvider.state;
    
    if (state != null) {
      // Adjust animation speed based on energy and growth stage
      final energyFactor = (state.energy / 100).clamp(0.3, 1.0);
      final stageFactor = state.growthStage.animationSpeed;
      
      final duration = Duration(
        milliseconds: (GameConstants.baseAnimationInterval / (energyFactor * stageFactor))
            .round()
            .clamp(GameConstants.minAnimationInterval, GameConstants.maxAnimationInterval),
      );
      
      if (_animationController.duration != duration) {
        _animationController.duration = duration;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateCustomPet() async {
    try {
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
      }
    } catch (e) {
      debugPrint('Error generating custom pet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final state = petProvider.state;
        
        if (state == null || _customAquatan == null) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Hatching your Aquatan...'),
                ],
              ),
            ),
          );
        }

        final displaySize = GameConstants.basePetSize * state.growthStage.size;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue[50]!,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Growth stage badge
              _buildGrowthStageBadge(state.growthStage),
              
              const SizedBox(height: 16),

              // Aquatan sprite with animation
              Container(
                width: displaySize + 32,
                height: displaySize + 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getMoodColor(state.mood).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: displaySize,
                    height: displaySize,
                    child: CustomPaint(
                      painter: AquatanPainter(
                        image: _customAquatan!,
                        frame: _currentFrame,
                        pose: state.currentPose,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Mood indicator
              _buildMoodIndicator(state.mood),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrowthStageBadge(AquatanGrowthStage stage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple[400]!,
            Colors.purple[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStageIcon(stage),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            stage.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator(AquatanMood mood) {
    final color = _getMoodColor(mood);
    final icon = _getMoodIcon(mood);
    final text = _getMoodText(mood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStageIcon(AquatanGrowthStage stage) {
    switch (stage) {
      case AquatanGrowthStage.egg:
        return Icons.egg;
      case AquatanGrowthStage.baby:
        return Icons.child_care;
      case AquatanGrowthStage.child:
        return Icons.face;
      case AquatanGrowthStage.teen:
        return Icons.sentiment_very_satisfied;
      case AquatanGrowthStage.adult:
        return Icons.star;
      case AquatanGrowthStage.elder:
        return Icons.workspace_premium;
    }
  }

  IconData _getMoodIcon(AquatanMood mood) {
    switch (mood) {
      case AquatanMood.happy:
        return Icons.sentiment_very_satisfied;
      case AquatanMood.excited:
        return Icons.celebration;
      case AquatanMood.sad:
        return Icons.sentiment_dissatisfied;
      case AquatanMood.tired:
        return Icons.battery_2_bar;
      case AquatanMood.sick:
        return Icons.sick;
      case AquatanMood.sleeping:
        return Icons.bedtime;
    }
  }

  String _getMoodText(AquatanMood mood) {
    switch (mood) {
      case AquatanMood.happy:
        return "Feeling great!";
      case AquatanMood.excited:
        return "Super excited!";
      case AquatanMood.sad:
        return "Feeling lonely...";
      case AquatanMood.tired:
        return "So tired...";
      case AquatanMood.sick:
        return "Not feeling well...";
      case AquatanMood.sleeping:
        return "Zzz...";
    }
  }

  Color _getMoodColor(AquatanMood mood) {
    switch (mood) {
      case AquatanMood.happy:
        return Colors.green;
      case AquatanMood.excited:
        return Colors.orange;
      case AquatanMood.sad:
        return Colors.blue;
      case AquatanMood.tired:
        return Colors.grey;
      case AquatanMood.sick:
        return Colors.red;
      case AquatanMood.sleeping:
        return Colors.indigo;
    }
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
    const spriteSize = GameConstants.spriteSize;
    
    // Source rectangle from sprite sheet
    final srcRect = Rect.fromLTWH(
      frame * spriteSize,
      pose.row * spriteSize,
      spriteSize,
      spriteSize,
    );

    // Destination rectangle (scaled to widget size)
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Paint with pixel-perfect rendering (no smoothing for pixel art)
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(AquatanPainter oldDelegate) {
    return frame != oldDelegate.frame || 
           pose != oldDelegate.pose ||
           image != oldDelegate.image;
  }
}