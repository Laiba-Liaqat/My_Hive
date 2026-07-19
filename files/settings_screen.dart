import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'customize_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, FocusProvider, SettingsProvider>(
      builder: (context, themeProvider, focus, settings, _) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text('Settings', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
              const SizedBox(height: 20),

              _SectionCard(
                title: 'Appearance',
                children: [
                  _ThemeOption(
                    label: 'Light Mode', icon: '☀️',
                    selected: themeProvider.mode == ThemeMode.light,
                    onTap: () => themeProvider.setMode(ThemeMode.light),
                  ),
                  _ThemeOption(
                    label: 'Dark Mode', icon: '🌙',
                    selected: themeProvider.mode == ThemeMode.dark,
                    onTap: () => themeProvider.setMode(ThemeMode.dark),
                  ),
                  _ThemeOption(
                    label: 'System Default', icon: '⚙️',
                    selected: themeProvider.mode == ThemeMode.system,
                    onTap: () => themeProvider.setMode(ThemeMode.system),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionCard(
                title: 'Customization',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Text('🐝', style: TextStyle(fontSize: 22)),
                    title: const Text('Bee Species & Flowers', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Unlocked through consistent focus'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CustomizeScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionCard(
                title: 'Sound',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: HiveColors.honeyGold,
                    value: settings.soundEffects,
                    onChanged: settings.setSoundEffects,
                    title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Taps, honey drips, success & fail chimes'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: HiveColors.honeyGold,
                    value: settings.focusMusic,
                    onChanged: (v) {
                      settings.setFocusMusic(v);
                      final audio = context.read<AudioService>();
                      if (!v) audio.stopFocusMusic();
                    },
                    title: const Text('Focus Music', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Soft ambient hum during active sessions'),
                  ),
                  if (settings.focusMusic) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('🔈', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: settings.musicVolume,
                            activeColor: HiveColors.honeyGold,
                            onChanged: (v) {
                              settings.setMusicVolume(v);
                              context.read<AudioService>().setMusicVolume(v);
                            },
                          ),
                        ),
                        const Text('🔊', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),
              _SectionCard(
                title: 'Bee Alerts',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: HiveColors.honeyGold,
                    value: settings.smartNudges,
                    onChanged: settings.setSmartNudges,
                    title: const Text('Smart Nudges', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Personalized reminders based on today\'s progress'),
                  ),
                  if (settings.smartNudges)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final notif = context.read<NotificationService>();
                            await notif.init();
                            await notif.sendSmartNudge(
                              todaysSessions: focus.sessions
                                  .where((s) => _isToday(s.startTime))
                                  .toList(),
                              currentStreak: focus.currentStreak,
                            );
                          } catch (e) {
                            // flutter_local_notifications has no web
                            // implementation yet, so this is expected to
                            // fail on Chrome — fail quietly instead of
                            // crashing the screen.
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Notifications aren\'t supported in the browser yet — try this on Android/iOS.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Preview a nudge'),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionCard(
                title: 'Accessibility',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: HiveColors.honeyGold,
                    value: settings.reduceMotion,
                    onChanged: settings.setReduceMotion,
                    title: const Text('Reduce Motion', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Calmer, near-instant transitions and fewer moving elements'),
                  ),
                  const SizedBox(height: 8),
                  Text('Text Size', style: TextStyle(fontWeight: FontWeight.w700, color: HiveColors.waxBrown)),
                  Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: settings.textScale,
                          min: 0.85,
                          max: 1.3,
                          divisions: 9,
                          activeColor: HiveColors.honeyGold,
                          onChanged: settings.setTextScale,
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionCard(
                title: 'About Hive Focus',
                children: [
                  const _InfoRow(label: 'Version', value: '2.0.0'),
                  _InfoRow(label: 'Sessions Logged', value: '${focus.sessions.length}'),
                  const _InfoRow(label: 'Concept', value: 'Focus builds honey. Distraction wilts the hive.'),
                ],
              ),

              const SizedBox(height: 20),
              _SectionCard(
                title: 'Danger Zone',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Reset all history', style: TextStyle(color: HiveColors.danger, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Clears every session and honey jar. Cannot be undone.'),
                    onTap: () => _confirmReset(context, focus),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _confirmReset(BuildContext context, FocusProvider focus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset all history?'),
        content: const Text('This will permanently delete every focus session and honey jar you\'ve earned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              focus.clearHistory();
            },
            child: Text('Reset', style: TextStyle(color: HiveColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            if (selected) const Icon(Icons.check_circle, color: HiveColors.honeyGold),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}