import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../models/aquatan.dart';
import '../utils/game_constants.dart';
import 'aquatan_sprite.dart';

/// Complete pet display with sprite, decorations, badges, and mood indicator
class PetWidget extends StatelessWidget {
  const PetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final state = petProvider.state;
        
        if (state == null) {
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
                    child: const AquatanSprite(), // Using the pure sprite widget
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