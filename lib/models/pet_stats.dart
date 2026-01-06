import '../utils/game_constants.dart';

class PetStats {
  final int health;
  final int happiness;
  final int energy;

  const PetStats({
    required this.health,
    required this.happiness,
    required this.energy,
  });

  factory PetStats.initial() {
    return const PetStats(
      health: GameConstants.maxStat,
      happiness: GameConstants.maxStat,
      energy: GameConstants.maxStat,
    );
  }

  PetStats copyWith({
    int? health,
    int? happiness,
    int? energy,
  }) {
    return PetStats(
      health: _clampStat(health ?? this.health),
      happiness: _clampStat(happiness ?? this.happiness),
      energy: _clampStat(energy ?? this.energy),
    );
  }

  static int _clampStat(int value) {
    return value.clamp(GameConstants.minStat, GameConstants.maxStat);
  }

  PetStats applyDecay(Duration timePassed) {
    final hours = timePassed.inHours;
    return copyWith(
      health: health - (hours * GameConstants.healthDecayRate),
      happiness: happiness - (hours * GameConstants.happinessDecayRate),
      energy: energy - (hours * GameConstants.energyDecayRate),
    );
  }

  PetStats feed() {
    return copyWith(
      health: health + GameConstants.feedHealthBoost,
      energy: energy + GameConstants.feedEnergyBoost,
    );
  }

  PetStats play() {
    return copyWith(
      happiness: happiness + GameConstants.playHappinessBoost,
      energy: energy - GameConstants.playEnergyCost,
    );
  }

  PetStats rest() {
    return copyWith(
      energy: energy + GameConstants.restEnergyBoost,
    );
  }

  PetStats receiveCommitReward(int commitCount) {
    return copyWith(
      health: health + (commitCount * GameConstants.commitHealthBoost),
      happiness: happiness + (commitCount * GameConstants.commitHappinessBoost),
    );
  }

  Map<String, dynamic> toJson() => {
    'health': health,
    'happiness': happiness,
    'energy': energy,
  };

  factory PetStats.fromJson(Map<String, dynamic> json) {
    return PetStats(
      health: json['health'] ?? GameConstants.maxStat,
      happiness: json['happiness'] ?? GameConstants.maxStat,
      energy: json['energy'] ?? GameConstants.maxStat,
    );
  }
}