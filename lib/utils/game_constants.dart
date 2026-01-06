class GameConstants {
  // Stats bounds
  static const int minStat = 0;
  static const int maxStat = 100;
  
  // Stat decay rates (per hour)
  static const int healthDecayRate = 2;
  static const int happinessDecayRate = 1;
  static const int energyDecayRate = 3;
  
  // Action effects
  static const int feedHealthBoost = 20;
  static const int feedEnergyBoost = 15;
  static const int playHappinessBoost = 25;
  static const int playEnergyCost = 10;
  static const int restEnergyBoost = 30;
  
  // Commit rewards
  static const int commitHealthBoost = 2;
  static const int commitHappinessBoost = 5;
  
  // Growth thresholds
  static const int eggToBaby = 10;
  static const int babyToChild = 50;
  static const int childToTeen = 150;
  static const int teenToAdult = 500;
  static const int adultToElder = 1500;
  
  // Animation
  static const int baseAnimationInterval = 250;
  static const int minAnimationInterval = 100;
  static const int maxAnimationInterval = 1000;
  
  // Sprite dimensions
  static const double spriteSize = 32.0;
  static const double basePetSize = 64.0;
}