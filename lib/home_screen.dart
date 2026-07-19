import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth
import 'auth_screen.dart'; // Added Auth Screen import

import 'providers/customization_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/hive_progress_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HiveSessionState? _lastState;
  bool _resultSheetOpen = false;

  // Added your Firebase Logout function here
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _handleStateTransition(BuildContext context, FocusProvider focus) {
    final settings = context.read<SettingsProvider>();
    final audio = context.read<AudioService>();
    final previous = _lastState;
    _lastState = focus.state;
    if (previous == focus.state) return;

    switch (focus.state) {
      case HiveSessionState.running:
        if (previous == HiveSessionState.idle) {
          if (settings.soundEffects) audio.playTap();
          if (settings.focusMusic) audio.startFocusMusic(volume: settings.musicVolume);
          HapticFeedback.lightImpact();
        }
        break;
      case HiveSessionState.distracted:
        if (settings.soundEffects) audio.playNotification();
        HapticFeedback.heavyImpact();
        break;
      case HiveSessionState.completed:
        if (settings.soundEffects) {
          audio.playHoneyDrop();
          Future.delayed(const Duration(milliseconds: 250), audio.playSuccess);
        }
        if (settings.focusMusic) audio.stopFocusMusic();
        HapticFeedback.mediumImpact();
        if (!_resultSheetOpen) _showResultSheet(context, focus, success: true);
        break;
      case HiveSessionState.failed:
        if (settings.soundEffects) audio.playFail();
        if (settings.focusMusic) audio.stopFocusMusic();
        HapticFeedback.mediumImpact();
        if (!_resultSheetOpen) _showResultSheet(context, focus, success: false);
        break;
      case HiveSessionState.idle:
      case HiveSessionState.paused:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final custom = context.watch<CustomizationProvider>();

    return Consumer<FocusProvider>(
      builder: (context, focus, _) {
        if (!focus.loaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _handleStateTransition(context, focus);
        });

        // Wrapped in a Scaffold to ensure proper background color and material styling
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Passed the logout function into the header
                            _Header(onLogout: () => _logout(context)),
                            const SizedBox(height: 8),
                            Center(child: _buildHive(context, focus, settings, custom)),
                            const SizedBox(height: 20),
                            if (focus.state == HiveSessionState.idle) _DurationPicker(focus: focus),
                            if (focus.state == HiveSessionState.distracted) ...[
                              const SizedBox(height: 16),
                              const _DistractionWarning(),
                            ],
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: _buildControls(context, focus),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHive(
    BuildContext context,
    FocusProvider focus,
    SettingsProvider settings,
    CustomizationProvider custom,
  ) {
    final isActive = focus.state == HiveSessionState.running;
    String center;
    String sub;
    switch (focus.state) {
      case HiveSessionState.idle:
        center = '${focus.plannedMinutes}:00';
        sub = 'Ready to focus';
        break;
      case HiveSessionState.running:
        center = formatClock(focus.remainingSeconds);
        sub = 'Bees are collecting honey';
        break;
      case HiveSessionState.paused:
        center = formatClock(focus.remainingSeconds);
        sub = 'Paused — the hive waits';
        break;
      case HiveSessionState.distracted:
        center = formatClock(focus.remainingSeconds);
        sub = 'Colony in danger — come back!';
        break;
      default:
        center = formatClock(focus.remainingSeconds);
        sub = '';
    }

    return HiveProgressWidget(
      progress: focus.progress,
      colonyHealth: focus.colonyHealth,
      isActive: isActive,
      centerLabel: center,
      subLabel: sub,
      beeEmoji: custom.activeBee.emoji,
      flowerEmoji: custom.activeFlower.emoji,
      reduceMotion: settings.reduceMotion,
    );
  }

  Widget _buildControls(BuildContext context, FocusProvider focus) {
    final settings = context.read<SettingsProvider>();
    final audio = context.read<AudioService>();
    void tap() {
      if (settings.soundEffects) audio.playTap();
    }

    switch (focus.state) {
      case HiveSessionState.idle:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              tap();
              focus.startSession();
            },
            icon: const Text('🐝'),
            label: const Text('Start Focus Session'),
          ),
        );
      case HiveSessionState.running:
      case HiveSessionState.distracted:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: focus.state == HiveSessionState.running
                    ? () {
                        tap();
                        focus.pauseSession();
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  side: const BorderSide(color: HiveColors.honeyAmber),
                ),
                child: const Text('Pause'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmGiveUp(context, focus),
                style: ElevatedButton.styleFrom(backgroundColor: HiveColors.danger),
                child: const Text('Give Up'),
              ),
            ),
          ],
        );
      case HiveSessionState.paused:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  tap();
                  focus.resumeSession();
                },
                child: const Text('Resume'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _confirmGiveUp(context, focus),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  side: const BorderSide(color: HiveColors.danger),
                ),
                child: const Text('Give Up', style: TextStyle(color: HiveColors.danger)),
              ),
            ),
          ],
        );
      default:
        return const SizedBox(height: 56);
    }
  }

  void _confirmGiveUp(BuildContext context, FocusProvider focus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Abandon this batch?'),
        content: const Text(
          'Leaving now will collapse the colony and this session will be lost. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Going')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              focus.giveUp();
            },
            child: const Text('Give Up', style: TextStyle(color: HiveColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showResultSheet(BuildContext context, FocusProvider focus, {required bool success}) {
    _resultSheetOpen = true;
    final previousCompleted = focus.completedSessions.length - (success ? 1 : 0);
    final previousHoney = focus.totalHoneyMl - (success && focus.sessions.isNotEmpty ? focus.sessions.first.honeyMl : 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResultSheet(
        success: success,
        focus: focus,
        previousCompletedSessions: previousCompleted,
        previousHoneyMl: previousHoney,
      ),
    ).then((_) {
      _resultSheetOpen = false;
      focus.acknowledgeResult();
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onLogout});
  
  final VoidCallback onLogout; // Added callback to accept the logout function

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hive Focus', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
            Text(
              'Stay in the hive. Let the honey flow.',
              style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            const Text('🍯', style: TextStyle(fontSize: 30)),
            // Integrated the logout button seamlessly into their header
            IconButton(
              icon: const Icon(Icons.logout, color: HiveColors.waxBrown),
              onPressed: onLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your focus length', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final m in AppConstants.presetMinutes) ...[
              Expanded(child: _PresetChip(minutes: m, focus: focus)),
              const SizedBox(width: 10),
            ],
            Expanded(child: _CustomChip(focus: focus)),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.minutes, required this.focus});
  final int minutes;
  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    final selected = focus.plannedMinutes == minutes;
    return GestureDetector(
      onTap: () => focus.setPlannedMinutes(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? HiveColors.honeyGold : HiveColors.combCream.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? HiveColors.honeyDeep : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : HiveColors.waxBrown,
          ),
        ),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  const _CustomChip({required this.focus});
  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    final isCustom = !AppConstants.presetMinutes.contains(focus.plannedMinutes);
    return GestureDetector(
      onTap: () => _openCustomPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCustom ? HiveColors.honeyGold : HiveColors.combCream.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCustom ? HiveColors.honeyDeep : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          isCustom ? '${focus.plannedMinutes}m' : 'Custom',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isCustom ? Colors.white : HiveColors.waxBrown,
          ),
        ),
      ),
    );
  }

  void _openCustomPicker(BuildContext context) {
    int value = focus.plannedMinutes;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Custom duration', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('$value minutes', style: Theme.of(ctx).textTheme.displayLarge?.copyWith(fontSize: 30)),
                Slider(
                  value: value.toDouble(),
                  min: AppConstants.minCustomMinutes.toDouble(),
                  max: AppConstants.maxCustomMinutes.toDouble(),
                  divisions: (AppConstants.maxCustomMinutes - AppConstants.minCustomMinutes) ~/ 5,
                  activeColor: HiveColors.honeyGold,
                  onChanged: (v) => setState(() => value = v.round()),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      focus.setPlannedMinutes(value);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Set Duration'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DistractionWarning extends StatelessWidget {
  const _DistractionWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HiveColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text('⚠️', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You left the hive! Return immediately or the colony will collapse.',
              style: TextStyle(color: HiveColors.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSheet extends StatefulWidget {
  const _ResultSheet({
    required this.success,
    required this.focus,
    required this.previousCompletedSessions,
    required this.previousHoneyMl,
  });

  final bool success;
  final FocusProvider focus;
  final int previousCompletedSessions;
  final double previousHoneyMl;

  @override
  State<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<_ResultSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _capController;

  @override
  void initState() {
    super.initState();
    _capController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _capController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focus = widget.focus;
    final success = widget.success;
    final session = focus.sessions.isNotEmpty ? focus.sessions.first : null;
    final custom = context.watch<CustomizationProvider>();
    final newBees = success ? custom.newlyUnlockedBees(widget.previousCompletedSessions) : const [];
    final newFlowers = success ? custom.newlyUnlockedFlowers(widget.previousHoneyMl) : const [];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (success)
                  AnimatedBuilder(
                    animation: _capController,
                    builder: (context, child) {
                      final drop = Curves.easeIn.transform((_capController.value).clamp(0, 0.5) * 2);
                      final settle = Curves.elasticOut.transform(
                        ((_capController.value - 0.5).clamp(0, 0.5) * 2),
                      );
                      return Transform.translate(
                        offset: Offset(0, -20 + drop * 20 + (1 - settle) * 4),
                        child: Opacity(opacity: (_capController.value * 2).clamp(0, 1), child: child),
                      );
                    },
                    child: const Text('🍯', style: TextStyle(fontSize: 64)),
                  )
                else
                  const Text('🥀', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  success ? 'Batch Complete!' : 'Colony Collapsed',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  success
                      ? 'Your bees filled a fresh honeycomb. Great focus!'
                      : 'The hive lost momentum this time. Every batch teaches the colony something.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600),
                ),
                if (session != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HiveColors.combCream.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ResultStat(label: 'Honey', value: formatHoney(session.honeyMl)),
                        _ResultStat(label: 'Duration', value: formatDuration(session.actualDuration)),
                      ],
                    ),
                  ),
                ],
                if (newBees.isNotEmpty || newFlowers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [HiveColors.honeyGold, HiveColors.honeyDeep]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎉 New unlock!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        for (final b in newBees)
                          Text('${b.emoji} ${b.name} bee species', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        for (final f in newFlowers)
                          Text('${f.emoji} ${f.name} flower type', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(success ? 'Back to the Hive' : 'Try Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: TextStyle(color: HiveColors.wilted, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
class SimpleHoneyStatCard extends StatelessWidget {
  const SimpleHoneyStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the total honey directly from your customization provider
    final customization = context.watch<CustomizationProvider>();
    final honeyAmount = customization.totalHoneyMl.toInt(); 

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? const Color(0xFFFDF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HiveColors.honeyGold.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: HiveColors.honeyGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lifetime Honey',
                style: TextStyle(
                  color: HiveColors.wilted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$honeyAmount ml',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: HiveColors.honeyDeep,
                ),
              ),
            ],
          ),
          const Text('🍯', style: TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}