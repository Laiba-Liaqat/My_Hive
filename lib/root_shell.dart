import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

import 'apiary_screen.dart';
import 'home_screen.dart';
import 'mind_relax_screen.dart';
import 'settings_screen.dart';
import 'wallet_screen.dart'; // Added WalletScreen import

/// Hosts every top-level screen in a single [PageView] 
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  late final PageController _pageController = PageController();

  // Restored WalletScreen in the screen list
  final List<Widget> _screens = [
    HomeScreen(),
    ApiaryScreen(),
    MindRelaxScreen(),
    WalletScreen(), 
    SettingsScreen(),
  ];

  // Restored the Wallet icon in the navigation items
  static const _items = [
    (emoji: '⏳', label: 'Focus'),
    (emoji: '🐝', label: 'Apiary'),
    (emoji: '🌸', label: 'Relax'),
    (emoji: '💳', label: 'Wallet'),
    (emoji: '⚙️', label: 'Settings'),
  ];

  void _goTo(int i) {
    final settings = context.read<SettingsProvider>();
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: settings.motionDuration(const Duration(milliseconds: 420)),
      curve: settings.motionCurve,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _index = i),
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), 
                  blurRadius: 16, 
                  offset: const Offset(0, 6)
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < _items.length; i++)
                  _NavItem(
                    emoji: _items[i].emoji,
                    label: _items[i].label,
                    selected: _index == i,
                    onTap: () => _goTo(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.emoji, 
    required this.label, 
    required this.selected, 
    required this.onTap
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.watch<SettingsProvider>().reduceMotion;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.92,
        duration: reduceMotion 
            ? const Duration(milliseconds: 120) 
            : const Duration(milliseconds: 320),
        curve: reduceMotion ? Curves.linear : Curves.elasticOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: selected ? 20 : 17)),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? HiveColors.honeyAmber : HiveColors.wilted,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}