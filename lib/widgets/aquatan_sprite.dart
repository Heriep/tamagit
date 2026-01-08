import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../providers/pet_provider.dart';
import '../utils/aquatan_generator.dart';
import '../models/aquatan.dart';
import '../utils/game_constants.dart';

/// Pure sprite renderer - just displays the animated Aquatan character
class AquatanSprite extends StatefulWidget {
  const AquatanSprite({Key? key}) : super(key: key);

  @override
  State<AquatanSprite> createState() => _AquatanSpriteState();
}

class _AquatanSpriteState extends State<AquatanSprite> with SingleTickerProviderStateMixin {
  ui.Image? _customAquatan;
  int _currentFrame = 0;
  late AnimationController _animationController;
  late Animation<int> _frameAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _generateCustomPet();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: GameConstants.baseAnimationInterval * 4),
    );

    _frameAnimation = IntTween(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    )..addListener(() {
        if (mounted && _frameAnimation.value != _currentFrame) {
          setState(() {
            _currentFrame = _frameAnimation.value;
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
      final energyFactor = (state.energy / 100).clamp(0.3, 1.0);
      final stageFactor = state.growthStage.animationSpeed;
      
      final duration = Duration(
        milliseconds: ((GameConstants.baseAnimationInterval * 4) / (energyFactor * stageFactor))
            .round()
            .clamp(GameConstants.minAnimationInterval * 4, GameConstants.maxAnimationInterval * 4),
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
          return const SizedBox.shrink();
        }

        return CustomPaint(
          painter: AquatanPainter(
            image: _customAquatan!,
            frame: _currentFrame,
            pose: state.currentPose,
          ),
        );
      },
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
    const spriteSize = GameConstants.spriteSize;
    
    final srcRect = Rect.fromLTWH(
      frame * spriteSize,
      pose.row * spriteSize,
      spriteSize,
      spriteSize,
    );

    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
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