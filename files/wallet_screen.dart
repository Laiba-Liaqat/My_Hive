import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/customization_provider.dart';
import 'theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the total honey directly from your provider
    final customization = context.watch<CustomizationProvider>();
    final honeyAmount = customization.totalHoneyMl.toInt(); 

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Wallet', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
          const Text(
            'Your lifetime honey collection.',
            style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          
          // The Simple Lifetime Honey Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: HiveColors.honeyGold.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: HiveColors.honeyGold.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🍯', style: TextStyle(fontSize: 90)),
                const SizedBox(height: 24),
                const Text(
                  'Total Honey Earned',
                  style: TextStyle(
                    color: HiveColors.wilted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$honeyAmount ml',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: HiveColors.honeyDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}