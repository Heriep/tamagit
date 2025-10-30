import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../utils/constants.dart';

class PetWidget extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;

  const PetWidget({
    super.key,
    required this.pet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppConstants.petWidgetSize,
        height: AppConstants.petWidgetSize,
        decoration: BoxDecoration(
          color: _getMoodColor(),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getStageEmoji(),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 8),
            Text(
              _getMoodEmoji(),
              style: const TextStyle(fontSize: 40),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor() {
    switch (pet.mood) {
      case PetMood.happy:
        return AppConstants.happyColor.withOpacity(0.3);
      case PetMood.sad:
        return AppConstants.sadColor.withOpacity(0.3);
      case PetMood.sleeping:
        return AppConstants.sleepingColor.withOpacity(0.3);
      case PetMood.neutral:
        return AppConstants.neutralColor.withOpacity(0.3);
    }
  }

  String _getStageEmoji() {
    switch (pet.stage) {
      case PetStage.egg:
        return AppConstants.stageEmojis['egg']!;
      case PetStage.baby:
        return AppConstants.stageEmojis['baby']!;
      case PetStage.teen:
        return AppConstants.stageEmojis['teen']!;
      case PetStage.adult:
        return AppConstants.stageEmojis['adult']!;
    }
  }

  String _getMoodEmoji() {
    switch (pet.mood) {
      case PetMood.happy:
        return AppConstants.moodEmojis['happy']!;
      case PetMood.sad:
        return AppConstants.moodEmojis['sad']!;
      case PetMood.sleeping:
        return AppConstants.moodEmojis['sleeping']!;
      case PetMood.neutral:
        return AppConstants.moodEmojis['neutral']!;
    }
  }
}