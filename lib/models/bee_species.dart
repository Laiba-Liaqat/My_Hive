/// Unlockable "bee species" — cosmetic personalization that leverages the
/// endowed progress effect: users invest focus time and are rewarded with
/// a growing, personal collection rather than a single static hive.
class BeeSpecies {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int unlockSessionsRequired; // completed sessions needed

  const BeeSpecies({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.unlockSessionsRequired,
  });

  static const List<BeeSpecies> all = [
    BeeSpecies(
      id: 'honeybee',
      name: 'Honeybee',
      emoji: '🐝',
      description: 'The classic worker. Steady, reliable, always buzzing.',
      unlockSessionsRequired: 0,
    ),
    BeeSpecies(
      id: 'bumblebee',
      name: 'Bumblebee',
      emoji: '🐝',
      description: 'Bigger, fuzzier, and surprisingly fast in short bursts.',
      unlockSessionsRequired: 5,
    ),
    BeeSpecies(
      id: 'carpenter',
      name: 'Carpenter Bee',
      emoji: '🪵',
      description: 'A solitary builder who thrives on long, deep sessions.',
      unlockSessionsRequired: 15,
    ),
    BeeSpecies(
      id: 'golden',
      name: 'Golden Queen',
      emoji: '👑',
      description: 'Unlocked only by the most consistent hives. Rare and radiant.',
      unlockSessionsRequired: 40,
    ),
  ];
}

/// Unlockable flower/nectar sources — change the honey jar hue palette
/// and the flavor text shown across the apiary.
class FlowerType {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int unlockTotalHoneyMl; // cumulative honey required

  const FlowerType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.unlockTotalHoneyMl,
  });

  static const List<FlowerType> all = [
    FlowerType(
      id: 'clover',
      name: 'Clover',
      emoji: '🍀',
      description: 'Light, everyday nectar. A gentle place to start.',
      unlockTotalHoneyMl: 0,
    ),
    FlowerType(
      id: 'lavender',
      name: 'Lavender',
      emoji: '💜',
      description: 'Calming and floral — favored by evening focusers.',
      unlockTotalHoneyMl: 150,
    ),
    FlowerType(
      id: 'wildflower',
      name: 'Wildflower Meadow',
      emoji: '🌼',
      description: 'A rich, varied blend earned through consistency.',
      unlockTotalHoneyMl: 500,
    ),
    FlowerType(
      id: 'orangeblossom',
      name: 'Orange Blossom',
      emoji: '🍊',
      description: 'Bright and prized — only the most dedicated hives reach it.',
      unlockTotalHoneyMl: 1200,
    ),
  ];
}
