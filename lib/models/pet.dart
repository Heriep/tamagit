enum PetMood {
  happy,
  neutral,
  sad,
  sleeping,
}

enum PetStage {
  egg,
  baby,
  teen,
  adult,
}

class Pet {
  String name;
  int hunger; // 0-100, 0 = starving, 100 = full
  int happiness; // 0-100
  int energy; // 0-100
  int age; // in days
  PetMood mood;
  PetStage stage;
  DateTime lastFed;
  DateTime lastInteraction;
  int totalCommits;
  int currentStreak;

  Pet({
    this.name = 'GitPet',
    this.hunger = 50,
    this.happiness = 50,
    this.energy = 100,
    this.age = 0,
    this.mood = PetMood.neutral,
    this.stage = PetStage.egg,
    DateTime? lastFed,
    DateTime? lastInteraction,
    this.totalCommits = 0,
    this.currentStreak = 0,
  })  : lastFed = lastFed ?? DateTime.now(),
        lastInteraction = lastInteraction ?? DateTime.now();

  // Calculate mood based on current stats
  PetMood calculateMood() {
    if (energy < 20) {
      return PetMood.sleeping;
    } else if (hunger < 30 || happiness < 30) {
      return PetMood.sad;
    } else if (hunger > 70 && happiness > 70) {
      return PetMood.happy;
    }
    return PetMood.neutral;
  }

  // Calculate stage based on age and total commits
  PetStage calculateStage() {
    if (totalCommits < 5) {
      return PetStage.egg;
    } else if (totalCommits < 20) {
      return PetStage.baby;
    } else if (totalCommits < 50) {
      return PetStage.teen;
    }
    return PetStage.adult;
  }

  // Feed the pet with commits
  void feed(int commitCount) {
    final foodValue = commitCount * 10;
    hunger = (hunger + foodValue).clamp(0, 100);
    happiness = (happiness + commitCount * 5).clamp(0, 100);
    energy = (energy + 5).clamp(0, 100);
    lastFed = DateTime.now();
    totalCommits += commitCount;
    
    mood = calculateMood();
    stage = calculateStage();
  }

  // Natural decay over time
  void decay() {
    final hoursSinceLastFed = DateTime.now().difference(lastFed).inHours;
    
    // Decay based on time passed
    hunger = (hunger - (hoursSinceLastFed * 2)).clamp(0, 100);
    happiness = (happiness - (hoursSinceLastFed * 1)).clamp(0, 100);
    energy = (energy - (hoursSinceLastFed * 3)).clamp(0, 100);
    
    mood = calculateMood();
    stage = calculateStage();
  }

  // Check if pet is alive
  bool get isAlive => hunger > 0 && happiness > 0;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'age': age,
      'mood': mood.index,
      'stage': stage.index,
      'lastFed': lastFed.toIso8601String(),
      'lastInteraction': lastInteraction.toIso8601String(),
      'totalCommits': totalCommits,
      'currentStreak': currentStreak,
    };
  }

  // Create from JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'] ?? 'GitPet',
      hunger: json['hunger'] ?? 50,
      happiness: json['happiness'] ?? 50,
      energy: json['energy'] ?? 100,
      age: json['age'] ?? 0,
      mood: PetMood.values[json['mood'] ?? 1],
      stage: PetStage.values[json['stage'] ?? 0],
      lastFed: DateTime.parse(json['lastFed']),
      lastInteraction: DateTime.parse(json['lastInteraction']),
      totalCommits: json['totalCommits'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
    );
  }
}