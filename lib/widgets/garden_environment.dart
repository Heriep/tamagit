import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/pet_provider.dart';
import '../models/aquatan.dart';
import '../utils/game_constants.dart';
import 'aquatan_sprite.dart';

class GardenEnvironment extends StatefulWidget {
  const GardenEnvironment({Key? key}) : super(key: key);

  @override
  State<GardenEnvironment> createState() => _GardenEnvironmentState();
}

class _GardenEnvironmentState extends State<GardenEnvironment> with SingleTickerProviderStateMixin {
  Offset _petPosition = const Offset(0.5, 0.5);
  Offset _targetPosition = const Offset(0.5, 0.5);
  late AnimationController _movementController;
  final Random _random = Random();
  AquatanPose? _lastSetPose;
  
  @override
  void initState() {
    super.initState();
    _setupMovement();
  }

  void _setupMovement() {
    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _moveToRandomPosition();
        });
      }
    });
    
    _moveToRandomPosition();
  }

  void _moveToRandomPosition() {
    final petProvider = context.read<PetProvider>();
    final state = petProvider.state;
    
    if (state == null) return;

    // Don't move if sleeping or sick
    if (state.mood == AquatanMood.sleeping || state.mood == AquatanMood.sick) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) _moveToRandomPosition();
      });
      return;
    }

    // Random movement range based on energy
    final energyFactor = (state.energy / 100).clamp(0.2, 1.0);
    final maxMovement = 0.4 * energyFactor;

    final oldPosition = _petPosition;
    final newPosition = Offset(
      (_petPosition.dx + (_random.nextDouble() - 0.5) * maxMovement).clamp(0.15, 0.85),
      (_petPosition.dy + (_random.nextDouble() - 0.5) * maxMovement).clamp(0.15, 0.85),
    );

    setState(() {
      _targetPosition = newPosition;
    });

    // Update pose based on movement direction
    _updatePoseFromMovement(oldPosition, newPosition);

    _movementController.reset();
    _movementController.forward();
  }

  void _updatePoseFromMovement(Offset from, Offset to) {
    final petProvider = context.read<PetProvider>();
    final state = petProvider.state;
    
    if (state == null) return;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;

    AquatanPose newPose;
    
    // Determine direction based on dominant movement axis
    if (dx.abs() > dy.abs()) {
      // Horizontal movement is dominant
      newPose = dx > 0 ? AquatanPose.walkingRight : AquatanPose.walkingLeft;
    } else {
      // Vertical movement is dominant
      newPose = dy > 0 ? AquatanPose.walkingFront : AquatanPose.walkingBack;
    }

    // Only update if pose actually changed
    if (newPose != _lastSetPose) {
      debugPrint('🎮 Garden: Moving ${newPose.name} (dx: ${dx.toStringAsFixed(2)}, dy: ${dy.toStringAsFixed(2)})');
      _lastSetPose = newPose;
      
      // Force update the state
      final newState = state.copyWith(currentPose: newPose);
      petProvider.setState(newState);
    }
  }

  @override
  void dispose() {
    _movementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final state = petProvider.state;
        
        if (state == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue[100]!,
                Colors.green[200]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green[700]!, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Garden decorations
                    ..._buildGardenDecorations(constraints),

                    // Shadow
                    AnimatedBuilder(
                      animation: _movementController,
                      builder: (context, child) {
                        final currentPos = Offset.lerp(_petPosition, _targetPosition, _movementController.value)!;
                        final displaySize = GameConstants.basePetSize * state.growthStage.size;
                        
                        // Scale shadow based on Aquatan's size
                        final shadowWidth = displaySize * 0.8;
                        final shadowHeight = displaySize * 0.25;
                        // Shadow offset below the sprite
                        final shadowYOffset = displaySize * 0.4;
                        
                        return Positioned(
                          left: constraints.maxWidth * currentPos.dx - shadowWidth / 2,
                          top: constraints.maxHeight * currentPos.dy + shadowYOffset,
                          child: Container(
                            width: shadowWidth,
                            height: shadowHeight,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(shadowWidth / 2),
                            ),
                          ),
                        );
                      },
                    ),

                    // Aquatan sprite
                    AnimatedBuilder(
                      animation: _movementController,
                      builder: (context, child) {
                        final currentPos = Offset.lerp(_petPosition, _targetPosition, _movementController.value)!;
                        
                        // Update actual position for next movement
                        if (_movementController.isCompleted) {
                          _petPosition = _targetPosition;
                        }
                        
                        final displaySize = GameConstants.basePetSize * state.growthStage.size;
                        
                        return Positioned(
                          left: constraints.maxWidth * currentPos.dx - displaySize / 2,
                          top: constraints.maxHeight * currentPos.dy - displaySize / 2,
                          child: SizedBox(
                            width: displaySize,
                            height: displaySize,
                            child: const AquatanSprite(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGardenDecorations(BoxConstraints constraints) {
    return [
      // Sky elements
      Positioned(
        right: 40,
        top: 30,
        child: _buildCloud(),
      ),
      Positioned(
        left: 60,
        top: 50,
        child: _buildCloud(),
      ),
      
      // Grass patches
      Positioned(
        left: 20,
        bottom: 30,
        child: _buildGrass(),
      ),
      Positioned(
        right: 40,
        bottom: 50,
        child: _buildGrass(),
      ),
      Positioned(
        left: constraints.maxWidth * 0.4,
        bottom: 20,
        child: _buildGrass(),
      ),
      Positioned(
        left: constraints.maxWidth * 0.7,
        bottom: 40,
        child: _buildGrass(),
      ),

      // Flowers
      Positioned(
        left: 50,
        top: 120,
        child: _buildFlower(Colors.red),
      ),
      Positioned(
        right: 80,
        top: 150,
        child: _buildFlower(Colors.yellow),
      ),
      Positioned(
        left: constraints.maxWidth * 0.6,
        top: 180,
        child: _buildFlower(Colors.pink),
      ),
      Positioned(
        left: constraints.maxWidth * 0.3,
        bottom: 80,
        child: _buildFlower(Colors.purple),
      ),

      // Trees/bushes in background
      Positioned(
        left: 10,
        top: 10,
        child: _buildTree(),
      ),
      Positioned(
        right: 10,
        top: 30,
        child: _buildTree(),
      ),
      Positioned(
        left: constraints.maxWidth * 0.5 - 20,
        top: 20,
        child: _buildBush(),
      ),
    ];
  }

  Widget _buildCloud() {
    return Opacity(
      opacity: 0.6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            width: 25,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Container(
            width: 20,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrass() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Container(
          width: 3,
          height: 10 + _random.nextInt(8).toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Colors.green[800],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
      ),
    );
  }

  Widget _buildFlower(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildTree() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green[900],
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 10,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.brown[800],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildBush() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}