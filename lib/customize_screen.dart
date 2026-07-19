import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/bee_species.dart';
import 'providers/customization_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/glass_container.dart';

/// Lets the user see and equip everything they've earned through
/// consistent focus — the endowed-progress payoff screen.
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomizationProvider>(
      builder: (context, custom, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Customize Your Hive')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                Text('Bee Species', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Unlocked by completing focus sessions.',
                  style: TextStyle(color: HiveColors.wilted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                for (final bee in BeeSpecies.all)
                  _UnlockTile(
                    emoji: bee.emoji,
                    name: bee.name,
                    description: bee.description,
                    unlocked: custom.isBeeUnlocked(bee),
                    active: custom.activeBeeId == bee.id,
                    requirementLabel: '${bee.unlockSessionsRequired} sessions',
                    onTap: () => custom.setActiveBee(bee),
                  ),
                const SizedBox(height: 28),
                Text('Flower Types', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'Unlocked by cumulative honey produced.',
                  style: TextStyle(color: HiveColors.wilted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                for (final flower in FlowerType.all)
                  _UnlockTile(
                    emoji: flower.emoji,
                    name: flower.name,
                    description: flower.description,
                    unlocked: custom.isFlowerUnlocked(flower),
                    active: custom.activeFlowerId == flower.id,
                    requirementLabel: '${flower.unlockTotalHoneyMl.toStringAsFixed(0)}ml honey',
                    onTap: () => custom.setActiveFlower(flower),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UnlockTile extends StatelessWidget {
  const _UnlockTile({
    required this.emoji,
    required this.name,
    required this.description,
    required this.unlocked,
    required this.active,
    required this.requirementLabel,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final String description;
  final bool unlocked;
  final bool active;
  final String requirementLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: unlocked ? onTap : null,
        child: GlassContainer(
          opacity: active ? 0.75 : 0.4,
          borderColor: active ? HiveColors.honeyGold : null,
          child: Row(
            children: [
              Opacity(
                opacity: unlocked ? 1 : 0.3,
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))),
                        if (active) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle, size: 16, color: HiveColors.honeyGold),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unlocked ? description : 'Locked — unlock with $requirementLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: unlocked ? HiveColors.wilted : HiveColors.wilted.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!unlocked) const Icon(Icons.lock_outline, size: 18, color: HiveColors.wilted),
            ],
          ),
        ),
      ),
    );
  }
}
